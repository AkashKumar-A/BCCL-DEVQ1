import { LightningElement } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import aopMappings from '@salesforce/resourceUrl/aopMappings';
import updateTargets from '@salesforce/apex/UploadAOPController.updateTargets';

export default class UploadAOP extends LightningElement {
    selectedCsvFile;
    selectedFilename;

    partnershipMappings;
    developmentMappings;
    nationalVerticalMappings;
    restBranchMappings;

    allPromiseList = [];
    

    selectedCSVData;
    showSipnner = false;
    showMonthOptions = false;
    showStructureOptions = false;
    selectedMonth;
    selectedStructure;
    monthOptions = [];
    structureOptions = [];
    selectedMonthAOP = [];

    connectedCallback() {
        console.log(aopMappings);
        this.allPromiseList = [
            fetch(`${aopMappings}/Partnership.csv`).then(resp => resp.text())
            .then(data => {this.partnershipMappings = this.parseCSV(data, true)})
            .catch(err=>{console.error(err)}),
        
            fetch(`${aopMappings}/Development.csv`).then(resp => resp.text())
            .then(data => {this.developmentMappings = this.parseCSV(data, true)})
            .catch(err=>{console.error(err)}),
        
            fetch(`${aopMappings}/NationalVerticals.csv`).then(resp => resp.text())
            .then(data => {this.nationalVerticalMappings = this.parseCSV(data, true)})
            .catch(err=>{console.error(err)}),
        
            fetch(`${aopMappings}/RestBranches.csv`).then(resp => resp.text())
            .then(data => {this.restBranchMappings = this.parseCSV(data, true)})
            .catch(err=>{console.error(err)})
        ];
    }

    csvSelected(evt) {
        console.log(evt.target.files[0].name);
        this.selectedFilename = evt.target.files[0].name;
        this.selectedCsvFiles = evt.target.files;
        let reader = new FileReader();
        reader.onload = (evt) => {
        let csvData = evt.target.result;
            let res = this.parseCSV(csvData, true);
            this.selectedCSVData = res;
            Promise.all(this.allPromiseList).then(allLoaded => this.parseAOP()).catch(err => {console.error(err);});
        }
        reader.readAsText(evt.target.files[0]);
    }

    parseAOP() {
        console.log('csvData', this.selectedCSVData[0]);
        // console.log('Part', this.partnershipMappings[0]);
        // console.log('Dev', this.developmentMappings[0]);
        // console.log('NV', this.nationalVerticalMappings[0]);
        // console.log('RB', this.restBranchMappings[0]);
        let monthSet = new Set();
        this.selectedCSVData.forEach(item => {
            monthSet.add(item.AOPMONTH);
        });
        console.log(monthSet);
        this.monthOptions = [...monthSet].map(item => {return {label: item, value: item}});
        console.log(this.monthOptions);
        this.showMonthOptions = true;
    }

    monthSelected(evt) {
        let value = evt.target.value;
        console.log(value);
        this.selectedMonth = value;
        this.selectedMonthAOP = this.selectedCSVData.filter(item => item.AOPMONTH == value);
        console.log('selected month records', this.selectedMonthAOP.length);
        let kamStructures = new Set();
        console.log('1');
        this.selectedMonthAOP.forEach(item => {
            kamStructures.add(item.KAMStructure);
        });
        console.log('2');
        let structures = [];
        console.log('3');
        kamStructures.forEach(item => {
            console.log('4');
            structures.push({
                label: item,
                value: item
            });
        })
        console.log('5');
        this.showStructureOptions = true;
        this.structureOptions = structures;
    }

    structureChanged(evt) {
        let selected = evt.target.value;
        if (selected) {
            this.selectedStructure = selected;
            this.disableUpload = false;
        }
    }

    handleUploadAOP(evt) {
        let filteredList = this.selectedMonthAOP.filter(item => item.KAMStructure == this.selectedStructure);
        switch (this.selectedStructure) {
            case 'REST BRANCHES':
                console.log('rest branches');
                this.parseRestBranchAOP(filteredList);
                break;
            
            case 'NATIONAL VERTICALS':
                console.log('national verticals');
                this.parseNationalVerticalAOP(filteredList)
                break;
            
            case 'DEVELOPMENT ACCOUNTS':
                console.log('development accounts');
                this.parseDevelopmentAccounts(filteredList)
                break;
            
            case 'PARTNERSHIP ACCOUNTS':
                console.log('Partnership accounts');
                this.parsePartnershipAccounts(filteredList);
                break;

            default:
                this.dispatchEvent(new ShowToastEvent({
                    title: "Error!",
                    message: "Please select a KAM Structure from the dropdown",
                    variant: "error"
                }));
                break;
        }
    }

    parseRestBranchAOP(restBranchAOP) {
        this.showSipnner = true;
        try {
            console.log('rest branch of selected month', restBranchAOP.length);
            let bhMap = new Map();
            let bvhMap = new Map();
            restBranchAOP.forEach(item => {
                let bvhKey = item.Branch + ' ' + item.VERTICAL;
                if (!bhMap.has(item.BH_KAM_L1?.toUpperCase())) {
                    bhMap.set(item.BH_KAM_L1?.toUpperCase(), {PRINT: 0, TIL: 0})
                }
                if (!bvhMap.has(bvhKey?.toUpperCase())) {
                    bvhMap.set(bvhKey?.toUpperCase(), {PRINT: 0, TIL: 0})
                }
                bhMap.get(item.BH_KAM_L1?.toUpperCase())[item['Print/Nonprint']] += parseFloat(item.AOPVALUE);
                bvhMap.get(bvhKey?.toUpperCase())[item['Print/Nonprint']] += parseFloat(item.AOPVALUE);
            });
            let roleName_TargetMap = new Map();
            if (this.restBranchMappings && this.restBranchMappings.length) {
                let bhMappings = new Map();
                let bvhMappings = new Map();
                this.restBranchMappings.forEach(item => {
                    let bvhKey = item['Final Branch'] + ' ' + item.Vertical;
                    if (!bhMappings.has(item.BH_KAM_L1?.toUpperCase())) {
                        bhMappings.set(item.BH_KAM_L1?.toUpperCase(), item.BH?.toUpperCase());
                    }
                    if (!bvhMappings.has(bvhKey?.toUpperCase())) {
                        bvhMappings.set(bvhKey?.toUpperCase(), item['Role Name']?.toUpperCase());
                    }
                });
                for (let [key, value] of bhMap) {
                    let roleName = bhMappings.get(key);
                    let obj = {...value};
                    obj.PRINT = obj.PRINT ? obj.PRINT * 1_00_00_000 : 0;
                    obj.TIL = obj.TIL ? obj.TIL * 1_00_00_000 : 0;
                    if (roleName) {
                        roleName_TargetMap.set(roleName, obj);
                    }
                }
                for (let [key, value] of bvhMap) {
                    let roleName = bvhMappings.get(key);
                    let obj = {...value};
                    obj.PRINT = obj.PRINT ? obj.PRINT * 1_00_00_000 : 0;
                    obj.TIL = obj.TIL ? obj.TIL * 1_00_00_000 : 0;
                    if (roleName) {
                        roleName_TargetMap.set(roleName, obj);
                    }
                }
                console.log(roleName_TargetMap);
                
                this.showSipnner = true;
                Promise.all([
                    updateTargets({month: this.selectedMonth, targetMap: Object.fromEntries(roleName_TargetMap)})
                    .then(resp => {console.log(resp);})
                    .catch(err => {console.log('bh', err);}),
                ])
                .then(allLoaded => {
                    this.showSipnner = false;
                    this.dispatchEvent(new ShowToastEvent({
                        title: "Success!",
                        message: "Targets have been uploaded for " + this.selectedStructure,
                        variant: "success"
                    }));
                })
                .catch(err => {
                    console.error(err);
                    this.showSipnner = false;
                });
            }
        }
        catch(err) {
            console.error(err);
            this.showSipnner = false;
        }
    }

    parseNationalVerticalAOP(nationalVerticalAOP) {
        this.showSipnner = true;
        try{
            console.log('natinal of selected month', nationalVerticalAOP.length);
            let directorMap = new Map();
            let nvhMap = new Map();
            let bvhMap = new Map();
            nationalVerticalAOP.forEach(item => {
                let bvhKey = item.Branch + ' ' + item.VERTICAL;
                if (!directorMap.has(item.VERTICAL?.toUpperCase())) {
                    directorMap.set(item.VERTICAL?.toUpperCase(), {PRINT: 0, TIL: 0})
                }
                if(!nvhMap.has(item.RH_NVH?.toUpperCase())) {
                    nvhMap.set(item.RH_NVH?.toUpperCase(),{PRINT: 0, TIL: 0})
                }
                if (!bvhMap.has(bvhKey?.toUpperCase())) {
                    bvhMap.set(bvhKey?.toUpperCase(), {PRINT: 0, TIL: 0})
                }
                directorMap.get(item.VERTICAL?.toUpperCase())[item['Print/Nonprint']] += parseFloat(item.AOPVALUE);
                bvhMap.get(bvhKey?.toUpperCase())[item['Print/Nonprint']] += parseFloat(item.AOPVALUE);
                nvhMap.get(item.RH_NVH?.toUpperCase())[item['Print/Nonprint']] += parseFloat(item.AOPVALUE);
            });
            let roleName_TargetMap = new Map();

            if (this.nationalVerticalMappings && this.nationalVerticalMappings.length) {
                let nvhMapping = new Map();
                let bvhMappings = new Map();
                let directorMapping = new Map();
                this.nationalVerticalMappings.forEach(item => {
                    let bvhKey = item['BH_KAM_L1'] + ' ' + item.Vertical;
                    if (!bvhMappings.has(bvhKey?.toUpperCase())) {
                        bvhMappings.set(bvhKey?.toUpperCase(), item['BVH']?.toUpperCase());
                    }
                    if (!nvhMapping.has(item.RH_NVH?.toUpperCase())) {
                        nvhMapping.set(item.RH_NVH?.toUpperCase(), item.NVH?.toUpperCase());
                    }
                    if(!directorMapping.has(item.Vertical?.toUpperCase())) {
                        directorMapping.set(item.Vertical?.toUpperCase(),item.Director?.toUpperCase());
                    }
                });
                // console.log('bvh mapping'+bvhMappings.get('AHM INTERNATIONAL'));
                // console.log('nvh mapping'+nvhMapping.get('NVH INTERNATIONAL'));
                // console.log('director mapping '+directorMapping.get('INTERNATIONAL'));
                for (let [key, value] of bvhMap) {
                    let roleName = bvhMappings.get(key);
                    let obj = {...value};
                    obj.PRINT = obj.PRINT ? obj.PRINT * 1_00_00_000 : 0;
                    obj.TIL = obj.TIL ? obj.TIL * 1_00_00_000 : 0;
                    if (roleName) {
                        roleName_TargetMap.set(roleName, obj);
                    }
                }
                for (let [key, value] of nvhMap) {
                    let roleName = nvhMapping.get(key);
                    let obj = {...value};
                    obj.PRINT = obj.PRINT ? obj.PRINT * 1_00_00_000 : 0;
                    obj.TIL = obj.TIL ? obj.TIL * 1_00_00_000 : 0;
                    if (roleName) {
                        roleName_TargetMap.set(roleName, obj);
                    }
                }
                for (let [key, value] of directorMap) {
                    let roleName = directorMapping.get(key);
                    let obj = {...value};
                    obj.PRINT = obj.PRINT ? obj.PRINT * 1_00_00_000 : 0;
                    obj.TIL = obj.TIL ? obj.TIL * 1_00_00_000 : 0;
                    if (roleName) {
                        roleName_TargetMap.set(roleName, obj);
                    }
                }
                // update the records
                this.showSipnner = true;
                Promise.all([
                    updateTargets({month: this.selectedMonth, targetMap: Object.fromEntries(roleName_TargetMap)})
                    .then(resp => {console.log(resp);})
                    .catch(err => {console.log('bvh', err);}),
                ])
                .then(allLoaded => {
                    this.showSipnner = false;
                    this.dispatchEvent(new ShowToastEvent({
                        title: "Success!",
                        message: "Targets have been uploaded for " + this.selectedStructure,
                        variant: "success"
                    }));
                })
                .catch(err => {
                    console.error(err);
                    this.showSipnner = false;
                });
                
                
            }
        }
        catch(err) {
            console.error(err);
            this.showSipnner = false;
        }
    }

    parseDevelopmentAccounts(developmentAOP) {
        this.showSipnner = true;
        try {
            console.log('rest branch of selected month', developmentAOP.length);
            let bvhMap = new Map();
            developmentAOP.forEach(item => {
                //console.log('ach '+item.AOPVALUE);
                let bvhKey = item.Branch + ' ' + item.VERTICAL;
                if (!bvhMap.has(bvhKey?.toUpperCase())) {
                    bvhMap.set(bvhKey?.toUpperCase(), {PRINT: 0, TIL: 0})
                }
                if (item['Print/Nonprint'] == 'PRINT') {
                    bvhMap.get(bvhKey?.toUpperCase()).PRINT += parseFloat(item.AOPVALUE);
                }
                else if (item['Print/Nonprint'] == 'TIL') {
                    bvhMap.get(bvhKey?.toUpperCase()).TIL += parseFloat(item.AOPVALUE);
                }
            });
            let roleName_TargetMap = new Map();
            if (this.developmentMappings && this.developmentMappings.length) {
                let bvhMappings = new Map();
                this.developmentMappings.forEach(item => {
                    let bvhKey = item['Final Branch'] + ' ' + item.Vertical;
                    
                    if (!bvhMappings.has(bvhKey?.toUpperCase())) {
                        bvhMappings.set(bvhKey?.toUpperCase(), item['BVH']?.toUpperCase());
                    }
                });
                
                for (let [key, value] of bvhMap) {
                    let roleName = bvhMappings.get(key);
                    let obj = {...value};
                    obj.PRINT = obj.PRINT ? obj.PRINT * 1_00_00_000 : 0;
                    obj.TIL = obj.TIL ? obj.TIL * 1_00_00_000 : 0;
                    if (roleName) {
                        roleName_TargetMap.set(roleName, obj);
                    }
                }
                
                this.showSipnner = true;
                Promise.all([                   
                    updateTargets({month: this.selectedMonth, targetMap: Object.fromEntries(roleName_TargetMap)})
                    .then(resp => {console.log(resp);})
                    .catch(err => {console.log('bvh', err);})
                ])
                .then(allLoaded => {
                    this.showSipnner = false;
                    this.dispatchEvent(new ShowToastEvent({
                        title: "Success!",
                        message: "Targets have been uploaded for " + this.selectedStructure,
                        variant: "success"
                    }));
                })
                .catch(err => {
                    console.error(err);
                    this.showSipnner = false;
                });
            }
        }
        catch(err) {
            console.error(err);
            this.showSipnner = false;
        }
    }

    parsePartnershipAccounts(partnershipAOP) {
        this.showSipnner = true;
        try{
            console.log('natinal of selected month', partnershipAOP.length);
            let directorMap = new Map();
            let rhMap = new Map();
            let bhMap = new Map();
            let kamMap = new Map();
            partnershipAOP.forEach(item => {
                let directorKey = item.Branch + ' ' + item.BH_KAM_L1;
                let rhKey = item.Branch + ' ' + item.BH_KAM_L1;
                let bhKey = item.Branch + ' ' + item.BH_KAM_L1;
                let kamKey = item.Branch + ' ' + item.BVH_JKAM_L2;
                if (!directorMap.has(directorKey?.toUpperCase())) {
                    directorMap.set(directorKey?.toUpperCase(), {PRINT: 0, TIL: 0});
                }
                if(!rhMap.has(rhKey?.toUpperCase())) {
                    rhMap.set(rhKey?.toUpperCase(),{PRINT: 0, TIL: 0});
                }
                if (!bhMap.has(bhKey?.toUpperCase())) {
                    bhMap.set(bhKey?.toUpperCase(), {PRINT: 0, TIL: 0});
                }
                if (!kamMap.has(kamKey?.toUpperCase())) {
                    kamMap.set(kamKey?.toUpperCase(), {PRINT: 0, TIL: 0});
                }
                directorMap.get(directorKey?.toUpperCase())[item['Print/Nonprint']] += parseFloat(item.AOPVALUE);
                rhMap.get(rhKey?.toUpperCase())[item['Print/Nonprint']] += parseFloat(item.AOPVALUE);
                bhMap.get(bhKey?.toUpperCase())[item['Print/Nonprint']] += parseFloat(item.AOPVALUE);
                kamMap.get(kamKey?.toUpperCase())[item['Print/Nonprint']] += parseFloat(item.AOPVALUE);
            });
            let roleName_TargetMap = new Map();

            function prepareMap(roleName, obj, map) {
                obj.PRINT = obj.PRINT ? obj.PRINT * 1_00_00_000 : 0;
                obj.TIL = obj.TIL ? obj.TIL * 1_00_00_000 : 0;
                if (!map.has(roleName)) {
                    map.set(roleName, {PRINT: 0, TIL: 0});
                }
                map.get(roleName).PRINT += obj.PRINT;
                map.get(roleName).TIL += obj.TIL;
            }
            let nvhTagetMap = new Map();
            let directorTargetMap = new Map();
            let bvhTargetMap = new Map();
            if (this.partnershipMappings && this.partnershipMappings.length) {
                let directorMapping = new Map();
                let rhMapping = new Map();
                let bhMapping = new Map();
                let kamMapping = new Map();
                this.partnershipMappings.forEach(item => {
                    let directorKey = item.Branch + ' ' + item.BH_KAM_L1;
                    let rhKey = item.Branch + ' ' + item.BH_KAM_L1;
                    let bhKey = item.Branch + ' ' + item.BH_KAM_L1;
                    let kamKey = item.Branch + ' ' + item.BVH_JKAM_L2;
                    if(!directorMapping.has(directorKey?.toUpperCase())) {
                        directorMapping.set(directorKey?.toUpperCase(), item['Parent Parent Parent Role Name']?.toUpperCase());
                    }
                    if (!rhMapping.has(rhKey?.toUpperCase())) {
                        rhMapping.set(rhKey?.toUpperCase(), item['Parent Parent Role Name']?.toUpperCase());
                    }
                    if (!bhMapping.has(bhKey?.toUpperCase())) {
                        bhMapping.set(bhKey?.toUpperCase(), item['Parent Role Name']?.toUpperCase());
                    }
                    if (!kamMapping.has(kamKey?.toUpperCase())) {
                        kamMapping.set(kamKey?.toUpperCase(), item['Role Name']?.toUpperCase());
                    }
                });
                for (let [key, value] of directorMap) {
                    let roleName = directorMapping.get(key);
                    let obj = {...value};
                    prepareMap(roleName, obj, roleName_TargetMap);
                }
                for (let [key, value] of rhMap) {
                    let roleName = rhMapping.get(key);
                    let obj = {...value};
                    prepareMap(roleName, obj, roleName_TargetMap);
                }
                for (let [key, value] of bhMap) {
                    let roleName = bhMapping.get(key);
                    let obj = {...value};
                    prepareMap(roleName, obj, roleName_TargetMap);
                }
                for (let [key, value] of kamMap) {
                    let roleName = kamMapping.get(key);
                    let obj = {...value};
                    prepareMap(roleName, obj, roleName_TargetMap);
                }
                console.log('values:', roleName_TargetMap);
                // update the records
                this.showSipnner = true;
                Promise.all([
                    updateTargets({month: this.selectedMonth, targetMap: Object.fromEntries(roleName_TargetMap)})
                    .then(resp => {console.log(resp);})
                    .catch(err => {console.log('bvh', err);}),
                ])
                .then(allLoaded => {
                    this.showSipnner = false;
                    this.dispatchEvent(new ShowToastEvent({
                        title: "Success!",
                        message: "Targets have been uploaded for " + this.selectedStructure,
                        variant: "success"
                    }));
                })
                .catch(err => {
                    console.error(err);
                    this.showSipnner = false;
                });
                
                
            }
        }
        catch(err) {
            console.error(err);
            this.showSipnner = false;
        }
    }

    parseCSV( strData, csvWithHeader, strDelimiter ){
        // Check to see if the delimiter is defined. If not,
        // then default to comma.
        strDelimiter = (strDelimiter || ",");
        csvWithHeader = (csvWithHeader || false);
 
        // Create a regular expression to parse the CSV values.
        var objPattern = new RegExp(
            (
                // Delimiters.
                "(\\" + strDelimiter + "|\\r?\\n|\\r|^)" +
 
                // Quoted fields.
                "(?:\"([^\"]*(?:\"\"[^\"]*)*)\"|" +
 
                // Standard fields.
                "([^\"\\" + strDelimiter + "\\r\\n]*))"
            ),
            "gi"
        );
 
 
        // Create an array to hold our data. Give the array
        // a default empty first row.
        var arrData = [[]];
        var headers = [];
        if (csvWithHeader) {
            arrData = [];
        }
        // Create an array to hold our individual pattern
        // matching groups.
        var arrMatches = null;
 
        let currentColIndex = -1;
        // Keep looping over the regular expression matches
        // until we can no longer find a match.
        while (arrMatches = objPattern.exec( strData )){
 
            // Get the delimiter that was found.
            var strMatchedDelimiter = arrMatches[ 1 ];
 
            // Check to see if the given delimiter has a length
            // (is not the start of string) and if it matches
            // field delimiter. If id does not, then we know
            // that this delimiter is a row delimiter.
            if (
                strMatchedDelimiter.length &&
                strMatchedDelimiter !== strDelimiter
            ){
 
                // Since we have reached a new row of data,
                // add an empty row to our data array.
                if (csvWithHeader) {
                    arrData.push({});
                }
                else {
                    arrData.push( [] );
                }
                currentColIndex = 0;
 
            }
            else {
                currentColIndex++;
            }
 
            var strMatchedValue;
 
            // Now that we have our delimiter out of the way,
            // let's check to see which kind of value we
            // captured (quoted or unquoted).
            if (arrMatches[ 2 ]){
 
                // We found a quoted value. When we capture
                // this value, unescape any double quotes.
                strMatchedValue = arrMatches[ 2 ].replace(
                    new RegExp( "\"\"", "g" ),
                    "\""
                    );
 
            } else {
 
                // We found a non-quoted value.
                strMatchedValue = arrMatches[ 3 ];
 
            }

 
 
            // Now that we have our value string, let's add
            // it to the data array.
            if (csvWithHeader) {
                if (arrData.length == 0) {
                    headers.push(strMatchedValue);
                }
                else {
                    let headerName = headers[currentColIndex];
                    arrData[ arrData.length - 1 ][headerName] = strMatchedValue;
                }
            }
            else {
                arrData[ arrData.length - 1 ].push( strMatchedValue );
            }
        }
        let lastItem = arrData[arrData.length - 1];
        if (Object.keys(lastItem).length == 1 && Object.keys(lastItem)[0] == headers[0] && lastItem[headers[0]] == '') {
            arrData.pop();
        }
        
        // Return the parsed data.
        return( arrData );
    }
}
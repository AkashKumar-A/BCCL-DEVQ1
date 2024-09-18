({
    getGraphColorCodes :function(component, event, helper) {
        var action = component.get("c.getColorCodes");        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var colorCodeList = response.getReturnValue();
                console.log('===colorCodeList=== '+JSON.stringify(colorCodeList));
                component.set("v.graphColorCodeList",colorCodeList);
                this.getIndividualData(component, event, helper);
            } 
            else if(state === "ERROR") { 
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                    errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
            else {
                console.log("Unknown error-- " +response.getReturnValue());
            }    
        });
        $A.enqueueAction(action);
    },
    
    getIndividualData :function(component, event, helper) {
        component.set("v.checkedIndividual",true);
        component.set("v.checkedCumulative",false);
        
        var action = component.get("c.getTargetsData");
        action.setParams({
            "isIndividual": true
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var wrapperList = response.getReturnValue();
                console.log('===wrapperListIndividual=== '+JSON.stringify(wrapperList));
                component.set("v.roleWiseWrapperList",wrapperList);
                this.generateIndividualChart(component, event, helper);
            } 
            else if(state === "ERROR") { 
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                    errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
            else {
                console.log("Unknown error-- " +response.getReturnValue());
            }    
        });
        $A.enqueueAction(action);
    },
    getCumulativeData :function(component, event, helper) {
        component.set("v.checkedCumulative",true);
        component.set("v.checkedIndividual",false);
        var action = component.get("c.getTargetsData");
        action.setParams({
            "isIndividual": false
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var wrapperList = response.getReturnValue();
                console.log('===wrapperListCumulative=== '+JSON.stringify(wrapperList));
                component.set("v.roleWiseWrapperList",wrapperList);
                this.generateCumulativeChart(component, event, helper);
            } 
            else if(state === "ERROR") { 
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                    errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
            else {
                console.log("Unknown error-- " +response.getReturnValue());
            }    
        });
        $A.enqueueAction(action);
    },
    
    generateIndividualChart : function(component, event, helper) {
        var wrapperList = component.get("v.roleWiseWrapperList");
        //alert('wrapperList'+JSON.stringify(wrapperList));
        var graphColorCodeList = component.get("v.graphColorCodeList");
        var dataArray = [];
        var minHeightOfDiv = 150;
        if (wrapperList != undefined) {
            var count = 0;           
            for (var indexVar = 0; indexVar < wrapperList.length; indexVar++) {                
                minHeightOfDiv = minHeightOfDiv + 50;
                if (wrapperList[indexVar].targetDistributionList != undefined) {
                    var v1 = {
                        label: wrapperList[indexVar].roleName+ '-T',
                        data: wrapperList[indexVar].targetDistributionList,
                        fill: false,
                        borderColor:graphColorCodeList[count],
                        borderWidth: 2,
                        /*pointBorderWidth: 4,
                        pointHoverRadius: 5,
                        pointRadius: 3,*/
                    };
                    dataArray.push(v1);
                }
                if (wrapperList[indexVar].achievementDistributionList != undefined) {
                    var v2 = {
                        label:wrapperList[indexVar].roleName+ '-A',
                        data: wrapperList[indexVar].achievementDistributionList,
                        fill: false,
                        borderColor:graphColorCodeList[count+1],
                        borderWidth: 2,
                        /*pointBorderWidth: 4,
                        pointHoverRadius: 5,
                        pointRadius: 3,*/
                    };
                    dataArray.push(v2);
                }
                count = count +2;
            }
        }
        var chartDiv = document.getElementById("individualDivId");
        chartDiv.style.height = minHeightOfDiv+'px';
        
        var chartdata = {
            labels: ['Apr','May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct','Nov','Dec','Jan','Feb','Mar'],
            datasets: dataArray
        }
        
        //Get the context of the canvas element we want to select
        var ctx = component.find("linechart").getElement();
        var lineChart = new Chart(ctx ,{
            type: 'line',
            data: chartdata,
            options: {	
                legend: {
                    position: 'bottom',
                    padding: 10,
                },
                responsive: true,
                maintainAspectRatio: false
            }
        });        
    },
    generateCumulativeChart : function(component, event, helper) {
        var wrapperList = component.get("v.roleWiseWrapperList");
        var dataArray = [];
        for (var indexVar = 0; indexVar < wrapperList.length; indexVar++) {
            
            if(wrapperList.length > 0){
            if (wrapperList[indexVar].targetDistributionList != undefined) {
                var v1 = {
                    label:wrapperList[indexVar].roleName + ' -T',
                    data: wrapperList[indexVar].targetDistributionList,
                    fill: false,
                    borderColor:'rgba(62, 159, 222, 1)',
                    borderWidth: 2,
                };
                dataArray.push(v1);
            }
            if (wrapperList[indexVar].achievementDistributionList != undefined) {
                var v2 = {
                    label:wrapperList[indexVar].roleName+ ' -A',
                    data: wrapperList[indexVar].achievementDistributionList,
                    fill: false,
                    borderColor:'rgba(10, 25, 30, 50)',
                    borderWidth: 2,
                };
                dataArray.push(v2);
            }
        }
        }
        var chartdata = {
            labels: ['Apr','May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct','Nov','Dec','Jan','Feb','Mar'],
            datasets: dataArray
        }
        
        //Get the context of the canvas element we want to select
        var ctx = component.find("linechart1").getElement();
        var lineChart = new Chart(ctx ,{
            type: 'line',
            data: chartdata,
            options: {	
                legend: {
                    position: 'bottom',
                    padding: 10,
                },
                responsive: true,
                maintainAspectRatio: false
            }
        });        
    },
    getRandomColor : function(component, event, helper) {
        var letters = '0123456789ABCDEF';
        var color = '#';
        for (var i = 0; i < 6; i++) {
            color += letters[Math.floor(Math.random() * 16)];
        }
        return color;
    }
    
    
})
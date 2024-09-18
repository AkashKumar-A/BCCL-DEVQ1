({
    helperMethod : function() {
        
    },
    cMonthValues : function(component, event, helper) {
        var action =  component.get("c.getPicklistvalues");
        action.setCallback(this,function(response){
            var state =  response.getState();   
            if(state === 'SUCCESS'){
                component.set("v.mList",response.getReturnValue()); 
            }
            else{
                this.showErrorToast(component, event,'Something went wrong, contact your administrator.');
            }
        });
        $A.enqueueAction(action);  
    },
    
    //Shubham
    viewScreen: function(component, event, helper) {
        var a=component.get("v.selectedRoleValue");
        console.log(a);
        
        var action1 =  component.get("c.getOfficeType");
        action1.setParams({
            'roleId':''
        })
        action1.setCallback(this,function(response){
            var state =  response.getState();
            var res = response.getReturnValue();
            
            if(res.includes("BH") || res.includes("Director") || res.includes("SOH") || res.includes("BVH") || res.includes("President")){
                component.set("v.displayVerticalPanel",true); 
            }
            else{
                component.set("v.displayVerticalPanel",false);
            }
            if(res.includes("SOVGH") || res.includes("BVGH") || res.includes("BVH") || res.includes("BH") || res.includes("RVH") || res.includes("NVH") || res.includes("Director") || res.includes("President")){
                component.set("v.displayBranchPanel",true); 
            }
            else{
                component.set("v.displayBranchPanel",false);
            }
            if((res.includes("BH") && !res.includes("BHH")) || res.includes("RVH") || res.includes("NVH") || res.includes("Director") || res.includes("President"))
            {
                component.set("v.displayProjButton",false);
                component.set("v.displayOppButton",false);
                component.set("v.displayFieldsPanel",false);
                component.set("v.displayProjFilterButton",true);
            }
            else 
            {
                component.set("v.displayProjButton",true);
                component.set("v.displayOppButton",true);
                component.set("v.displayFieldsPanel",true);
                component.set("v.displayProjFilterButton",false);
            }
            if(res.includes("STM"))
            {
                component.set('v.mycolumns', [
            
            {label: 'Name', fieldName: 'linkName1', type: 'url', 
            typeAttributes: {label: { fieldName: 'Name' }, target: '_blank'}},
            //{label: 'Created By', fieldName: 'Owner_Name__c', type: 'text'},
            {label: 'Vertical', fieldName: 'bccl_Vertical_Name__c', type: 'text'},
            {label: 'MM/YY', fieldName: 'bccl_Projection_Month_Year__c', type: 'text'},
            {label: 'Print ( In lacs)', fieldName: 'bccl_Projection_Week_1__c', type: 'number', editable : 'true'},
            {label: 'Non-Print ( In lacs)', fieldName: 'bccl_Non_Print_1__c', type: 'number', editable : 'true'},
            {label: 'Created ( In lacs)', fieldName: 'bccl_Created_1__c', type: 'number', editable : 'true'},
             {label: 'Total( In lacs)', fieldName: 'Total__c', type: 'Integer', editable :false},
            {label: 'Probability', fieldName: 'bccl_Probability__c', type: 'text'},
            {label: 'Sales Office', fieldName: 'Sales_Office_Name__c', type: 'text'},
            {label: 'Field Visits', fieldName: 'Number_of_Events__c', type: 'text'}
          ]);
            }
            if(res.includes("SOH"))
            {
                component.set('v.mycolumns', [
            
            {label: 'Name', fieldName: 'linkName1', type: 'url', 
            typeAttributes: {label: { fieldName: 'Name' }, target: '_blank'}},
            {label: 'Created By', fieldName: 'Owner_Name__c', type: 'text'},
            {label: 'Vertical', fieldName: 'bccl_Vertical_Name__c', type: 'text'},
            {label: 'MM/YY', fieldName: 'bccl_Projection_Month_Year__c', type: 'text'},
            {label: 'Print ( In lacs)', fieldName: 'bccl_Projection_Week_1__c', type: 'number', editable : 'true'},
            {label: 'Non-Print ( In lacs)', fieldName: 'bccl_Non_Print_1__c', type: 'number', editable : 'true'},
            {label: 'Created ( In lacs)', fieldName: 'bccl_Created_1__c', type: 'number', editable : 'true'},
             {label: 'Total( In lacs)', fieldName: 'Total__c', type: 'Integer', editable : false},
            {label: 'Probability', fieldName: 'bccl_Probability__c', type: 'text'},
            //{label: 'Sales Office', fieldName: 'Sales_Office_Name__c', type: 'text'}
            {label: 'Field Visits', fieldName: 'Number_of_Events__c', type: 'text'}
          ]);
            }
            if(!res.includes("SOH") && !res.includes("STM"))
            {
                component.set('v.mycolumns', [
            //{label: 'Name', fieldName: 'Name', type: 'text'},
            
            {label: 'Name', fieldName: 'linkName1', type: 'url', 
            typeAttributes: {label: { fieldName: 'Name' }, target: '_blank'}},
            
            //{label: 'Account Name', fieldName: 'bccl_Account_Name__c', type: 'text'},
            
         //  {label: 'Account Name', fieldName: 'linkName', type: 'url', 
           // typeAttributes: {label: { fieldName: 'bccl_Account_Name__c' }, target: '_blank'}},
            
           {label: 'Created By', fieldName: 'Owner_Name__c', type: 'text'},
          
        	
            //{label: 'Role Name', fieldName: 'bccl_Role_Name__c', type: 'text'},
            {label: 'Vertical', fieldName: 'bccl_Vertical_Name__c', type: 'text'},
            {label: 'MM/YY', fieldName: 'bccl_Projection_Month_Year__c', type: 'text'},
            {label: 'Print ( In lacs)', fieldName: 'bccl_Projection_Week_1__c', type: 'number', editable : 'true'},
            {label: 'Non-Print ( In lacs)', fieldName: 'bccl_Non_Print_1__c', type: 'number', editable : 'true'},
            {label: 'Created ( In lacs)', fieldName: 'bccl_Created_1__c', type: 'number', editable : 'true'},
             {label: 'Total( In lacs)', fieldName: 'Total__c', type: 'Integer', editable : false},
            {label: 'Probability', fieldName: 'bccl_Probability__c', type: 'text'},
            {label: 'Sales Office', fieldName: 'Sales_Office_Name__c', type: 'text'},
            {label: 'Field Visits', fieldName: 'Number_of_Events__c', type: 'text'}
            //{label: 'Region', fieldName: 'Region__c', type: 'text'},
            //{label: 'Director', fieldName: 'Director__c', type: 'text'}
            //{label: 'Description', fieldName: 'Description__c', type: 'textarea'}
          ]);
            }
                
        });
        $A.enqueueAction(action1);
        
    },
    
    
    
    
    
    salesOfficeValues : function(component, event, helper) {
        var action =  component.get("c.getSalesOfficeList");
        var roleV=component.get("v.selectedRoleValue");
        action.setParams({
            'roleId':roleV
        })
        action.setCallback(this,function(response){
            var state =  response.getState();   
            if(state === 'SUCCESS'){
                component.set("v.salesOfficeList",response.getReturnValue()); 
            }
            else{
                this.showErrorToast(component, event,'Something went wrong, contact your administrator.');
            }
        });
        $A.enqueueAction(action);  
    },
    //Shubham End
    
    verticalValues : function(component, event, helper) {
        var action =  component.get("c.getVerticalList");
        action.setCallback(this,function(response){
            var state =  response.getState();   
            if(state === 'SUCCESS'){
                component.set("v.verticalList",response.getReturnValue()); 
            }
            else{
                this.showErrorToast(component, event,'Something went wrong, contact your administrator.');
            }
        });
        $A.enqueueAction(action);  
    },
    horizontalValues : function(component, event, helper) {
        var action =  component.get("c.getHorizontalList");
        action.setCallback(this,function(response){
            var state =  response.getState();   
            if(state === 'SUCCESS'){
                component.set("v.horizontalList",response.getReturnValue()); 
            }
           else{
                this.showErrorToast(component, event,'Something went wrong, contact your administrator.');
            }
        });
        $A.enqueueAction(action);  
    },
    roleValues : function(component, event, helper) {
        var action =  component.get("c.getRoleList");
        action.setCallback(this,function(response){
            var state =  response.getState();   
            if(state === 'SUCCESS'){
                component.set("v.roleList",response.getReturnValue()); 
            }
            else{
                this.showErrorToast(component, event,'Something went wrong, contact your administrator.');
            }
        });
        $A.enqueueAction(action);  
    },

    /*monthValues : function(component, event, helper) {
        var action = component.get("c.getMonthSelectOptions");
        var inputIndustry = component.find("monthID");
        var opts=[];
        action.setCallback(this, function(a) {
            opts.push({
                class: "optionClass",
                label: "--- None ---",
                value: ""
            });
            for(var i=0;i< a.getReturnValue().length;i++){
                opts.push({"class": "optionClass", label: a.getReturnValue()[i], value: a.getReturnValue()[i]});
            }
            inputIndustry.set("v.options", opts);
        });
        $A.enqueueAction(action);  
    },

    yearValues : function(component, event, helper) {
        var action = component.get("c.getYearSelectOptions");
        var inputIndustry = component.find("yearID");
        var opts=[];
        action.setCallback(this, function(a) {
            opts.push({
                class: "optionClass",
                label: "--- None ---",
                value: ""
            });
            for(var i=0;i< a.getReturnValue().length;i++){
                opts.push({"class": "optionClass", label: a.getReturnValue()[i], value: a.getReturnValue()[i]});
            }
            inputIndustry.set("v.options", opts);
        });
        $A.enqueueAction(action);  
    },*/

    fetchRoles : function (component, event, helper) {
        var geoId=
            component.get("v.selectedGeographyId").Id;
        var vertId=
            component.get("v.selectedVerticalValue");
        var horiId=
            component.get("v.selectedHorizontalValue");
        var vertCategoryId=
            component.get("v.selectedVerticalCategory");

        var action = component.get("c.fetchRolesValueL");
        action.setParams({
            'selectedVerticalId':vertId,
            'verticalCategoryID':vertCategoryId,
            'selectedGeographyId':geoId,
            'horizontalId':horiId
        })
        action.setCallback(this, function(response) {
            //store state of response
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.roleList",response.getReturnValue());
            }
            else
            {
                helper.showErrorToast(component, event,'Value cannot be fetched.');
            }
      });
      $A.enqueueAction(action); 
    },
    roleProjection: function (component, event, helper) {
        var roleV=component.get("v.selectedRoleValue");
        
        var SalesOffV=component.get("v.selectedSalesOfficeValue")!= undefined ?
            component.get("v.selectedSalesOfficeValue") : undefined;
        /*var horiV=component.get("v.selectedHorizontalValue");
        var vertCat=component.get("v.selectedVerticalCategory");
        var vertV=component.get("v.selectedVerticalValue");*/

        var abc=component.get("v.selectedAccountId").Id;
        console.log('recordId:', abc);

        var mth=component.find("makeId").get("v.value")!= undefined ?
            component.find("makeId").get("v.value") : undefined;
        var prob=component.find("probId").get("v.value")!= undefined ?
            component.find("probId").get("v.value") : undefined;
        
        var action = component.get("c.createRoleAccountProjection");
        action.setParams({
            'roleID':roleV,
            'SOfficeVal':SalesOffV,
            'accId':abc,
            'monthV':mth,
            'probValue':prob
            /*
            'projAmt1':component.get("v.ProjectionAmount1"),
            'projAmt2':component.get("v.ProjectionAmount2"),
            'projAmt3':component.get("v.ProjectionAmount3"),
            'projAmt4':component.get("v.ProjectionAmount4"),
            'projAmt5':component.get("v.ProjectionAmount5"),
            'nonprojAmt1':component.get("v.nonprojectionValue1"),
            'nonprojAmt2':component.get("v.nonprojectionValue2"),
            'nonprojAmt3':component.get("v.nonprojectionValue3"),
            'nonprojAmt4':component.get("v.nonprojectionValue4"),
            'nonprojAmt5':component.get("v.nonprojectionValue5"),
            'createdAmt1':component.get("v.createdprojectionValue1"),
            'createdAmt2':component.get("v.createdprojectionValue2"),
            'createdAmt3':component.get("v.createdprojectionValue3"),
            'createdAmt4':component.get("v.createdprojectionValue4"),
            'createdAmt5':component.get("v.createdprojectionValue5"),
            'probValue':component.get("v.probabilityValue")
            */
            /*'yearValue':component.get("v.yearValue"),
            'monthValue':component.get("v.monthValue")*/
        })
        action.setCallback(this, function(response) {
            //store state of response
            var state = response.getState();
            var record = response.getReturnValue();
            if (state === "SUCCESS") {
                if(response.getReturnValue()!=null)
                {
                helper.showSuccessToast(component, event,'Account Projection created.');

                component.set("v.displaySecondPanel",true);
                component.set("v.displayRole",true);
                /*component.set("v.displayVertical",true);
                component.set("v.displayGeography",true);
                component.set("v.displayHorizontal",true);
                component.set("v.selectedVerticalValue","");*/
                component.set("v.selectedRoleValue","");
                /*component.set("v.selectedHorizontalValue","");
                component.set("v.selectedVerticalCategory","");
                component.set("v.selectedGeographyId","");*/
                component.set("v.selectedAccountId","");
                component.set("v.ProjectionAmount1","");
                /*component.set("v.ProjectionAmount2","");
                component.set("v.ProjectionAmount3","");
                component.set("v.ProjectionAmount4","");
                component.set("v.ProjectionAmount5","");*/
                component.set("v.nonprojectionValue1","");
                /*component.set("v.nonprojectionValue2","");
                component.set("v.nonprojectionValue3","");
                component.set("v.nonprojectionValue4","");
                component.set("v.nonprojectionValue5","");*/
                component.set("v.createdprojectionValue1","");
                /*component.set("v.createdprojectionValue2","");
                component.set("v.createdprojectionValue3","");
                component.set("v.createdprojectionValue4","");
                component.set("v.createdprojectionValue5","");*/
                component.set("v.probabilityValue","");
                component.find("makeId").set("v.value","");
                component.find("probId").set("v.value","");
                /*component.set("v.yearValue","");
                component.set("v.monthValue","");
                this.monthValues(component, event,helper);
                this.yearValues(component, event,helper);*/
            }
                else{
                    helper.showErrorToast(component, event,'You already have a projection record created for this Account for this month, Please edit the already existing record.');
                }
                }
            else
            {
                helper.showErrorToast(component, event,'Projection cannot be saved.');
            }
      });
      $A.enqueueAction(action);
    },
    horizontalProjection: function (component, event, helper) {
        var roleV=component.get("v.selectedRoleValue");
        var horiV=component.get("v.selectedHorizontalValue");
        var vertCat=component.get("v.selectedVerticalCategory");
        var vertV=component.get("v.selectedVerticalValue");
        var geoId=component.get("v.selectedGeographyId").Id;
        var actId=component.get("v.selectedAccountId").Id;

        var action = component.get("c.createHoriAccountProjection");
        action.setParams({
            'selectedHorizontalId':horiV,
            'selectedGeographyId':geoId,
            'accId':actId,
            'projAmt1':component.get("v.ProjectionAmount1"),
            'projAmt2':component.get("v.ProjectionAmount2"),
            'projAmt3':component.get("v.ProjectionAmount3"),
            'projAmt4':component.get("v.ProjectionAmount4"),
            'projAmt5':component.get("v.ProjectionAmount5"),
            'nonprojAmt1':component.get("v.nonprojectionValue1"),
            'nonprojAmt2':component.get("v.nonprojectionValue2"),
            'nonprojAmt3':component.get("v.nonprojectionValue3"),
            'nonprojAmt4':component.get("v.nonprojectionValue4"),
            'nonprojAmt5':component.get("v.nonprojectionValue5"),
            'createdAmt1':component.get("v.createdprojectionValue1"),
            'createdAmt2':component.get("v.createdprojectionValue2"),
            'createdAmt3':component.get("v.createdprojectionValue3"),
            'createdAmt4':component.get("v.createdprojectionValue4"),
            'createdAmt5':component.get("v.createdprojectionValue5"),
            'probValue':component.get("v.probabilityValue")
            /*'yearValue':component.get("v.yearValue"),
            'monthValue':component.get("v.monthValue")*/
        })
        action.setCallback(this, function(response) {
            //store state of response
            var state = response.getState();
            if (state === "SUCCESS") {
                helper.showSuccessToast(component, event,'Account Projection created.');

                component.set("v.displaySecondPanel",true);
                component.set("v.displayRole",true);
                component.set("v.displayVertical",true);
                component.set("v.displayGeography",true);
                component.set("v.displayHorizontal",true);
                component.set("v.selectedVerticalValue","");
                component.set("v.selectedRoleValue","");
                component.set("v.selectedHorizontalValue","");
                component.set("v.selectedVerticalCategory","");
                component.set("v.selectedGeographyId","");
                component.set("v.selectedAccountId","");
                component.set("v.ProjectionAmount1","");
                component.set("v.ProjectionAmount2","");
                component.set("v.ProjectionAmount3","");
                component.set("v.ProjectionAmount4","");
                component.set("v.ProjectionAmount5","");
                component.set("v.nonprojectionValue1","");
                component.set("v.nonprojectionValue2","");
                component.set("v.nonprojectionValue3","");
                component.set("v.nonprojectionValue4","");
                component.set("v.nonprojectionValue5","");
                component.set("v.createdprojectionValue1","");
                component.set("v.createdprojectionValue2","");
                component.set("v.createdprojectionValue3","");
                component.set("v.createdprojectionValue4","");
                component.set("v.createdprojectionValue5","");
                component.set("v.probabilityValue","");
                /*component.set("v.yearValue","");
                component.set("v.monthValue","");
                this.monthValues(component, event,helper);
                this.yearValues(component, event,helper);*/
            }
            else
            {
                helper.showErrorToast(component, event,'Role cannot be fetched for the selected horizontal.');
            }
      });
      $A.enqueueAction(action);
    },
    verticalCatProjection: function (component, event, helper) {
        var roleV=component.get("v.selectedRoleValue");
        var horiV=component.get("v.selectedHorizontalValue");
        var vertCat=component.get("v.selectedVerticalCategory");
        var vertV=component.get("v.selectedVerticalValue");
        
        var geoId=component.get("v.selectedGeographyId").Id;
        var actId=component.get("v.selectedAccountId").Id;
        
        var action = component.get("c.createVCatAccountProjection");
        action.setParams({
            'selectedVerticalId':vertV,
            'selectedGeographyId':geoId,
            'selectedVertCatId':vertCat,
            'accId':actId,
            'projAmt1':component.get("v.ProjectionAmount1"),
            'projAmt2':component.get("v.ProjectionAmount2"),
            'projAmt3':component.get("v.ProjectionAmount3"),
            'projAmt4':component.get("v.ProjectionAmount4"),
            'projAmt5':component.get("v.ProjectionAmount5"),
            'nonprojAmt1':component.get("v.nonprojectionValue1"),
            'nonprojAmt2':component.get("v.nonprojectionValue2"),
            'nonprojAmt3':component.get("v.nonprojectionValue3"),
            'nonprojAmt4':component.get("v.nonprojectionValue4"),
            'nonprojAmt5':component.get("v.nonprojectionValue5"),
            'createdAmt1':component.get("v.createdprojectionValue1"),
            'createdAmt2':component.get("v.createdprojectionValue2"),
            'createdAmt3':component.get("v.createdprojectionValue3"),
            'createdAmt4':component.get("v.createdprojectionValue4"),
            'createdAmt5':component.get("v.createdprojectionValue5"),
            'probValue':component.get("v.probabilityValue")
            /*'yearValue':component.get("v.yearValue"),
            'monthValue':component.get("v.monthValue")*/
        })
        action.setCallback(this, function(response) {
            //store state of response
            var state = response.getState();
            if (state === "SUCCESS") {
                helper.showSuccessToast(component, event,'Account Projection created.');

                component.set("v.displaySecondPanel",true);
                component.set("v.displayRole",true);
                component.set("v.displayVertical",true);
                component.set("v.displayGeography",true);
                component.set("v.displayHorizontal",true);
                component.set("v.selectedVerticalValue","");
                component.set("v.selectedRoleValue","");
                component.set("v.selectedHorizontalValue","");
                component.set("v.selectedVerticalCategory","");
                component.set("v.selectedGeographyId","");
                component.set("v.selectedAccountId","");
                component.set("v.ProjectionAmount1","");
                component.set("v.ProjectionAmount2","");
                component.set("v.ProjectionAmount3","");
                component.set("v.ProjectionAmount4","");
                component.set("v.ProjectionAmount5","");
                component.set("v.nonprojectionValue1","");
                component.set("v.nonprojectionValue2","");
                component.set("v.nonprojectionValue3","");
                component.set("v.nonprojectionValue4","");
                component.set("v.nonprojectionValue5","");
                component.set("v.createdprojectionValue1","");
                component.set("v.createdprojectionValue2","");
                component.set("v.createdprojectionValue3","");
                component.set("v.createdprojectionValue4","");
                component.set("v.createdprojectionValue5","");
                component.set("v.probabilityValue","");
                /*component.set("v.yearValue","");
                component.set("v.monthValue","");
                this.monthValues(component, event,helper);
                this.yearValues(component, event,helper);*/
            }
            else
            {
                helper.showErrorToast(component, event,'Role cannot be fetched for the selected vertical and vertical category.');
            }
      });
      $A.enqueueAction(action);
    },
    verticalProjection: function (component, event, helper) {
        var roleV=component.get("v.selectedRoleValue");
        var horiV=component.get("v.selectedHorizontalValue");
        var vertCat=component.get("v.selectedVerticalCategory");
        var vertV=component.get("v.selectedVerticalValue");
        
        var geoId=component.get("v.selectedGeographyId").Id;
        var actId=component.get("v.selectedAccountId").Id;
        //var amt=component.get("v.ProjectionAmount");
        
        var action = component.get("c.createVerticalAccountProjection");
        action.setParams({
            'selectedVerticalId':vertV,
            'selectedGeographyId':geoId,
            'accId':actId,
            'projAmt1':component.get("v.ProjectionAmount1"),
            'projAmt2':component.get("v.ProjectionAmount2"),
            'projAmt3':component.get("v.ProjectionAmount3"),
            'projAmt4':component.get("v.ProjectionAmount4"),
            'projAmt5':component.get("v.ProjectionAmount5"),
            'nonprojAmt1':component.get("v.nonprojectionValue1"),
            'nonprojAmt2':component.get("v.nonprojectionValue2"),
            'nonprojAmt3':component.get("v.nonprojectionValue3"),
            'nonprojAmt4':component.get("v.nonprojectionValue4"),
            'nonprojAmt5':component.get("v.nonprojectionValue5"),
            'createdAmt1':component.get("v.createdprojectionValue1"),
            'createdAmt2':component.get("v.createdprojectionValue2"),
            'createdAmt3':component.get("v.createdprojectionValue3"),
            'createdAmt4':component.get("v.createdprojectionValue4"),
            'createdAmt5':component.get("v.createdprojectionValue5"),
            'probValue':component.get("v.probabilityValue")
            /*'yearValue':component.get("v.yearValue"),
            'monthValue':component.get("v.monthValue")*/
        })
        action.setCallback(this, function(response) {
            //store state of response
            var state = response.getState();
            if (state === "SUCCESS") {
                helper.showSuccessToast(component, event,'Account Projection created.');

                component.set("v.displaySecondPanel",true);
                component.set("v.displayRole",true);
                component.set("v.displayVertical",true);
                component.set("v.displayGeography",true);
                component.set("v.displayHorizontal",true);
                component.set("v.selectedVerticalValue","");
                component.set("v.selectedRoleValue","");
                component.set("v.selectedHorizontalValue","");
                component.set("v.selectedVerticalCategory","");
                component.set("v.selectedGeographyId","");
                component.set("v.selectedAccountId","");
                component.set("v.ProjectionAmount1","");
                component.set("v.ProjectionAmount2","");
                component.set("v.ProjectionAmount3","");
                component.set("v.ProjectionAmount4","");
                component.set("v.ProjectionAmount5","");
                component.set("v.nonprojectionValue1","");
                component.set("v.nonprojectionValue2","");
                component.set("v.nonprojectionValue3","");
                component.set("v.nonprojectionValue4","");
                component.set("v.nonprojectionValue5","");
                component.set("v.createdprojectionValue1","");
                component.set("v.createdprojectionValue2","");
                component.set("v.createdprojectionValue3","");
                component.set("v.createdprojectionValue4","");
                component.set("v.createdprojectionValue5","");
                component.set("v.probabilityValue","");
                /*component.set("v.yearValue","");
                component.set("v.monthValue","");
                this.monthValues(component, event,helper);
                this.yearValues(component, event,helper);*/
            }
            else
            {
                helper.showErrorToast(component, event,'Role cannot be fetched for the selected vertical.');
            }
        });
        $A.enqueueAction(action);
    },
    getCaseList: function(component) {
        /*component.set('v.mycolumns', [
            //{label: 'Name', fieldName: 'Name', type: 'text'},
            
            {label: 'Name', fieldName: 'linkName1', type: 'url', 
            typeAttributes: {label: { fieldName: 'Name' }, target: '_blank'}},
            
            //{label: 'Account Name', fieldName: 'bccl_Account_Name__c', type: 'text'},
            
         //  {label: 'Account Name', fieldName: 'linkName', type: 'url', 
           // typeAttributes: {label: { fieldName: 'bccl_Account_Name__c' }, target: '_blank'}},
            
           {label: 'Created By', fieldName: 'Owner_Name__c', type: 'text'},
          
        	
            //{label: 'Role Name', fieldName: 'bccl_Role_Name__c', type: 'text'},
            {label: 'Vertical', fieldName: 'bccl_Vertical_Name__c', type: 'text'},
            {label: 'MM/YY', fieldName: 'bccl_Projection_Month_Year__c', type: 'text'},
            {label: 'Print ( In lacs)', fieldName: 'bccl_Projection_Week_1__c', type: 'number', editable : 'true'},
            {label: 'Non-Print ( In lacs)', fieldName: 'bccl_Non_Print_1__c', type: 'number', editable : 'true'},
            {label: 'Created ( In lacs)', fieldName: 'bccl_Created_1__c', type: 'number', editable : 'true'},
             {label: 'Total( In lacs)', fieldName: 'Total__c', type: 'Integer', editable : 'false'},
            {label: 'Probability', fieldName: 'bccl_Probability__c', type: 'text'},
            {label: 'Sales Office', fieldName: 'Sales_Office_Name__c', type: 'text'}
            //{label: 'Region', fieldName: 'Region__c', type: 'text'},
            //{label: 'Director', fieldName: 'Director__c', type: 'text'}
            //{label: 'Description', fieldName: 'Description__c', type: 'textarea'}
          ]);*/
        
        var action = component.get("c.getAccountProjection");
        action.setParams({
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            var totalPrtAmt=0;
            var totalNonPrtAmt=0;
            var totalCrtAmt=0;
            if (state === "SUCCESS") {
                var records =response.getReturnValue();
                //console.log('records get' + JSON.stringify(records));  
                for(var i = 0; i < records.length; i++){
                    var PrtAmt = 0;
                    var nonPrtAmt = 0;
                    var CrtAmt = 0;
                    
                    /*if(records[i].bccl_Non_Print_1__c=== undefined || records[i].bccl_Projection_Week_1__c=== undefined || records[i].bccl_Created_1__c=== undefined)
                    {
                    }
                    else{
                        PrtAmt = records[i].bccl_Projection_Week_1__c;
                        nonPrtAmt = records[i].bccl_Non_Print_1__c;
                        CrtAmt = records[i].bccl_Created_1__c;
                    }*/
                    
                    if(records[i].bccl_Non_Print_1__c!= undefined)
                        nonPrtAmt = records[i].bccl_Non_Print_1__c;
                    
                    if(records[i].bccl_Projection_Week_1__c!= undefined)
                    {
                        PrtAmt = records[i].bccl_Projection_Week_1__c;
                    }
                    
                    if(records[i].bccl_Created_1__c!= undefined)
                    {
                        CrtAmt = records[i].bccl_Created_1__c;
                    }
                    
                    
                        
                    totalPrtAmt += PrtAmt;
                    totalNonPrtAmt += nonPrtAmt;
                    totalCrtAmt += CrtAmt;
                    
                    }
                component.set("v.totalPrint", totalPrtAmt);
                component.set("v.totalNonPrint", totalNonPrtAmt);
                component.set("v.totalCreated", totalCrtAmt);
                component.set("v.totalAmount", totalPrtAmt+totalNonPrtAmt+totalCrtAmt);
                
                records.forEach(function(record){
                    record.linkName1='/'+record.Id;
                    record.linkName ='/'+record.bccl_Account__c;
                                      
                });
              component.set("v.projectionList", records);
              component.set("v.projDataList", records);
            }
        });
        $A.enqueueAction(action);
    },

    checkAdminLogin: function(component) {
        var action = component.get('c.adminLogin');
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state == 'SUCCESS') {
                //console.log('admin login');
                component.set('v.adminLogin', response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
    },
    
    getfilter :function(component, helper, event) {
        var roleV=component.get("v.selectedRoleValue");
        var abc=component.get("v.selectedAccountId")!= null ?
            component.get("v.selectedAccountId").Id : undefined;
        var verId=component.find("vertical").get("v.value")!= undefined ?
            component.find("vertical").get("v.value") : undefined;
        
       
        
        
        var sub= component.get("v.projDataList");
        var filterdata = [];
        for(let i=0; i<sub.length; i++)
        {
                    
        if(sub[i].bccl_Role__c==roleV)
        {
            if( sub[i].bccl_Account__c==abc)
            {
                
            if(sub[i].bccl_Vertical__c==verId)
            {
                this.probfetch(component);
            }
                else{
                this.accountfetch(component);    
                }
           
                
            }
            
            
            else{
                 //filterdata.push(sub[i]);
                this.rolefetch(component);

            }
            
                
        }
        }
        
    },
    
    rolefetch: function(component) {
       var roleV=component.get("v.selectedRoleValue");
        
        var sub= component.get("v.projDataList");
        var filterdata = [];
        for(let i=0; i<sub.length; i++)
        {
            if(sub[i].bccl_Role__c==roleV)
            { 
                filterdata.push(sub[i]);
            }
         
        }
        
        component.set("v.sub", filterdata);
        component.set("v.projectionList",filterdata);
        var tom = component.get("v.sub");
        //console.log('tom----' +JSON.stringify(tom)); 
    },
    
    accountfetch: function(component) {
       var roleV=component.get("v.selectedRoleValue");
        var abc=component.get("v.selectedAccountId")!= null ?
            component.get("v.selectedAccountId").Id : undefined;
        
        
        var sub= component.get("v.projDataList");
        var filterdata = [];
        for(let i=0; i<sub.length; i++)
        {
            if(sub[i].bccl_Role__c==roleV)
            {
            if( sub[i].bccl_Account__c==abc)
            {
                
                filterdata.push(sub[i]);
            }
                }
         
        }
        
        component.set("v.sub", filterdata);
        component.set("v.projectionList",filterdata);
        var tom = component.get("v.sub");
        
    },
    
    probfetch: function(component) {
       var roleV=component.get("v.selectedRoleValue");
        var abc=component.get("v.selectedAccountId")!= null ?
            component.get("v.selectedAccountId").Id : undefined;
        var verId=component.find("verId1").get("v.value")!= undefined ?
            component.find("verId1").get("v.value") : undefined;
        
        
        var sub= component.get("v.projDataList");
        var filterdata = [];
        for(let i=0; i<sub.length; i++)
        {
            if(sub[i].bccl_Role__c==roleV)
            {
            if( sub[i].bccl_Account__c==abc)
            {
                
            if( sub[i].bccl_Vertical__c==verId)
            {
                filterdata.push(sub[i]);
            }
            }
            }
         
        }
        component.set("v.sub", filterdata);
        component.set("v.projectionList",filterdata);
        var tom = component.get("v.sub");
    },
   
    createVerticalOpp: function(component, event, errorMessage) {
        var a;
        var b = component.get("v.closeDate");
        var c = component.get("v.Description");
        var records = component.get("v.selectedCases");
        var act=[];
        var act1=[];
        for ( var i = 0; i < records.length; i++ ) {
            a=records[i].Id;
            act.push(records[i].Id);
            act1.push(records[i]);
        }
        if(b==undefined){
            this.showErrorToast(component, event,'Proposed close date is mandatory for Opportunity.');
            let button = component.find('disablebuttonid');
            button.set('v.disabled',false);
        }
        else if(c==undefined){
            this.showErrorToast(component, event,'Description is mandatory for Opportunity.');
            let button = component.find('disablebuttonid');
            button.set('v.disabled',false);
        }
        else
        {
            let button = component.find('disablebuttonid');
            button.set('v.disabled',true);
            
            var action = component.get("c.createVerticalOpportunity");
            action.setParams({
                'projId':a,
                'proposalDate':b,
                'description' :c
            })
            action.setCallback(this, function(response) {
                //store state of response
                var state = response.getState();
                var records =response.getReturnValue();
                if (state === "SUCCESS") {
                    this.showSuccessToast(component, event,'Opportunity created.');
                    component.set("v.isModalOpen", false);
                    component.set("v.closeDate","");
                    component.set("v.projectionValue5","");
                    //window.open(records,'_top');
                    
                   var navEvt = $A.get("e.force:navigateToSObject");
    navEvt.setParams({
      "recordId": records,
      "slideDevName": "related"
    });
    navEvt.fire();
                }
                else
                {
                    this.showErrorToast(component, event,'Opportunity cannot be created.');
                }
            });
            $A.enqueueAction(action);
        }
    },

    createHorizontalOpp: function(component, event, errorMessage) {
        var a;
        var b = component.get("v.closeDate");
        var c = component.get("v.Description");
        var records = component.get("v.selectedCases");
        var act=[];
        var act1=[];
        for ( var i = 0; i < records.length; i++ ) {
            a=records[i].Id;
            act.push(records[i].Id);
            act1.push(records[i]);
        }
        
        var vertCat=component.get("v.selectedVerticalCategory");
        var vertV=component.get("v.selectedVerticalValue");
        	
        if(b==undefined){
            this.showErrorToast(component, event,'Proposed close date is mandatory for Opportunity.');
            let button = component.find('disablebuttonid');
            button.set('v.disabled',false);
        }
        else
        {

            var action = component.get("c.createHorizontalOpportunity");
            action.setParams({
                'projId':a,
                'vertID':vertV,
                'VCatId':vertCat,
                'proposalDate':b,
                'description' :c
            })
            action.setCallback(this, function(response) {
                //store state of response
                var state = response.getState();
                var records = response.getReturnValue();
                if (state === "SUCCESS") {
                    if(response.getReturnValue()!=null)
                    {
                        this.showSuccessToast(component, event,'Opportunity created.');
                        component.set("v.isModalOpen", false);
                        component.set("v.selectedVerticalValue","");
                        component.set("v.selectedVerticalCategory","");
                        component.set("v.closeDate","");
                        component.set("v.Description","");
                        component.set("v.isHorizModal", false);
                        component.set("v.projectionValue5","");
                        var navEvt = $A.get("e.force:navigateToSObject");
    navEvt.setParams({
      "recordId": records,
      "slideDevName": "related"
    });
    navEvt.fire();
                    }
                    else
                    {
                        this.showErrorToast(component, event,'Selected vertical is not present on Account. Please select appropriate vertical.');
                    }
                }
                else
                {
                    this.showErrorToast(component, event,'Opportunity cannot be created.');
                }
            });
            $A.enqueueAction(action);
        }
    },

    showErrorToast : function(component, event, errorMessage) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : 'Error Message',
            message: errorMessage,
            key: 'info_alt',
            type: 'error',
            mode: 'dismissible'
        });
        toastEvent.fire();
    },
    // Show Success Toast
    showSuccessToast : function(component, event, successMessage) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : 'Success Message',
            message:successMessage, 
            key: 'info_alt',
            type: 'success',
            mode: 'dismissible'
        });
        toastEvent.fire();
    },
    showSpinner: function (component, event, helper) {
        var spinner = component.find("mySpinner");
        $A.util.addClass(spinner, "slds-show");
        $A.util.removeClass(spinner, "slds-hide");
    },
     
    hideSpinner: function (component, event) {
        var spinner = component.find("mySpinner");
        $A.util.addClass(spinner, "slds-hide");
        $A.util.removeClass(spinner, "slds-show");
    }
})
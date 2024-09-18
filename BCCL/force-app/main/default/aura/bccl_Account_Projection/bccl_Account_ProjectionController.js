({
    doInit : function(component, event, helper) {

        helper.verticalValues(component, event, helper);
        helper.horizontalValues(component, event, helper);
        helper.roleValues(component, event, helper);
        helper.salesOfficeValues(component, event, helper);
        helper.viewScreen(component, event, helper);
        helper.getCaseList(component);
        helper.checkAdminLogin(component);
        helper.cMonthValues(component, event, helper);
        //helper.yearValues(component, event, helper);
    },
    filter: function(component, event, helper) {
        var data = component.get("v.projDataList"); //component.get("v.data"),
        var term = component.get("v.filter");
         
            console.log('data---->' +data);
        var results = data;
        var regex;
        var totalPrtAmt=0;
            var totalNonPrtAmt=0;
            var totalCrtAmt=0;
        
        try {
            regex = new RegExp(term, "i");
            // filter checks each row, constructs new array where function returns true
            results = data.filter(row=>regex.test(row.Owner_Name__c) || regex.test(row.bccl_Probability__c) || regex.test(row.Name) || regex.test(row.bccl_Projection_Month_Year__c) || regex.test(row.bccl_Vertical_Name__c) || regex.test(row.Sales_Office_Name__c) || regex.test(row.bccl_Projection_Week_1__c) || regex.test(row.bccl_Non_Print_1__c) || regex.test(row.bccl_Created_1__c) || regex.test(row.Total__c)); // || regex.test(row.age.toString())
           
        } catch(e) {
            // invalid regex, use full list
        }
        
        for(var i = 0; i < results.length; i++){
                    var PrtAmt = 0;
                    var nonPrtAmt = 0;
                    var CrtAmt = 0;
                    //if(results[i].bccl_Non_Print_1__c=== undefined || results[i].bccl_Projection_Week_1__c=== undefined || results[i].bccl_Created_1__c=== undefined)
                    //{
                   // }
                  //  else{
                        PrtAmt =  results[i].bccl_Projection_Week_1__c=== undefined ? 0 : results[i].bccl_Projection_Week_1__c;
                        nonPrtAmt = results[i].bccl_Non_Print_1__c=== undefined ? 0 : results[i].bccl_Non_Print_1__c;
                        CrtAmt = results[i].bccl_Created_1__c=== undefined ? 0 : results[i].bccl_Created_1__c;
                   // }
                    totalPrtAmt += PrtAmt;
                    totalNonPrtAmt += nonPrtAmt;
                    totalCrtAmt += CrtAmt;
                    
                    }
                component.set("v.totalPrint", totalPrtAmt);
                component.set("v.totalNonPrint", totalNonPrtAmt);
                component.set("v.totalCreated", totalCrtAmt);
                component.set("v.totalAmount", totalPrtAmt+totalNonPrtAmt+totalCrtAmt);
                
        
        
        component.set("v.projectionList", results);
        //component.set("v.filteredData", results);
    },
    onMonthChange : function(component, event, helper) {
        var categoryValue = component.get("v.selectedMnthValue");
    },

    onCategoryChange : function(component, event, helper) {
        var categoryValue = component.get("v.selectedVerticalValue");
        //alert(categoryValue);
        var action = component.get("c.getVerticalCategoryList");
        action.setParams({
            'verticalId':categoryValue
        })
        action.setCallback(this, function(response) {
            //store state of response
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.verticalCategoryList",response.getReturnValue());
                var abc=response.getReturnValue();
                if(abc!=''){
                    component.set("v.showSubCategoryList",true);
                }
                else
                {
                    component.set("v.showSubCategoryList",false);
                }
            }
            else
            {
                alert('Value cannot be fetched.');
            }
      });
      $A.enqueueAction(action);

        var a=component.get("v.selectedVerticalValue");
        if(a!='')
        {
            component.set("v.displayHorizontal",false);
            component.set("v.displayRole",false);
        }
        else
        {
            component.set("v.displayHorizontal",true);
            component.set("v.displayRole",true);
            component.set("v.displayVertical",true);
            component.set("v.displayGeography",true);
        } 
    },

    onSubCategoryChange: function(component, event, helper) {

        var a=component.get("v.selectedVerticalCategory");
        if(a!='')
        {
            component.set("v.displayHorizontal",false);
            component.set("v.displayRole",false);
        }
        else
        {
            component.set("v.displayHorizontal",false);
            component.set("v.displayRole",false);
            component.set("v.showSubCategoryList",true);
            component.set("v.displayVertical",true);
            component.set("v.displayGeography",true);
        }
    },

    onHorizontalChange: function(component, event, helper) {
        var a=component.get("v.selectedHorizontalValue");
        if(a!='')
        {
            component.set("v.displayRole",false);
            component.set("v.displayVertical",false);
            component.set("v.displaySecondPanel",true);
        }
        else
        {
            component.set("v.displaySecondPanel",true);
            component.set("v.displayRole",true);
            component.set("v.displayVertical",true);
            component.set("v.displayGeography",true);
        }
    },

    onRoleChange: function(component, event, helper) {
        var a=component.get("v.selectedRoleValue");
        
        var evt = $A.get("e.c:RoleProfileResult");
            evt.setParams({ "Pass_Result": a});
            evt.fire();
            
        
        var action =  component.get("c.getSalesOfficeList");
        action.setParams({
            'roleId':a
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
        
        var action1 =  component.get("c.getOfficeType");
        action1.setParams({
            'roleId':a
        })
        action1.setCallback(this,function(response){
            var state =  response.getState();
            var res = response.getReturnValue();
            //var n = res.includes("world");
            if(res.includes("STM") || res.includes("SOVGH") || res.includes("SOH") || res.includes("SOHGH") || res.includes("Jr. KAM")){
                component.set("v.displaySofficePanel",false); 
            }
            else{
                component.set("v.displaySofficePanel",true);
            }
            
        });
        $A.enqueueAction(action1);
        
        /*var action2 =  component.get("c.getRoleDetails");
        action2.setParams({
            'roleId':a
        })
        action2.setCallback(this,function(response){
            var state =  response.getState();
            var res = response.getReturnValue();
            console.log(res);
            var evt = $A.get("e.c:RoleProfileResult");
            evt.setParams({ "Pass_Result": res});
            evt.fire();
            });
            $A.enqueueAction(action2);
        */
        
        if(a!='')
        {
            component.set("v.displaySecondPanel",false);
        }
        else
        {
            component.set("v.displaySecondPanel",true);
            component.set("v.displayVertical",true);
        }
    },
    
    
    
    //8/02
    //
    //
    filterProj: function (component, event, helper) {
    helper.getfilter(component, event, helper);
        
    },
    
    filterProjection: function (component, event, helper) {
        helper.showSpinner(component, event, helper);
        var roleV=component.get("v.selectedRoleValue");
        var action = component.get("c.getAccountProjection");
        action.setParams({
            'roleID':roleV
            
        })
        action.setCallback(this, function(response){
            var state = response.getState();
            var totalPrtAmt=0;
            var totalNonPrtAmt=0;
            var totalCrtAmt=0;
            if (state === "SUCCESS") {
                var records =response.getReturnValue();
                  
                for(var i = 0; i < records.length; i++){
                    var PrtAmt = 0;
                    var nonPrtAmt = 0;
                    var CrtAmt = 0;
                    
                    PrtAmt =  records[i].bccl_Projection_Week_1__c=== undefined ? 0 : records[i].bccl_Projection_Week_1__c;
                    nonPrtAmt = records[i].bccl_Non_Print_1__c=== undefined ? 0 : records[i].bccl_Non_Print_1__c;
                    CrtAmt = records[i].bccl_Created_1__c=== undefined ? 0 : records[i].bccl_Created_1__c;
                    
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
              component.set("v.isViewPrjModel", false);
            }
        });
        helper.hideSpinner(component, event);
      $A.enqueueAction(action);
        },
         //   8/02 END

    saveActProjection: function(component, event, helper) {
        var roleV=component.get("v.selectedRoleValue")!= undefined ?
            component.get("v.selectedRoleValue") : undefined;
        /*var horiV=component.get("v.selectedHorizontalValue")!= undefined ?
            component.get("v.selectedHorizontalValue") : undefined;
        var vertCat=component.get("v.selectedVerticalCategory")!= undefined ?
            component.get("v.selectedVerticalCategory") : undefined;
        var vertV=component.get("v.selectedVerticalValue")!= undefined ?
            component.get("v.selectedVerticalValue") : undefined;

        var geoId=component.get("v.selectedGeographyId")!= undefined ?
            component.get("v.selectedGeographyId").Id : undefined;*/
        var actId=component.get("v.selectedAccountId")!= undefined ?
            component.get("v.selectedAccountId").Id : undefined;

        var mth=component.find("makeId").get("v.value");
        var prob=component.find("probId").get("v.value");

        /*var prob=component.get("v.probabilityValue"); 
        var pointNum = Number(prob);*/

        /*var selectedMonth = component.find("monthID");
        var mValue=selectedMonth.get("v.value");

        var selectedYear = component.find("yearID");
        var yValue=selectedYear.get("v.value");*/

        if(actId==undefined)
        {
            helper.showErrorToast(component, event,'Please select a Account before moving forward.');
        }
        else if(roleV=='')
        {
            helper.showErrorToast(component, event,'Please select a Role before moving forward.');
        }
        else if(prob=='--None--')
        {
            helper.showErrorToast(component, event,'Please select a probability before moving forward.');
        }
        /*else if(roleV=='' && (horiV!='' || vertV!='') && geoId==undefined)
        {
            helper.showErrorToast(component, event,'Please either select a Sales Office before moving forward.');
        }
        else if(pointNum!='' && (pointNum>100 || pointNum<0))
        {
            helper.showErrorToast(component, event,'Probability %age cannot be greater than 100 or negative.');
        }*/
        else
        {
        
            if(roleV!='')
            {
                helper.roleProjection(component, event, helper);
            }
            /*else if(horiV!='')
            {
                helper.horizontalProjection(component, event, helper);   
            }
            else if(vertCat!='' && vertCat!=undefined)
            {
                helper.verticalCatProjection(component, event, helper);
            }
            else if(vertV!='')
            {
                helper.verticalProjection(component, event, helper);
            }*/
            helper.getCaseList(component);
        }
    },
    
    newProjectionwithReason :function(component, event, helper){
        
        var selectedRows = event.getParam('selectedRows'); 
        var setRows = [];
        var a=component.get("v.projectionValue5");
        var reason=component.get("v.Reason");
        var printProj=component.get("v.printProjAmt");
        var nonprintProj=component.get("v.nonprintProjAmt");
        var createdProj=component.get("v.createdProjAmt");
        var prob=component.get("v.probR");
        


        //var draftValues = event.getParam('draftValues');
        /*for ( var i = 0; i < draftValues.length; i++ ) {
                printProj=draftValues[i].bccl_Projection_Week_1__c;
                nonprintProj=draftValues[i].bccl_Non_Print_1__c;
                createdProj=draftValues[i].bccl_Created_1__c;
                prob=draftValues[i].bccl_Probability__c;
                setRows.push(draftValues[i]);
            }*/

            var action = component.get("c.updateProjectionNew");
            action.setParams({
                'projId':a,
                'projAmt1':printProj,
                'projAmt2':nonprintProj,
                'projAmt3':createdProj,
                'probValue':prob,
                'ProReason':reason
            })
            action.setCallback(this, function(response) {
                var state = response.getState();
                var records =response.getReturnValue();
               // if (state === "SUCCESS") {
                    if(records ==true) {
                     helper.showSuccessToast(component, event,'Record updated successfully.');
                     helper.getCaseList(component);
                     $A.get('e.force:refreshView').fire();
                }
                    else { 
                        helper.showErrorToast(component, event,'Amounts are recorded in lacs, can not be greater than 999.');
                         $A.get('e.force:refreshView').fire();
                    }
                //    }
                //else
                //{
                //    helper.showErrorToast(component, event,'Record could not be updated.');
                //}
            });
            $A.enqueueAction(action);
            component.set("v.projectionValue5",""); 
    },

    updateProjectionNEWVALUE  : function(component, event, helper) {
        var selectedRows = event.getParam('selectedRows'); 
        var setRows = [];
        var a=component.get("v.projectionValue5");
        var reason=component.get("v.Reason");
        var printProj;
        var nonprintProj;
        var createdProj;
        var prob;
        


        var draftValues = event.getParam('draftValues');
        //prob=draftValues[0].bccl_Probability__c;    
        
        if(a==undefined)
        {
            helper.showErrorToast(component, event,'Please select the record that you want to edit.');
        }
        else if(draftValues.length>1)
        {
            helper.showErrorToast(component, event,'Please edit only one record at a time.');
        }
        
        
        /*else if(prob!=undefined && (sprob!='HIGH'|| sprob!='LOW' || sprob!='MEDIUM'))
        {
            helper.showErrorToast(component, event,'Probability can either be High , Medium or Low');
        }*/
        else
        {
            
            var days;
        var Reason;
        var action1 = component.get("c.getOldProjection");
            action1.setParams({
                'projId':a,
            })
            action1.setCallback(this, function(response) {
                var state = response.getState();
                var records =response.getReturnValue();
                Reason = records.Reason__c;
                var CDate = new Date(records.CreatedDate);
                var Tdate = new Date();
                days = Math.ceil((Tdate-CDate)/8.64e7);
                var CurrentDateMonth=Tdate.toLocaleString('default', { month: 'short' });
                var CurrentWeek;
                
             if(records.bccl_Month__c != CurrentDateMonth){
                
                CurrentWeek='Week - 1';
                
            }
            else
            {
             //moValue=System.Today().month();
                
            if(Tdate.getDate()<=7)
            CurrentWeek='Week - 1';
            
            if(Tdate.getDate()>7 && Tdate.getDate()<15)
            CurrentWeek='Week - 2';
            
            if(Tdate.getDate()>=15 && Tdate.getDate()<22)
            CurrentWeek='Week - 3';
            
            if(Tdate.getDate()>=22 && Tdate.getDate()<29)
            CurrentWeek='Week - 4';
            
            if(Tdate.getDate()>=29)
            CurrentWeek='Week - 5';
            }
                
           if(records.Active__c== false)
           {
               helper.showErrorToast(component, event,'Record is locked, Not available for editing.');
               
           }
         
        else if(CurrentWeek != records.Week__c) //days>7
        {
            component.set("v.isReasonModalOpen", true);
            component.set("v.printProjAmt", draftValues[0].bccl_Projection_Week_1__c);
            component.set("v.nonprintProjAmt", draftValues[0].bccl_Non_Print_1__c);
            component.set("v.createdProjAmt", draftValues[0].bccl_Created_1__c);
            component.set("v.probR", draftValues[0].bccl_Probability__c);
            if(Reason==undefined)
            {
               return false;
            }
            }
            else
            {
               
            for ( var i = 0; i < draftValues.length; i++ ) {
                printProj=draftValues[i].bccl_Projection_Week_1__c;
                nonprintProj=draftValues[i].bccl_Non_Print_1__c;
                createdProj=draftValues[i].bccl_Created_1__c;
                prob=draftValues[i].bccl_Probability__c;
                setRows.push(draftValues[i]);
            }

            var action = component.get("c.updateProjectionNew");
            action.setParams({
                'projId':a,
                'projAmt1':printProj,
                'projAmt2':nonprintProj,
                'projAmt3':createdProj,
                'probValue':prob,
                'ProReason':reason
            })
            action.setCallback(this, function(response) {
                var state = response.getState();
                var records =response.getReturnValue();
               // if (state === "SUCCESS") {
                    if(records ==true) {
                     helper.showSuccessToast(component, event,'Record updated successfully.');
                     helper.getCaseList(component);
                     $A.get('e.force:refreshView').fire();
                }
                    else { 
                        helper.showErrorToast(component, event,'Amounts are recorded in lacs, can not be greater than 999.');
                         $A.get('e.force:refreshView').fire();
                    }
                //    }
                //else
                //{
                //    helper.showErrorToast(component, event,'Record could not be updated.');
                //}
            });
            $A.enqueueAction(action);
            //component.set("v.projectionValue5",""); 
            }
        
        });
            $A.enqueueAction(action1);
      
        }
        /*var draftValues = event.getParam('draftValues');
        var action = component.get("c.updateAccount");
        action.setParams({"acc" : draftValues});
        action.setCallback(this, function(response) {
            var state = response.getState();
            alert(state);
            $A.get('e.force:refreshView').fire();
            
        });
        $A.enqueueAction(action);*/
    },
    
    
    handleSelect : function(component, event, helper) {
        var selectedRows = event.getParam('selectedRows'); 
        var setRows = [];
        var a;

        if(selectedRows.length>1)
        {
            helper.showErrorToast(component, event,'Please select only one record at a time.');
        }
        else if(selectedRows.length==0)
        {
            helper.showErrorToast(component, event,'Please select at least one record.');
        }
        else
        {
            for ( var i = 0; i < selectedRows.length; i++ ) {
                a=selectedRows[i].Id;
                setRows.push(selectedRows[i]);
            }
            component.set("v.selectedCases", setRows);
            component.set("v.projectionValue5",a);

            var action = component.get("c.fecthValidationForOpp");
            action.setParams({
                'projId':a
            })
            action.setCallback(this, function(response) {
                //store state of response
                var state = response.getState();
                if (state === "SUCCESS") {
                    component.set("v.proj",response.getReturnValue());
                    var b=component.get("v.proj").bccl_Horizontal__c;
                    if(b!=null && b!=undefined){
                        component.set("v.isHorizModal", true);
                    }

                    component.set("v.p1",component.get("v.proj").bccl_Projection_Week_1__c);
                //component.set("v.p2",component.get("v.proj").bccl_Projection_Week_2__c);
                //component.set("v.p3",component.get("v.proj").bccl_Projection_Week_3__c);
                //component.set("v.p4",component.get("v.proj").bccl_Projection_Week_4__c);
                //component.set("v.p5",component.get("v.proj").bccl_Projection_Week_5__c);

                    component.set("v.np1",component.get("v.proj").bccl_Non_Print_1__c);
                //component.set("v.np2",component.get("v.proj").bccl_Non_Print_2__c);
                //component.set("v.np3",component.get("v.proj").bccl_Non_Print_3__c);
                //component.set("v.np4",component.get("v.proj").bccl_Non_Print_4__c);
                //component.set("v.np5",component.get("v.proj").bccl_Non_Print_5__c);

                    component.set("v.cp1",component.get("v.proj").bccl_Created_1__c);
                //component.set("v.cp2",component.get("v.proj").bccl_Created_2__c);
                //component.set("v.cp3",component.get("v.proj").bccl_Created_3__c);
                //component.set("v.cp4",component.get("v.proj").bccl_Created_4__c);
                //component.set("v.cp5",component.get("v.proj").bccl_Created_5__c);

                    component.set("v.PV1",component.get("v.proj").bccl_Probability__c);
                }
                else
                {
                    helper.showErrorToast(component, event,'Something went wrong, contact your administrator.');
                }
            });
            $A.enqueueAction(action);
            //component.set("v.projectionValue5","");
            //component.set("v.selectedRows","");
        }
    },
    
    createOpp: function(component, event, helper) {
        var a;
        var b = component.get("v.closeDate");
        var c=component.get("v.proj").bccl_Horizontal__c;
        var records = component.get("v.selectedCases");
        var act=[];
        var act1=[];
        for ( var i = 0; i < records.length; i++ ) {
            a=records[i].Id;
            act.push(records[i].Id);
            act1.push(records[i]);
        }

        if(records.length==0)
        {
            helper.showErrorToast(component, event,'Please select at least one record.');
        }
        else
        {
            if(c!=null && c!=undefined)
            {
                helper.createHorizontalOpp(component, event, helper);
            }
            else
            {
                helper.createVerticalOpp(component, event, helper);   
            }
        }
        component.set("v.projectionValue5","");
        
        //let button = component.find('disablebuttonid');
        //button.set('v.disabled',true);
    },

    onSaveCall : function( component, event, helper ) {
        var records = component.get("v.selectedCases");
        var a;
        var act=[];
        var act1=[];
        for ( var i = 0; i < records.length; i++ ) {
            a=records[i].Id;
            act.push(records[i].Id);
            act1.push(records[i]);
        }

        var prob=component.get("v.PV1"); 
        var pointNum = Number(prob);
        
        if(records.length==0)
        {
            helper.showErrorToast(component, event,'Please select at least one record.');
        }
        else
        {

            var action = component.get("c.updateProjection");
            action.setParams({
                'projId':a,
                'projAmt1':component.get("v.p1"),
                'projAmt2':component.get("v.p2"),
                'projAmt3':component.get("v.p3"),
                'projAmt4':component.get("v.p4"),
                'projAmt5':component.get("v.p5"),
                'nonprojAmt1':component.get("v.np1"),
                'nonprojAmt2':component.get("v.np2"),
                'nonprojAmt3':component.get("v.np3"),
                'nonprojAmt4':component.get("v.np4"),
                'nonprojAmt5':component.get("v.np5"),
                'createdAmt1':component.get("v.cp1"),
                'createdAmt2':component.get("v.cp2"),
                'createdAmt3':component.get("v.cp3"),
                'createdAmt4':component.get("v.cp4"),
                'createdAmt5':component.get("v.cp5"),
                'probValue':component.get("v.PV1")
            })
            action.setCallback(this, function(response) {
                //store state of response
                var state = response.getState();
                if (state === "SUCCESS") {
                    helper.showSuccessToast(component, event,'Account Projection updated.');
                    component.set("v.isEditModalOpen", false);
                    component.set("v.p1","");
                    component.set("v.p2","");
                    component.set("v.p3","");
                    component.set("v.p4","");
                    component.set("v.p5","");
                    component.set("v.np1","");
                    component.set("v.np2","");
                    component.set("v.np3","");
                    component.set("v.np4","");
                    component.set("v.np5","");
                    component.set("v.cp1","");
                    component.set("v.cp2","");
                    component.set("v.cp3","");
                    component.set("v.cp4","");
                    component.set("v.cp5","");
                    component.set("v.PV1","");
                }
                else
                {
                    helper.showErrorToast(component, event,'Account Projection cannot be updated.');
                }
            });
            $A.enqueueAction(action);
            helper.getCaseList(component);
        }
    },
    
    openViewPrjModel: function(component, event, helper) {
        // Set isModalOpen attribute to false  
        component.set("v.isViewPrjModel", true);
    },

    openModel: function(component, event, helper) {
        // Set isModalOpen attribute to true
        var records = component.get("v.selectedCases");
        var a;
        var act=[];
        var act1=[];
        for ( var i = 0; i < records.length; i++ ) {
            a=records[i].Id;
            act.push(records[i].Id);
            act1.push(records[i]);
        }
        
        if(records.length==0)
        {
            helper.showErrorToast(component, event,'Please select at least one record.');
        }
        else
        {
            component.set("v.isModalOpen", true);
        }
    },
  
    closeModel: function(component, event, helper) {
        // Set isModalOpen attribute to false  
        component.set("v.isModalOpen", false);
        component.set("v.isReasonModalOpen", false);
        component.set("v.isViewPrjModel", false);
    },
    
    openEditModel: function(component, event, helper) {
        // Set isModalOpen attribute to true
        var records = component.get("v.selectedCases");
        var a;
        var act=[];
        var act1=[];
        for ( var i = 0; i < records.length; i++ ) {
            a=records[i].Id;
            act.push(records[i].Id);
            act1.push(records[i]);
        }
        
        if(records.length==0)
        {
            helper.showErrorToast(component, event,'Please select at least one record.');
        }
        else
        {
            component.set("v.isEditModalOpen", true);
        }
    },

    /*onMonthPicklistChange:function(component, event, helper) {
        var selectedIndustry = component.find("monthID");
        var monthValue=selectedIndustry.get("v.value");
        component.set("v.monthValue", monthValue);
    },

    onYearPicklistChange:function(component, event, helper) {
        var selectedIndustry = component.find("yearID");
        var yearValue=selectedIndustry.get("v.value");
        component.set("v.yearValue", yearValue);
    },*/
    
    closeEditModel: function(component, event, helper) {
        // Set isModalOpen attribute to false  
        component.set("v.isEditModalOpen", false);
    },
  
    submitDetails: function(component, event, helper) {
        // Set isModalOpen attribute to false
        //Add your code to call apex method or do some processing
        component.set("v.isModalOpen", false);
    },

    showSpinner: function(component, event, helper) {
        // make Spinner attribute true for display loading spinner 
        component.set("v.Spinner", true); 
    },
    
    // this function automatic call by aura:doneWaiting event 
    hideSpinner : function(component,event,helper){
        // make Spinner attribute to false for hide loading spinner    
        component.set("v.Spinner", false);
        
    }
})
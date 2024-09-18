({
    getReport : function(component, event, helper) {
        //hide report and show spinner while we process
        //debugger;
        var loadingSpinner = component.find('loading');
        $A.util.removeClass(loadingSpinner, 'slds-hide');
        var reportContainer = component.find('report');
        $A.util.addClass(reportContainer, 'slds-hide');
        var reportError = component.find('report-error');
        $A.util.addClass(reportError, 'slds-hide');

        //get report data from Apex controller using report ID provided
        var action = component.get('c.getReportMetadata');
        action.setParams({ 
            reportId: component.get("v.reportIdAttribute")
        });

        //handle response from Apex controller
        action.setCallback(this, function(response){
            // transform into JSON object
            var returnValue = JSON.parse(response.getReturnValue());
            var groupingLabels = {};
            
            if( returnValue && returnValue.reportExtendedMetadata ){
                // categorize groupings into levels so we can access them as we go down grouping level
                var columnInfo = returnValue.reportExtendedMetadata.groupingColumnInfo;
                for( var property in columnInfo ){
                    if( columnInfo.hasOwnProperty(property) ){
                        var level = columnInfo[property].groupingLevel;
                        var label = columnInfo[property].label;
                        groupingLabels[level] = label;
                    }
                }
                // set lightning attributes so we have access to variables in the view
                component.set("v.groupingLevelToLabel", groupingLabels)
                component.set("v.reportData", returnValue);
                component.set("v.groupingKey", returnValue.groupingsDown.groupings.key);
                component.set("v.factMap", returnValue.factMap);
                var Factmp = component.get("v.factMap");
                var grpk = component.get("v.groupingKey");
                console.log("Factmp" +Factmp);
                console.log("grpk" +returnValue.groupingsDown.groupings.Key);
                
                //set column headers, this assumes that they are returned in order
                var tableHeaders = [];
                var GroupingKeyList = [];
                var listAggregatesColumn1 = [];
                for(var i = 0; i < returnValue.groupingsDown.groupings.length; i++) {
                    var singleGroupingKey = returnValue.groupingsDown.groupings[i].key;
                    GroupingKeyList.push(singleGroupingKey);
                }
                GroupingKeyList.push("T");
                console.log("GroupingKeyList" +GroupingKeyList);
                
                
                if(Factmp)
                {
                    for(var i = 0; groupingKey.length; i++)
                    {
                       // for(var j = 0; Factmp[groupingKey[i]+"!T"].aggregates.length; j++)
                       // {
                    var aggregatesColumn1 = Factmp[groupingKey[i]+"!T"].aggregates[0].value;
                    listAggregatesColumn1.puch(aggregatesColumn1);
                    var aggregatesColumn2 = Factmp[groupingKey[i]+"!T"].aggregates[1].value;
                    listAggregatesColumn2.puch(aggregatesColumn2);
                    var aggregatesColumn3 = Factmp[groupingKey[i]+"!T"].aggregates[2].value;
                    listAggregatesColumn3.puch(aggregatesColumn3);
                    var aggregatesColumn4 = Factmp[groupingKey[i]+"!T"].aggregates[3].value;
                    listAggregatesColumn4.puch(aggregatesColumn4);
                    var aggregatesColumn5 = Factmp[groupingKey[i]+"!T"].aggregates[4].value;
                    listAggregatesColumn5.puch(aggregatesColumn5);
                    var aggregatesColumn6 = Factmp[groupingKey[i]+"!T"].aggregates[5].value;
                    listAggregatesColumn6.puch(aggregatesColumn6);
                    var aggregatesColumn7 = Factmp[groupingKey[i]+"!T"].aggregates[6].value;
                    listAggregatesColumn7.puch(aggregatesColumn7);
                    var aggregatesColumn8 = Factmp[groupingKey[i]+"!T"].aggregates[7].value;
                    listAggregatesColumn8.puch(aggregatesColumn8);
                        
                    //component.set("v.dataRows", Factmp[groupingKey+"!T"]);
                    
                    //}
                        }
                    component.set("v.aggregateColumn1",listAggregatesColumn1);
                    }
                
                for( var i = 0; i < returnValue.reportMetadata.aggregates.length; i++ ){
                    var fieldAPIName = returnValue.reportMetadata.aggregates[i];
                    var fieldLabel = returnValue.reportExtendedMetadata.aggregateColumnInfo[fieldAPIName].label;
                    tableHeaders.push(fieldLabel)
                }
                component.set("v.columnLabels", tableHeaders);
                
                //hide spinner, reveal data
                $A.util.addClass(loadingSpinner, 'slds-hide');
                $A.util.removeClass(reportContainer, 'slds-hide');
            }
            else {
                $A.util.addClass(loadingSpinner, 'slds-hide');
                $A.util.removeClass(reportError, 'slds-hide');
            }
        })
        $A.enqueueAction(action);
        
        var action2 = component.get('c.getValues');
        action2.setParams({ 
            aggregateColumn1: component.get("v.aggregateColumn1")
        });
    }
})
({
  doInit: function(component, event, helper) {
    var factMap = component.get("v.factMap");
      console.log("factMap" +factMap);
    var colLabels = component.get("v.columnLabels");
    var ColNumber;
    var TargetVal;
    if (colLabels) {
      console.log("colLabels" + colLabels.length);
      for (var i = 0; i < colLabels.length; i++) {
        if (colLabels[i].includes("Target")) {
          ColNumber = i;
        }
      }

      var aggLst = component.get("v.dataRows[0].aggregates");
      
      if (ColNumber != "undefined") {
        for (var i = 0; i < component.get("v.dataRows[0].aggregates.length"); i++)
          if (i == ColNumber) {
            TargetVal = aggLst[i].value; //component.get("v.dataRows[0].aggregates[i].value");
            console.log(TargetVal + "TargetVal");
            component.set("v.TarValue", TargetVal);
          }
            else{
                component.set("v.TarValue", '');
            }
      }
    }

    if (factMap) {
        console.log("XYZ");
        
        
        
        
        
        
        
        var groupingKey = component.get("v.groupingKey");
      if(!groupingKey.includes("_"))
      {
        console.log("groupingKeyx" +groupingKey);
          component.set("v.dataRows", factMap[groupingKey+"!T"]);
       }
      //component.set("v.dataRows", factMap["T" + "!T"]);
      console.log("factMap" + factMap);
      var cValue = component.get("v.Column1");
      console.log("Column1" + cValue);
      console.log('groupingKey' +groupingKey);
      console.log('factMap1' +factMap[groupingKey+"!T"]);
      console.log("component.get(v.dataRows)" + component.get("v.dataRows[0].aggregates[0].value"));

      if (
        component.get("v.dataRows[0].aggregates[0].label") != undefined &&
        !component.get("v.dataRows[0].aggregates[0].label").includes("₹")
      ) {
        var col1 = component.get("v.dataRows[0].aggregates[0].label");
      } else {
        var col1 =
          "₹" +
          parseFloat(
            component.get("v.dataRows[0].aggregates[0].value") / 1000000
          ).toFixed(2) +
          "M";
      }
      if (
        component.get("v.dataRows[0].aggregates[1].label") != undefined &&
        !component.get("v.dataRows[0].aggregates[1].label").includes("₹")
      ) {
        var col2 = component.get("v.dataRows[0].aggregates[1].label");
      } else {
        var col2 =
          "₹" +
          parseFloat(
            component.get("v.dataRows[0].aggregates[1].value") / 1000000
          ).toFixed(2) +
          "M";
      }
      if (
        component.get("v.dataRows[0].aggregates[2].label") != undefined &&
        !component.get("v.dataRows[0].aggregates[2].label").includes("₹")
      ) {
        var col3 = component.get("v.dataRows[0].aggregates[2].label");
      } else {
        var col3 =
          "₹" +
          parseFloat(
            component.get("v.dataRows[0].aggregates[2].value") / 1000000
          ).toFixed(2) +
          "M";
      }
      if (
        component.get("v.dataRows[0].aggregates[3].label") != undefined &&
        !component.get("v.dataRows[0].aggregates[3].label").includes("₹")
      ) {
        var col4 = component.get("v.dataRows[0].aggregates[3].label");
      } else {
        var col4 =
          "₹" +
          parseFloat(
            component.get("v.dataRows[0].aggregates[3].value") / 1000000
          ).toFixed(2) +
          "M";
      }
      if (
        component.get("v.dataRows[0].aggregates[4].label") != undefined &&
        !component.get("v.dataRows[0].aggregates[4].label").includes("₹")
      ) {
        var col5 = component.get("v.dataRows[0].aggregates[4].label");
      } else {
        var col5 =
          "₹" +
          parseFloat(
            component.get("v.dataRows[0].aggregates[4].value") / 1000000
          ).toFixed(2) +
          "M";
      }
      if (
        component.get("v.dataRows[0].aggregates[5].label") != undefined &&
        !component.get("v.dataRows[0].aggregates[5].label").includes("₹")
      ) {
        var col6 = component.get("v.dataRows[0].aggregates[5].label");
      } else {
        var col6 = "₹" + parseFloat(component.get("v.dataRows[0].aggregates[5].value") / 1000000).toFixed(2) + "M";
      }
      if (
        component.get("v.dataRows[0].aggregates[6].label") != undefined &&
        !component.get("v.dataRows[0].aggregates[6].label").includes("₹")
      ) {
        var col7 = component.get("v.dataRows[0].aggregates[6].label");
      } else {
        var col7 = "₹" + parseFloat(component.get("v.dataRows[0].aggregates[6].value") / 1000000).toFixed(2) + "M";
      }
      if (
        component.get("v.dataRows[0].aggregates[7].label") != undefined &&
        !component.get("v.dataRows[0].aggregates[7].label").includes("₹")
      ) {
        var col8 = component.get("v.dataRows[0].aggregates[7].label");
      } else {
        var col8 = "₹" + parseFloat(component.get("v.dataRows[0].aggregates[7].value") / 1000000).toFixed(2) + "M";
      }
      component.set("v.colValue1", col1);
      component.set("v.colValue2", col2);
      component.set("v.colValue3", col3);
      component.set("v.colValue4", col4);
      component.set("v.colValue5", col5);
      component.set("v.colValue6", col6);
      component.set("v.colValue7", col7);
      component.set("v.colValue8", col8);
    }
  },
  editRecord: function(component, event, helper) {
    var recordId = event.currentTarget.dataset.recordid;
    var editRecordEvent = $A.get("e.force:editRecord");
    editRecordEvent.setParams({
      recordId: recordId
    });
    editRecordEvent.fire();
  }
});
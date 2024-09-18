global with sharing class ReportComponentController extends VisualEditor.DynamicPickList{
    @AuraEnabled
    public static String getReportMetadata ( Id reportId ){
        system.debug(JSON.serializePretty(Reports.ReportManager.runReport( reportId, false ) ));
       return JSON.serializePretty(Reports.ReportManager.runReport( reportId, false ) );
    }
    
    @AuraEnabled
    global override VisualEditor.DataRow getDefaultValue(){
        VisualEditor.DataRow defaultValue = new VisualEditor.DataRow('red', 'RED');
        return defaultValue;
    }
    @AuraEnabled
    global override VisualEditor.DynamicPickListRows getValues() {
        VisualEditor.DataRow value1 = new VisualEditor.DataRow('red', 'RED');
        VisualEditor.DataRow value2 = new VisualEditor.DataRow('yellow', 'YELLOW');
        VisualEditor.DynamicPickListRows  myValues = new VisualEditor.DynamicPickListRows();
        myValues.addRow(value1);
        myValues.addRow(value2);
        return myValues;
    }
    
    
        @AuraEnabled
    global static VisualEditor.DynamicPickListRows getLabel(list<string> acc) {
        VisualEditor.DataRow value1 = new VisualEditor.DataRow('red', 'RED');
        VisualEditor.DataRow value2 = new VisualEditor.DataRow('yellow', 'YELLOW');
        VisualEditor.DynamicPickListRows  myValues = new VisualEditor.DynamicPickListRows();
        myValues.addRow(value1);
        myValues.addRow(value2);
        return myValues;
    }
}
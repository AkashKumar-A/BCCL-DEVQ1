global class ReportContainerCustomPickList extends VisualEditor.DynamicPickList{
  @AuraEnabled  
    global override VisualEditor.DataRow getDefaultValue(){
        VisualEditor.DataRow defaultValue = new VisualEditor.DataRow('Red', 'RED');
        return defaultValue;
    }
    global override VisualEditor.DynamicPickListRows getValues() {
        VisualEditor.DataRow value1 = new VisualEditor.DataRow('Red', 'RED');
        VisualEditor.DataRow value2 = new VisualEditor.DataRow('Yellow', 'YELLOW');
        VisualEditor.DataRow value3 = new VisualEditor.DataRow('Blue', 'BLUE');
        VisualEditor.DynamicPickListRows  myValues = new VisualEditor.DynamicPickListRows();
        myValues.addRow(value1);
        myValues.addRow(value2);
        myValues.addRow(value3);
        return myValues;
    }

}
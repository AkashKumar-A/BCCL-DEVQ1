public class AchievementDeadlineController {
    public List<RowDetail> rowList {get;set;}
    public String horizontal {get;set;}
    public String branchName {get;set;}
    public String monthName {get;set;}
    public String totalValue {get;set;}

    public AchievementDeadlineController() {
        this.rowList = new List<RowDetail>();
        this.totalValue = '0';
        this.branchName = System.currentPageReference().getParameters().get('branch');
        String dateString = System.currentPageReference().getParameters().get('dateString');
        String verticalName = System.currentPageReference().getParameters().get('vertical');
        String horizontalName = System.currentPageReference().getParameters().get('horizontal');
        System.debug(dateString);
        System.debug('vertical: ' + verticalName);
        System.debug('horizontal: ' + horizontalName);
        Date runningDate = System.today();
        if (dateString != null) {
            runningDate = Date.valueOf(dateString);
        }
        System.debug('running date: ' + runningDate);
        Date rangeStartDate = runningDate.addMonths(-1).toStartOfMonth();
        Date rangeEndDate = rangeStartDate.addMonths(1).addDays(-1);
        String branchName = this.branchName;
        String status = rsp_ResponseConstants.ACHIEVEMENT_OPEN;
        System.debug('range => ' + rangeStartDate + ' to ' + rangeEndDate);
        this.monthName = ((DateTime) rangeStartDate).format('MMMM YYYY');
        Map<String, Map<String, WrapperClass>> tempMap = new Map<String, Map<String, WrapperClass>>();
        for (rsp_Achievement__c objAch: Database.query(
            'SELECT Id, rsp_Role__r.Name, rsp_Opportunity__r.rsp_Role__r.Name, ' + 
            'rsp_Opportunity__r.Owner.Name, rsp_User__r.Name, rsp_Credit_Split_Status__c, ' +
            'rsp_Vertical__c, rsp_Horizontal__c, rsp_Achievement_Value__c ' +
            'FROM rsp_Achievement__c WHERE ' +
            'rsp_Achievement_Date__c >= :rangeStartDate AND ' +
            'rsp_Achievement_Date__c <= :rangeEndDate AND ' +
            (verticalName != null ? 'rsp_Opportunity__r.rsp_Role__r.rsp_Vertical__r.Name = :verticalName AND ' : '') +
            (horizontalName != null ? 'rsp_Opportunity__r.rsp_Role__r.rsp_Horizontal__r.Name = :horizontalName AND ' : '') +
            'rsp_Credit_Split_Status__c = :status AND ' +
            'rsp_Sales_Org__c = :branchName AND ' + 
            'Response_Revenue_Print__c = true '
        )) {
            String key1;
            if (objAch.rsp_Vertical__c != null) {
                key1 = objAch.rsp_Vertical__c;
            }
            else if (objAch.rsp_Horizontal__c != null) {
                key1 = objAch.rsp_Horizontal__c;
                if (this.horizontal == null) {
                    this.horizontal = '/ Horizontal';
                }
            }
            if (key1 != null) {
                if (tempMap.get(key1) == null) {
                    tempMap.put(key1, new Map<String, WrapperClass>());
                }
                Map<String, WrapperClass> tempMapInner = tempMap.get(key1);
                String key2 = objAch.rsp_Role__r?.Name;
                if (key2 != null) {
                    if (tempMapInner.get(key2) == null) {
                        tempMapInner.put(key2, new WrapperClass(objAch.rsp_Opportunity__r?.Owner?.Name));
                    }
                    tempMapInner.get(key2).totalValue += objAch.rsp_Achievement_Value__c;
                }
            }
        }
        Decimal totalValue = 0;
        for (String key1: tempMap.keySet()) {
            // Boolean firstRowForVertical = true;
            // Boolean firstRowForRole = true;
            Map<String, WrapperClass> tempMapInner = tempMap.get(key1);
            for (String key2: tempMapInner.keySet()) {
                WrapperClass wrapObj = tempMapInner.get(key2);
                String value = String.format((wrapObj.totalValue ?? 0).format(), new String[]{'0','number','##,##,##,##0.00'});

                RowDetail rd = new RowDetail();
                rd.columnList = new List<ColumnDetail>();
                rd.columnList.add(new ColumnDetail(key1));
                rd.columnList.add(new ColumnDetail(key2));
                rd.columnList.add(new ColumnDetail(wrapObj.userName));
                rd.columnList.add(new ColumnDetail(value));
                totalValue += (wrapObj.totalValue ?? 0).setScale(2);
                this.rowList.add(rd);
            }
        }
        this.totalValue = String.format(totalValue.format(), new String[]{'0','number','##,##,##,##0.00'});
    }
    
    public class RowDetail {
        public List<ColumnDetail> columnList{get;set;}

        public RowDetail() {
            this.columnList = new List<ColumnDetail>();
        }
    }
    
    public class ColumnDetail {
        public String rowSpan;
        public String colSpan;
        public String style{get;set;}
        public String data{get;set;}

        public ColumnDetail() {}

        public ColumnDetail(String data) {
            this.data = String.isBlank(data) ? '&nbsp;' : data;
            this.style = 'empty-cells:show;padding: 4pt 2pt 2pt 3pt;';
            this.rowSpan = '1';
            this.colSpan = '1';
        }

        public ColumnDetail(String data, String style, Integer rowSpan, Integer colSpan) {
            this.data = String.isBlank(data) ? '&nbsp;' : data;
            this.style = 'empty-cells:show;padding:5pt 5pt 5pt 5pt;' + style;
            if (rowSpan != null) {
                this.rowSpan = String.valueOf(rowSpan);
            }
            if (colSpan != null) {
                this.colSpan = String.valueOf(colSpan);
            }
        }

        public ColumnDetail(String data, String style) {
            this.data = String.isBlank(data) ? '\u202F' : data;
            this.style = 'empty-cells:show;padding:0.75pt 12pt 0.75pt 0.75pt;' + (style ?? '');
        }

        public String getrowSpan() {
            System.debug('custom debug ' + this.rowSpan);
            if (!String.isBlank(this.rowSpan) && this.rowSpan != '0') {
                return this.rowSpan;
            }
            else {
                return '1';
            }
        }
        public String getcolSpan() {
            if (!String.isBlank(this.colSpan) && this.colSpan != '0') {
                return this.colSpan;
            }
            else {
                return '1';
            }
        }
    }

    public class WrapperClass {
        public String userName;
        public Decimal totalValue;
        
        public WrapperClass() {
            this.totalValue = 0;
        }

        public WrapperClass(String name) {
            this.userName = name;
            this.totalValue = 0;
        }
    }

}
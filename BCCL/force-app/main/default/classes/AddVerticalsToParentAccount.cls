global class AddVerticalsToParentAccount implements Database.Batchable<sObject> {
    public string typeOfAcc = null;
    global AddVerticalsToParentAccount(string typeOfAccount) {
        if(typeOfAccount == 'GROUP') {
            this.typeOfAcc = 'GROUP';
        }
    }
    global Database.QueryLocator start(Database.BatchableContext bc) {
        //set<string> accountidset = new set<string>{'0001205856','0001208406','0001172688','0001153164','0001152766','0001172976','0001818088','0001150193'}; 
        //accountidset.add('0001152887');
        String query;
        if(typeOfAcc == null) {
            query= 'select id, name, Vertical__c, rsp_Hierarchy_Code__c, Branch_Sharing_Rule__c, ParentId, Parent.name, Parent.Vertical__c, Parent.Branch_Sharing_Rule__c from account where type != \'GROUP\' AND type != \'SUPER\' AND Vertical__c includes (\'GOVERNMENT\', \'B3+PSU\')'; // where rsp_Hierarchy_Code__c = :accountidset
        }
        else {
            query= 'select id, name, Vertical__c, rsp_Hierarchy_Code__c, Branch_Sharing_Rule__c, ParentId, Parent.name, Parent.Vertical__c, Parent.Branch_Sharing_Rule__c from account where type = \'GROUP\' AND Vertical__c != null';
        }
        return Database.getQueryLocator(query); 
    }
    
    global void execute(Database.BatchableContext bc, List<Account> AccList) {
        list<Account> UpdateAccList = new list<Account>();
        //create a map that will hold the values of the list 
        map<id,account> accmap = new map<id,account>();
        list<string> VerList = new list<String>();
        for(Account acc: AccList) {
            string ver = acc.Vertical__c;
            if(ver!=null && ver!='') {
                VerList = ver.split(';');
            }
            for(string verUnit : VerList) {
                if(verUnit == 'GOVERNMENT' || verUnit == 'B3+PSU') {
                    if(acc.Parent!=null && acc.Parent.Vertical__c!=null) {
                        if(acc.Vertical__c!=null) {
                            if(!acc.Parent.Vertical__c.contains(verUnit)) {
                                acc.Parent.Vertical__c =  acc.Parent.Vertical__c +';'+verUnit;
                                System.debug('Check1');    
                            }	
                            
                        }
                    }
                    else if (acc.Parent!=null && acc.Parent.Vertical__c==null) {
                        if(acc.Vertical__c!=null) {
                            acc.Parent.Vertical__c =  verUnit; //acc.Vertical__c;
                            System.debug('Check2');    
                        }
                    }
                    
                    if(acc.Parent!=null && acc.Parent.Branch_Sharing_Rule__c!=null) {
                        if(acc.Branch_Sharing_Rule__c!=null) {
                            
                            string Branch = acc.Branch_Sharing_Rule__c;
                            String[] BranchList     = Branch.split(';');
                            for(string branchUnit : BranchList) {
                                if(!acc.Parent.Branch_Sharing_Rule__c.contains(branchUnit)) {
                                    acc.Parent.Branch_Sharing_Rule__c =  acc.Parent.Branch_Sharing_Rule__c +';'+branchUnit;
                                    System.debug('Check3');    
                                }
                            }
                        }
                    }
                    else if (acc.Parent!=null && acc.Parent.Branch_Sharing_Rule__c==null) {
                        if(acc.Branch_Sharing_Rule__c!=null) {
                            acc.Parent.Branch_Sharing_Rule__c =  acc.Branch_Sharing_Rule__c;
                            System.debug('Check4');
                        }
                    }
                    if(acc.Parent!=null)
                        UpdateAccList.add(acc.Parent);
                }
            } 
        }
        
        if(UpdateAccList.size()>0 && !UpdateAccList.isEmpty())
        {
            //put all the values from the list to map. 
            accmap.putall(UpdateAccList);
            //update UpdateAccList;
        }
        if(accmap.size()>0){
            update accmap.values();
        }
        
    }
    global void finish(Database.BatchableContext bc) {
        if(typeOfAcc == null) {
            Database.executeBatch(new AddVerticalsToParentAccount('GROUP'));
        }
        else {
            System.debug([select id, vertical__c from account limit 10]);
        }
    }
}
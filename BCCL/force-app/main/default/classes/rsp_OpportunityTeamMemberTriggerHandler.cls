/*------------------------------------------------------------
Author      :   Himanshu Panwar
Company     :   SaaSfocus
Description :   Handler class for OpportunityTeamMember object Trigger
Test Class  :   
Details     :   This class is assigning the appropiate team members to the opportunity.

History
<Date>          <Authors Name>     <Brief Description of Change>
05-March-2019     Himanshu         Created
------------------------------------------------------------*/

public class rsp_OpportunityTeamMemberTriggerHandler {
    
    public void validations(List<OpportunityTeamMember> listOpportunityTeamMember)
    {
       
            //Local Variables
            Set<Id> opportunityIdsSet = new Set<Id>();
            Set<Id> selectedUsersSet = new Set<Id>();
            
            //Variables used for existing Team Member check
            Map<Id,Set<String>>  exisitngOpportunityWithHVBMap= new  Map<Id,Set<String>>();
            Map<Id,Set<String>>  exisitngOpportunityWithHorizontalMap= new  Map<Id,Set<String>>();
            //End
            
            //Variable to find out Owner Role Hierarchy type(Horz and Vertical) and Branches and Products Horz
            Map<Id,Opportunity> selectedOpportunitiesMap = new Map<Id,Opportunity>();
            Map<Id,String> opportunityIdWithHierarchyTypeMap = new Map<Id,String>();
            Map<Id,String> opportunityIdWithBranchMap = new Map<Id,String>();
            Map<Id,Set<String>> opportunityIdWithProductHorizontals = new Map<Id,Set<String>>();
            //End
            
            //Variables to findout selected User Roles
            Map<Id,Set<String>> selectedUserWithVerticalBranchMap = new Map<Id,Set<String>>();
            Map<Id,Set<String>> selectedUserWithHorizontalBranchMap = new Map<Id,Set<String>>();
            Map<String,Id> selectedHVBWithRoleId = new Map<String,Id>();
            Map<Id,Id> selectedUserIdWithOpportunityIdMap = new Map<Id,Id>();
            //End - Variables Declartion
            
            //Filling the data into sets
            for(OpportunityTeamMember oTeamMember : listOpportunityTeamMember)
            {    
                if (oTeamMember.rsp_Opportunity_Team_Member_Role__c != NULL) {
                    opportunityIdsSet.add(oTeamMember.OpportunityId);
                    selectedUsersSet.add(oTeamMember.UserId);
                    selectedUserIdWithOpportunityIdMap.put(oTeamMember.UserId,oTeamMember.OpportunityId);
                }
            }
            System.debug('==opportunityIdsSet=='+opportunityIdsSet);
            System.debug('==selectedUsersSet=='+selectedUsersSet);
            System.debug('==selectedUserIdWithOpportunityIdMap=='+selectedUserIdWithOpportunityIdMap);
            
            //Creating Opportunity maps with branch and Hierarchy
            if(!opportunityIdsSet.isEmpty())
            {
                for(Opportunity opportunity : [SELECT Id,rsp_Role__c,Vertical__c,rsp_Role__r.rsp_Geography__r.rsp_Branch__c,
                                               rsp_Role__r.rsp_Hierarchy_Type__c,Vertical__r.Name FROM Opportunity 
                                               WHERE Id IN :opportunityIdsSet AND
                                               ((rsp_Role__r.rsp_Hierarchy_Type__c != NULL) OR
                                               (rsp_Role__r.rsp_Geography__r.rsp_Branch__c != NULL AND
                                               rsp_Role__r.rsp_Geography__c != NULL))])
                {
                    selectedOpportunitiesMap.put(opportunity.Id,opportunity);
                    
                    if(!String.isEmpty(opportunity.rsp_Role__r.rsp_Hierarchy_Type__c))
                        opportunityIdWithHierarchyTypeMap.put(opportunity.Id,opportunity.rsp_Role__r.rsp_Hierarchy_Type__c);
                    
                    if(opportunity.rsp_Role__r.rsp_Geography__c != NULL)
                        opportunityIdWithBranchMap.put(opportunity.Id,opportunity.rsp_Role__r.rsp_Geography__r.rsp_Branch__c);
                }
                System.debug('==opportunityIdWithHierarchyTypeMap=='+opportunityIdWithHierarchyTypeMap);
                System.debug('==opportunityIdWithBranchMap=='+opportunityIdWithBranchMap);
            }
            
            if(!selectedUsersSet.isEmpty())
            {
                for(rsp_Role__c role : [SELECT Id,Name,rsp_Geography__c,rsp_Hierarchy_Type__c,rsp_Horizontal__c,
                                        rsp_Vertical__r.Name,rsp_Horizontal__r.Name,rsp_Geography__r.rsp_Branch__c,
                                        rsp_Vertical__c,rsp_Current_User__c FROM rsp_Role__c 
                                        WHERE rsp_Current_User__c IN :selectedUsersSet AND
                                        ((rsp_Vertical__c != NULL OR rsp_Horizontal__c != NULL) OR 
                                         (rsp_Geography__c != NULL AND rsp_Geography__r.rsp_Branch__c != NULL))])
                                         
                {
                    //Populating User with VerticalWithBranch combination
                    if(role.rsp_Vertical__c != NULL && role.rsp_Geography__c != NULL)
                    {
                        //Populating VerticalWithBranch Map
                        if(selectedUserWithVerticalBranchMap.get(role.rsp_Current_User__c) == null)
                        {
                            selectedUserWithVerticalBranchMap.put(role.rsp_Current_User__c,new Set<String>());
                        }
                        String value='';
                        Set<String> VerticalsWithBranchSet = selectedUserWithVerticalBranchMap.get(role.rsp_Current_User__c);
                        value = role.rsp_Vertical__r.Name +'-';
                        if(!String.isBlank(role.rsp_Geography__r.rsp_Branch__c))
                        {
                            Id opportunityId = selectedUserIdWithOpportunityIdMap.get(role.rsp_Current_User__c);
                            if(!String.isBlank(opportunityIdWithBranchMap.get(opportunityId)))
                            {
                                if(role.rsp_Geography__r.rsp_Branch__c == opportunityIdWithBranchMap.get(opportunityId))
                                {
                                    value = value + role.rsp_Geography__r.rsp_Branch__c;
                                    VerticalsWithBranchSet.add(value);
                                    selectedUserWithVerticalBranchMap.put(role.rsp_Current_User__c,VerticalsWithBranchSet);
                                    
                                    if(selectedHVBWithRoleId.get(value) == null)
                                        selectedHVBWithRoleId.put(value,role.Id); 
                                } 
                            } 
                        } 
                    }//End
                    
                    //Populating User with HorizontalWithBranch Map
                    if(role.rsp_Horizontal__c != NULL && role.rsp_Geography__c != NULL)
                    { 
                        if(selectedUserWithHorizontalBranchMap.get(role.rsp_Current_User__c) == null)
                        {
                            selectedUserWithHorizontalBranchMap.put(role.rsp_Current_User__c,new Set<String>());
                        }
                        String value='';
                        Set<String> HorizontalsWithBranchSet = selectedUserWithHorizontalBranchMap.get(role.rsp_Current_User__c);
                        value = role.rsp_Horizontal__r.Name +'-';
                        if(!String.isBlank(role.rsp_Geography__r.rsp_Branch__c))
                        {
                            Id opportunityId = selectedUserIdWithOpportunityIdMap.get(role.rsp_Current_User__c);
                            if(!String.isBlank(opportunityIdWithBranchMap.get(opportunityId)))
                            {
                                if(role.rsp_Geography__r.rsp_Branch__c == opportunityIdWithBranchMap.get(opportunityId))
                                {
                                    value = value + role.rsp_Geography__r.rsp_Branch__c;    
                                    HorizontalsWithBranchSet.add(value);
                                    selectedUserWithHorizontalBranchMap.put(role.rsp_Current_User__c,HorizontalsWithBranchSet);
                                    
                                    if(selectedHVBWithRoleId.get(value) == null)
                                        selectedHVBWithRoleId.put(value,role.Id); 
                                }
                            }
                        }
                    }//End
                }
            }
            
            System.debug('==selectedUserWithVerticalBranchMap=='+selectedUserWithVerticalBranchMap);
            System.debug('==selectedUserWithHorizontalBranchMap=='+selectedUserWithHorizontalBranchMap);
            System.debug('==selectedHVBWithRoleId=='+selectedHVBWithRoleId);
            
            //Creating a map for existing opportunity+user with HVB
            if(!opportunityIdsSet.isEmpty())
            {
                for(OpportunityTeamMember opportunityTeamMember : [SELECT OpportunityId,rsp_Opportunity_Team_Member_Role__c,UserId,
                                                                   rsp_Opportunity_Team_Member_Role__r.rsp_Hierarchy_Type__c,
                                                                   rsp_Opportunity_Team_Member_Role__r.rsp_Vertical__r.Name,
                                                                   rsp_Opportunity_Team_Member_Role__r.rsp_Horizontal__r.Name,
                                                                   rsp_Opportunity_Team_Member_Role__r.rsp_Geography__r.rsp_Branch__c
                                                                   FROM OpportunityTeamMember
                                                                   WHERE OpportunityId IN :opportunityIdsSet AND
                                                                   rsp_Opportunity_Team_Member_Role__c != NULL AND
                                                                   (rsp_Opportunity_Team_Member_Role__r.rsp_Hierarchy_Type__c != NULL OR
                                                                    rsp_Opportunity_Team_Member_Role__r.rsp_Vertical__c != NULL OR
                                                                    rsp_Opportunity_Team_Member_Role__r.rsp_Horizontal__c != NULL OR
                                                                    (rsp_Opportunity_Team_Member_Role__r.rsp_Geography__c != NULL AND
                                                                     rsp_Opportunity_Team_Member_Role__r.rsp_Geography__r.rsp_Branch__c != NULL))])
                {
                    System.debug('=====opportunityTeamMember==== '+opportunityTeamMember);
                    if(exisitngOpportunityWithHVBMap.get(opportunityTeamMember.OpportunityId) == null)
                    {
                        exisitngOpportunityWithHVBMap.put(opportunityTeamMember.OpportunityId, new Set<String>());
                    }
                    Set<String> HVBStringSet = exisitngOpportunityWithHVBMap.get(opportunityTeamMember.OpportunityId);
                    String value = '';
                    System.debug('::opportunityTeamMember.rsp_Opportunity_Team_Member_Role__c:'+opportunityTeamMember.rsp_Opportunity_Team_Member_Role__c);
                    if(opportunityTeamMember.rsp_Opportunity_Team_Member_Role__c != null)
                    {
                        //rsp_Role__c role = existingSelectedMemberRolesMap.get(eachMember.rsp_Opportunity_Team_Member_Role__c);
                        if(!String.isBlank(opportunityTeamMember.rsp_Opportunity_Team_Member_Role__r.rsp_Hierarchy_Type__c))
                        {
                            System.debug('::opportunityTeamMember.rsp_Opportunity_Team_Member_Role__r.rsp_Hierarchy_Type__c::'+opportunityTeamMember.rsp_Opportunity_Team_Member_Role__r.rsp_Hierarchy_Type__c);
                            if(opportunityTeamMember.rsp_Opportunity_Team_Member_Role__r.rsp_Hierarchy_Type__c == rsp_ResponseConstants.HIERARCHY_TYPE_VERTICAL)
                            {
                                if(opportunityTeamMember.rsp_Opportunity_Team_Member_Role__r.rsp_Vertical__c != null)
                                {
                                    value = opportunityTeamMember.rsp_Opportunity_Team_Member_Role__r.rsp_Vertical__r.Name +'-';
                                }
                            }
                            else if(opportunityTeamMember.rsp_Opportunity_Team_Member_Role__r.rsp_Hierarchy_Type__c == rsp_ResponseConstants.HIERARCHY_TYPE_HORIZONTAL)
                            {
                                if(exisitngOpportunityWithHorizontalMap.get(opportunityTeamMember.OpportunityId) == null)
                                {
                                    exisitngOpportunityWithHorizontalMap.put(opportunityTeamMember.OpportunityId,new Set<String>()); 
                                }
                                if(opportunityTeamMember.rsp_Opportunity_Team_Member_Role__r.rsp_Horizontal__c != null)
                                {
                                    value = opportunityTeamMember.rsp_Opportunity_Team_Member_Role__r.rsp_Horizontal__r.Name +'-';
                                    
                                    Set<String> horizontalValues = exisitngOpportunityWithHorizontalMap.get(opportunityTeamMember.OpportunityId);
                                    horizontalValues.add(opportunityTeamMember.rsp_Opportunity_Team_Member_Role__r.rsp_Horizontal__r.Name);
                                    exisitngOpportunityWithHorizontalMap.put(opportunityTeamMember.OpportunityId,horizontalValues); 
                                }
                            }
                        }
                        if(opportunityTeamMember.rsp_Opportunity_Team_Member_Role__r.rsp_Geography__c != null)
                        {
                            if(opportunityTeamMember.rsp_Opportunity_Team_Member_Role__r.rsp_Geography__r.rsp_Branch__c != NULL)
                                value = value + opportunityTeamMember.rsp_Opportunity_Team_Member_Role__r.rsp_Geography__r.rsp_Branch__c;
                        }
                    }
                    HVBStringSet.add(value);
                    exisitngOpportunityWithHVBMap.put(opportunityTeamMember.OpportunityId, HVBStringSet);
                }
            }
            System.debug('==exisitngOpportunityWithHVBMap=='+exisitngOpportunityWithHVBMap);
            System.debug('=exisitngOpportunityWithHorizontalMap=='+exisitngOpportunityWithHorizontalMap);
            
            //Finding opportunities line items Horizontals which are not already exists in Opportunity
            if(!opportunityIdsSet.isEmpty())
            {
                for(OpportunityLineItem opportLineItem : [SELECT Id,Product2.rsp_HorizontalList__c,OpportunityId
                                                          FROM OpportunityLineItem WHERE OpportunityId IN :opportunityIdsSet])
                {
                    if(opportunityIdWithProductHorizontals.get(opportLineItem.OpportunityId) == null)
                    {
                        opportunityIdWithProductHorizontals.put(opportLineItem.OpportunityId,new Set<String>()); 
                    }
                    if(opportLineItem.Product2.rsp_HorizontalList__c != null)
                    {
                        String branch = '';
                        if(!String.isBlank(opportunityIdWithBranchMap.get(opportLineItem.OpportunityId)))
                        {
                            branch = opportunityIdWithBranchMap.get(opportLineItem.OpportunityId);
                        }
                        List<String> horizontal = opportLineItem.Product2.rsp_HorizontalList__c.split(',');
                        //To find out existing Horizontal
                        if(exisitngOpportunityWithHorizontalMap.isEmpty() || exisitngOpportunityWithHorizontalMap.get(opportLineItem.OpportunityId).isEmpty())
                        {
                            Set<String> horizontalWithBranchValues = new Set<String>();
                            Set<String> exisitingHorz = opportunityIdWithProductHorizontals.get(opportLineItem.OpportunityId);
                            //Fetch branch for a particular opportunity
                            for(String eachHorizontal : horizontal)
                            {
                                if(!String.isBlank(branch))
                                {
                                    horizontalWithBranchValues.add(eachHorizontal+'-'+branch); 
                                }
                            }
                            exisitingHorz.addAll(horizontalWithBranchValues);
                            opportunityIdWithProductHorizontals.put(opportLineItem.OpportunityId,exisitingHorz); 
                        }
                        else
                        {
                            Set<String> horizontalValues = exisitngOpportunityWithHorizontalMap.get(opportLineItem.OpportunityId);
                            if(!horizontal.isEmpty())
                            {
                                for(String horzValue : horizontal)
                                {
                                    if(!horizontalValues.contains(horzValue)) 
                                    {
                                        Set<String> exisitingHorz = opportunityIdWithProductHorizontals.get(opportLineItem.OpportunityId);
                                        if(!String.isBlank(branch))
                                        {
                                            exisitingHorz.add(horzValue+'-'+branch);
                                        }
                                        opportunityIdWithProductHorizontals.put(opportLineItem.OpportunityId,exisitingHorz);  
                                    }
                                }
                            }
                        }
                    }
                }
            }
            System.debug('==opportunityIdWithProductHorizontals=='+opportunityIdWithProductHorizontals);
            
            
            //Main logic of trigger
            for(OpportunityTeamMember oTeamMember : listOpportunityTeamMember)
            {
                String horizontal = '';
                String branch = '';
                String vertical = '';
                
                //Filling branch in the variable
                if(!String.isBlank(opportunityIdWithBranchMap.get(oTeamMember.OpportunityId)))
                {
                    branch = opportunityIdWithBranchMap.get(oTeamMember.OpportunityId);
                }
                vertical = selectedOpportunitiesMap.containsKey(oTeamMember.OpportunityId) && selectedOpportunitiesMap.get(oTeamMember.OpportunityId).Vertical__r != null ?
                selectedOpportunitiesMap.get(oTeamMember.OpportunityId).Vertical__r.Name : null;
                
                //finding out whether opportunity is horizontal or vertical
                if(!String.isBlank(opportunityIdWithHierarchyTypeMap.get(oTeamMember.OpportunityId)))
                {
                    //If the opportunity is vertical
                    if(opportunityIdWithHierarchyTypeMap.get(oTeamMember.OpportunityId) == rsp_ResponseConstants.HIERARCHY_TYPE_VERTICAL)
                    {
                        Boolean isErrorComing = false;
                        //Checking if the Horizontal and Branch combination already exists or not in Opportunity Team Member
                        if(!exisitngOpportunityWithHVBMap.isEmpty())
                        {
                            if(!selectedUserWithHorizontalBranchMap.isEmpty()) 
                            {
                                if(!selectedUserWithHorizontalBranchMap.get(oTeamMember.UserId).isEmpty())
                                {
                                    //Checking existing HB Combinations with selected User HB
                                    if(exisitngOpportunityWithHVBMap.get(oTeamMember.OpportunityId).containsAll(selectedUserWithHorizontalBranchMap.get(oTeamMember.UserId)))
                                    {
                                        oTeamMember.addError(Label.User_Already_Exists_For_Horizontal);
                                        isErrorComing = true;
                                    }
                                }
                            }
                        }//End - Existing team Member
                        
                        //Finding products horizontals and matches with User's horizontals and checking null conditions
                        if(selectedUserWithHorizontalBranchMap.isEmpty() || (selectedUserWithHorizontalBranchMap.get(oTeamMember.UserId) != null &&
                        selectedUserWithHorizontalBranchMap.get(oTeamMember.UserId).isEmpty()))
                        {
                            if(isErrorComing == false)
                            {
                                oTeamMember.addError(Label.No_Horizontal_Available);
                                isErrorComing = true;
                            }
                        }    
                        else
                        {
                            //Adding Errors is not products found on Opportunity
                            if(opportunityIdWithProductHorizontals.isEmpty() || opportunityIdWithProductHorizontals.get(oTeamMember.OpportunityId).isEmpty())
                            {
                                if(isErrorComing == false)
                                {
                                    oTeamMember.addError(Label.No_Products_Available);
                                    isErrorComing = true;
                                }
                            }
                            //Matching Horizontals and Branch Combination
                            else
                            {
                                Boolean isHorizontalExist = False;
                                System.debug('@@@@@@@@@@@@'+selectedUserWithHorizontalBranchMap.get(oTeamMember.UserId));
                                if(selectedUserWithHorizontalBranchMap.get(oTeamMember.UserId) != null) {
                                    for(String horizontalBranchValue : selectedUserWithHorizontalBranchMap.get(oTeamMember.UserId))
                                {
                                    if(opportunityIdWithProductHorizontals.get(oTeamMember.OpportunityId).contains(horizontalBranchValue))
                                    {
                                        List<String> splittedValue = horizontalBranchValue.split('-');
                                        if(!splittedValue.isEmpty())
                                            horizontal = splittedValue[0];
                                        isHorizontalExist = True;  
                                        break;
                                    }
                                  }
                                }
                                
                                if(isHorizontalExist == False)
                                {
                                    if(isErrorComing == false)
                                    {
                                        oTeamMember.addError(Label.Horizontal_Not_Matched);
                                        isErrorComing = true;
                                    }
                                }
                            }
                        }//End - Horizontals and branch check
                        
                        //Filling out the role on the team member if there is no error
                        if(!String.isBlank(branch) && !String.isBlank(horizontal))
                        {
                            if(selectedHVBWithRoleId.get(horizontal+'-'+branch) != null)
                            {
                                oTeamMember.rsp_Opportunity_Team_Member_Role__c = selectedHVBWithRoleId.get(horizontal+'-'+branch); 
                            }
                        }//End - Role assignment
                    }//End - Vertical Opportunity
                    
                    //If the opportunity is horizontal
                    if(opportunityIdWithHierarchyTypeMap.get(oTeamMember.OpportunityId) == rsp_ResponseConstants.HIERARCHY_TYPE_HORIZONTAL)
                    {
                        //Checking if the Vertical and Branch combination already exists or not in Opportunity Team Member
                        if(!exisitngOpportunityWithHVBMap.isEmpty())
                        {
                            if(!String.isBlank(branch) && !String.isBlank(vertical))
                            {
                                //Checking existing VB Combinations with selected User VB
                                if(exisitngOpportunityWithHVBMap.get(oTeamMember.OpportunityId).contains(vertical+'-'+branch))
                                {
                                    oTeamMember.addError(Label.User_Already_Exists_For_Vertical); 
                                }
                            }
                        }//End - Existing team Member  
                       
                       
                        if(selectedUserWithVerticalBranchMap.isEmpty() || selectedUserWithVerticalBranchMap.get(oTeamMember.UserId).isEmpty() || selectedHVBWithRoleId.isEmpty())
                        {
                            oTeamMember.addError(Label.No_Vertical_Available); 
                        }
                        else
                        {
                            if(!String.isBlank(branch) && !String.isBlank(vertical))
                            {
                                Set<String> verticalBranchSet = selectedUserWithVerticalBranchMap.get(oTeamMember.UserId);
                                if(!verticalBranchSet.contains(vertical+'-'+branch))
                                {
                                    oTeamMember.addError(Label.Vertical_Not_Matched);
                                }
                            }
                        }
                        //Filling out the role on the team member if there is no error
                        if(!String.isBlank(branch) && !String.isBlank(vertical))
                        {
                            if(selectedHVBWithRoleId.get(vertical+'-'+branch) != null)
                            {
                                oTeamMember.rsp_Opportunity_Team_Member_Role__c = selectedHVBWithRoleId.get(vertical+'-'+branch); 
                            }
                        }//End - Role assignment
                        
                    }//End- Horizontal Opportunity
                }//End - isBlank condition of Hierarchy Type in Opportunity
            }//End - For loop for main logic of trigger
        }
}
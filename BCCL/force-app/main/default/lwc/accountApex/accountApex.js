import { LightningElement ,wire,api} from 'lwc';
import NAME_FIELD from '@salesforce/schema/Account.Name';
import UNIQUE_CODE__C  from '@salesforce/schema/Account.Unique_Code__c';
 
import getAccount from '@salesforce/apex/AccountController.getAccount';
import UnitPrice from '@salesforce/schema/PricebookEntry.UnitPrice';


const COLUMNS = [
    { label: 'Account Name', fieldName: NAME_FIELD.fieldApiName, type: 'text' },
    { label: 'Unique Code', fieldName: UNIQUE_CODE__C.fieldApiName, type: 'text' }

      ] ;


   

export default class AccountApex extends LightningElement {

@api  recordId = "001O000001q6ROMIA2" ;
columns = COLUMNS ;



@wire(getAccount,{recordid:'$recordId'}) 
 sharedata ;
     

   
      
}
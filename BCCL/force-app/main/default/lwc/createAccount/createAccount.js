import { LightningElement,api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import ACCOUNT_OBJECT from '@salesforce/schema/Account';
import NAME from '@salesforce/schema/Account.Name';
import UNIQUE_CODE from '@salesforce/schema/Account.Unique_Code__c';
import PHONE from '@salesforce/schema/Account.Phone';
import MOBILE from '@salesforce/schema/Account.rsp_Mobile__c';

const TITLE_SUCCESS = 'Case Created!';
const MESSAGE_SUCCESS = 'You have successfully created a Case';


export default class CreateAccount extends LightningElement {
   
     

    accountobject = ACCOUNT_OBJECT ;
    name = NAME;
    uniquecode = UNIQUE_CODE ;
    phone = PHONE;
    mobile = MOBILE ;
    @api recordId   ;
    handleCaseCreated()
    {
        alert("handleCaseCreated");
        const evt = new ShowToastEvent({
            title: "SUCCESS",
            message: "SAVED",
            variant: 'success'
        });
        this.dispatchEvent(evt);
        //reset the form
        const inputFields = this.template.querySelectorAll(
            'lightning-input-field'
        ); 
        if (inputFields) {
            inputFields.forEach(field => {
                field.reset();
            });
        }

       // const refreshEvt = new CustomEvent('refresh');
        // Fire the custom event
      // this.dispatchEvent(refreshEvt);
    }

}
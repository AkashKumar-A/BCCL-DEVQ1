import { LightningElement ,api,wire } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';

import NAME_FIELD from '@salesforce/schema/Opportunity.Id';

 
//const NAME_FIELD = 'Opportunity.Name';


const bear_fields =[NAME_FIELD ];


export default class DisplayDetail extends LightningElement {

    @api recordId ;
    
    @wire(getRecord, { recordId: '$recordId', fields: bear_fields })
    bear;  
    
   
    get name()
    {

        return getFieldValue(this.bear.data,NAME_FIELD);
    }
    
     get  cardTitle()
     {

        return 'Opportunity  Page';
     }
       
     

 
}
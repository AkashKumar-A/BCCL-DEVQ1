import { LightningElement,wire,api } from 'lwc';
import realtedOppOrderInDealId from '@salesforce/messageChannel/realtedOppOrderInDealId__c';
import {publish, MessageContext} from 'lightning/messageService';
export default class LmsPublisher extends LightningElement {
  dataToSend;
@api recordId;

@wire(MessageContext)
context;

  changeHandler(event){
      this.dataToSend = event.target.value;
  }

  publisherHandler(event){
      let message = {ridDeal: this.recordId};
      publish(this.context,realtedOppOrderInDealId,message);
  }  

}
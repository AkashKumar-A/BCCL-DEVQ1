import { LightningElement,wire } from 'lwc';
import realtedOppOrderInDealId from '@salesforce/messageChannel/realtedOppOrderInDealId__c';
import {subscribe, unsubscribe, MessageContext} from 'lightning/messageService';
export default class LmsSubscriber extends LightningElement {
dataToReceived;

@wire(MessageContext)
context;

connectedCallback() {
    this.handelSubscriber();
}

handelSubscriber(){
    this.subscription = subscribe(this.context,realtedOppOrderInDealId,(message)=>{
        this.dataToReceived = message.ridDeal? message.ridDeal : 'No message published';
    });
}
unsubscribeMessage(){
    unsubscribe(this.subscription) 
      this.subscription =null;
}
}
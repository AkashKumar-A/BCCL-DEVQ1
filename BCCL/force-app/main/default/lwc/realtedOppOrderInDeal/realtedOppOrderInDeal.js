import { LightningElement,wire,api,track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import fetchOrder from '@salesforce/apex/RealtedOppOrderInDeal.callDealRealtedOpp';

export default class RealtedOppOrderInDeal extends NavigationMixin(LightningElement) {

@api recordId;
@track getOrderList = [];
@track displayList = [];
showOrders = false;
orderSize = 0;
comparesize = 0;
dontshow = false;
@track isVisible =false;

  @wire(fetchOrder,{rid : '$recordId'})
  orderList({data,error}){
    if(data){
        console.log('Start Wire');
        this.getOrderList = JSON.parse(data);
        console.log(typeof this.getOrderList);
        console.log('Data -->'+this.getOrderList);
        this.error=undefined;
        this.comparesize = this.getOrderList.length;
        this.orderSize = (this.getOrderList.length < 3 ?this.getOrderList.length:"3+");
        this.displayList = [...this.getOrderList].splice(0,3);

        if(this.comparesize > 0){
          this.showOrders =true;
        }
    }
    else if(error){
        console.log(error);
        this.data=undefined;
    }

  }

  handleGotoOrderDetail(event){
    console.log('load 1')
   
    this.ridOrder = event.target.dataset.item;
    this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.ridOrder,
                objectApiName : 'Order',
                actionName:'view'
            }
        })
  }

  handleGotoRelatedList(event){

   console.log('rid nav 1:-->'+this.recordId);
    this[NavigationMixin.Navigate]({
      //type: "standard__webPage",
      type: "standard__component",
      attributes: {
        componentName: "c__customRelatedDealOrderForm"
        //url: "/one/one.app#" + encodedDef
        //recordId: this.recordId       
      },
      state: {
        c__strInput: this.recordId,
      },
    }); 
  }

}
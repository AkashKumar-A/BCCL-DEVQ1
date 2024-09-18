import { LightningElement,wire,api,track } from 'lwc';
//import fetchAllImage from '@salesforce/apex/lead_Image_lwc_apex.fetchListFileImage';
//import callselectedImage from '@salesforce/apex/lead_Image_lwc_apex.callselectedImage';
//import SAVE_DATA from '@salesforce/apex/lead_Image_lwc_apex.saveData';
import { refreshApex } from '@salesforce/apex';
import { RefreshEvent } from 'lightning/refresh';
import {NavigationMixin} from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class Lead_Image_lwc extends NavigationMixin(LightningElement) {
@track listImageLabel = [];
@track selectedValue ='';
@track imageurl;
@api recordId;
/*
@wire (fetchAllImage, {})
getImages({data,error}){
    if(data){
        console.log('Data :-'+data);
        this.listImageLabel = data.map(options => {
            return {
                label : options.label,
                value : options.value
            };
        });
        console.log('setp 2:-->');
    }else if(error){
        this.error = error;
        console.log('Error :-'+error);
    }
}

selectedHandler(event){
    this.selectedValue = event.target.value;
    callselectedImage({imgName: this.selectedValue})
    .then(result => {
        this.imageurl = result;
    })
    .catch(error =>{
        this.error = error;
    })
}

    saveHandle(){
        SAVE_DATA({ee :this.imageurl, rid : this.recordId})
    
        const event1 = new ShowToastEvent({
            title: 'Succesfully Updated Record',
            message: 'Successfully Updated Record',
            variant: 'success',
            mode: 'dismissable'
        });
        this.dispatchEvent(event1);
        this.dispatchEvent(new RefreshEvent());//use to refersh detail page
        console.log('Save 2:-->');
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId:this.recordId,
                objectApiName: 'Lead', // objectApiName is optional
                actionName: 'view'
            }
        })
        return refreshApex(this.imageurl);
    } */
}
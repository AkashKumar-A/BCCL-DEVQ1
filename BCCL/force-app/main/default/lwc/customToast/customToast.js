import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class CustomToast extends LightningElement {

    @api title = 'Sample Title';
    @api message = 'Sample Message';
    @api variant = 'error';

    variantOptions = [
        { label: 'error', value: 'error' },
        { label: 'warning', value: 'warning' },
        { label: 'success', value: 'success' },
        { label: 'info', value: 'info' },
    ];
    variantChange(event)
    {
      this.variant = event.target.value;
      
       
    

    }

    titleChange(event)
    {
     
      this.title =  event.target.value;

    }

    messageChange(event)
    {
        this.message = event.target.value;
    }

    showNotification(event)
    {
         
        if (ShowToastEvent)
        {
         
           
        const evt = new ShowToastEvent({
            title: this.title,
            message: this.message,
            variant: this.variant
        });
        this.dispatchEvent(evt);
        }
    }

}
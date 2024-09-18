import { LightningElement, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getRoleWiseRevenue from '@salesforce/apex/TvpController.getRoleWiseRevenue';


export default class CommittedFixedTabs extends LightningElement {
    // Variables to hold selected month values
    @track spinner = false;
    selectedMonth = '';
    @track tableColumns = [
        { label: 'Role Name', fieldName: 'roleName' },
        { label: 'Role Target', fieldName: 'roleTarget',wrapText: true, hideDefaultActions: true,initialWidth: 100 },
        { label: 'Committed Pipline', fieldName: 'committedPipline' , wrapText: true, hideDefaultActions: true ,initialWidth: 140},
        { label: 'Scheduled to Print', fieldName: 'scheduledtoPrint', wrapText: true, hideDefaultActions: true , initialWidth: 130},
        { label: 'Published', fieldName: 'published', wrapText: true, hideDefaultActions: true,initialWidth: 100 },
        { label: '%Committed Achievement', fieldName: 'preCommittedAchievement', wrapText: true, hideDefaultActions: true, initialWidth: 160 },
        { label: 'Invoice Billed', fieldName: 'invoiceBilled', wrapText: true, hideDefaultActions: true,initialWidth: 100 },
        { label: '%Fixed Achievement', fieldName: 'perFixedAchievement', wrapText: true, hideDefaultActions: true,initialWidth: 150 }
    ];
    @track roleWiseRevenue = [];
    @track userWiseRevenue = [];
    // Month options dynamically generated
    monthOptions;

    connectedCallback() {
        this.generateMonthOptions();
        const today = new Date();
        const currentMonth = (today.getMonth() + 1).toString().padStart(2, '0');
        const currentYear = today.getFullYear();
        this.selectedMonth = `${currentMonth}-${currentYear}`;
        this.spinner = true;
        getRoleWiseRevenue({dateStr:this.selectedMonth})
        .then(res=>{
            this.spinner = false;
            this.roleWiseRevenue = res.roleWise;
            this.userWiseRevenue = res.userWise;
            console.log(JSON.stringify(res,null,2));
            
        })
        .catch(error=>{
            this.spinner = false;
            this.dispatchEvent(new ShowToastEvent({
                title: "Error!",
                message: error.body.message,
                variant: "error"
            }));
        })
        
    }

    handleMonthChange(event) {
        this.selectedMonth = event.target.value;
        this.spinner = true;
        getRoleWiseRevenue({dateStr:this.selectedMonth})
        .then(res=>{
            this.spinner= false;
            this.roleWiseRevenue = res.roleWise;
            this.userWiseRevenue = res.userWise;
            console.log(JSON.stringify(res,null,2));
            
        })
        .catch(error=>{
            this.spinner = false;
            this.dispatchEvent(new ShowToastEvent({
                title: "Error!",
                message: error.body.message,
                variant: "error"
            }));
        })
    }
    generateMonthOptions() {
        // Get the current year
        const today = new Date();
        const currentYear = today.getFullYear();

        // Fiscal year starts in April, so generate months for the fiscal year
        const fiscalYear = today.getMonth() < 3 ? currentYear - 1 : currentYear;
        const nextYear = fiscalYear + 1;

        // Month mapping to generate the MM-YYYY values
        const months = [
            { label: 'April', value: '04' },
            { label: 'May', value: '05' },
            { label: 'June', value: '06' },
            { label: 'July', value: '07' },
            { label: 'August', value: '08' },
            { label: 'September', value: '09' },
            { label: 'October', value: '10' },
            { label: 'November', value: '11' },
            { label: 'December', value: '12' },
            { label: 'January', value: '01' },
            { label: 'February', value: '02' },
            { label: 'March', value: '03' }
        ];

        // Generate month options with MM-YYYY format
        this.monthOptions = [
            ...months.slice(0, 9).map(month => ({
                label: `${month.label} ${fiscalYear}`,
                value: `${month.value}-${fiscalYear}`
            })),
            ...months.slice(9).map(month => ({
                label: `${month.label} ${nextYear}`,
                value: `${month.value}-${nextYear}`
            }))
        ];
    }    
}
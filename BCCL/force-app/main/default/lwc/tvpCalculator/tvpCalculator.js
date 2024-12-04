import { LightningElement, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getRoleWiseRevenue from '@salesforce/apex/TvpController.getRoleWiseRevenue';
import getPayoutPercentage from '@salesforce/apex/TvpController.getPayoutPercentage';
import getTrimester from '@salesforce/apex/TvpController.getTrimester';
import getPayout from '@salesforce/apex/TvpController.getPayout';


export default class CommittedFixedTabs extends LightningElement {
    @track spinner = false;
    selectedMonth = '';
    @track tableColumns = [
        { label: 'Role Name', fieldName: 'roleName' },
        { label: 'Role Target', fieldName: 'roleTarget', wrapText: true, hideDefaultActions: true, initialWidth: 100 },
        { label: 'Scheduled', fieldName: 'scheduledtoPrint', wrapText: true, hideDefaultActions: true, initialWidth: 130 },
        { label: 'Published', fieldName: 'published', wrapText: true, hideDefaultActions: true, initialWidth: 100 },
        { label: 'Invoiced', fieldName: 'invoiceBilled', wrapText: true, hideDefaultActions: true, initialWidth: 100 },
        { label: 'Pipeline P+S+I', fieldName: 'PSI', wrapText: true, hideDefaultActions: true, initialWidth: 140 },
        { label: '% ACHV P+S+I', fieldName: 'prePSI', wrapText: true, hideDefaultActions: true, initialWidth: 160 }
    ];
    @track roleWiseRevenue = [];
    @track userWiseRevenue = [];
    @track previousUserWiseRevenue = [];
    @track previousUserWiseRevenue1 = [];
    @track trimesterWise = [];
    currentIncentive = {};

    monthOptions;

    connectedCallback() {
        this.spinner = true;
        this.generateMonthOptions();
        const today = new Date();
        const currentMonth = today.getMonth() + 1; // JS months are 0-indexed
        const currentYear = today.getFullYear();
        let fiscalYear = currentMonth < 4 ? currentYear - 1 : currentYear;

        const FIRST_MONTH_IN_TRIMESTER = currentMonth <= 3 ? 12 : (currentMonth <= 7 ? 4 : (currentMonth <= 11 ? 8 : 12));
        this.selectedMonth = `${currentMonth}-${currentYear}`;
        getTrimester()
            .then(res => {
                // Format each decimal field to two decimal places for userWise
                res.userWise.forEach(response => {
                    response.roleTarget = parseFloat(response.roleTarget).toFixed(2);
                    response.scheduledtoPrint = parseFloat(response.scheduledtoPrint).toFixed(2);
                    response.published = parseFloat(response.published).toFixed(2);
                    response.invoiceBilled = parseFloat(response.invoiceBilled).toFixed(2);
                    response.PSI = parseFloat(response.PSI).toFixed(2);
                    response.prePSI = parseFloat(response.prePSI).toFixed(2);
                    response.responseIncentive = parseFloat(response.responseIncentive).toFixed(2);
                });

                // Format each decimal field to two decimal places for roleWise
                res.roleWise.forEach(response => {
                    response.roleTarget = parseFloat(response.roleTarget).toFixed(2);
                    response.scheduledtoPrint = parseFloat(response.scheduledtoPrint).toFixed(2);
                    response.published = parseFloat(response.published).toFixed(2);
                    response.invoiceBilled = parseFloat(response.invoiceBilled).toFixed(2);
                    response.PSI = parseFloat(response.PSI).toFixed(2);
                    response.prePSI = parseFloat(response.prePSI).toFixed(2);
                    response.responseIncentive = parseFloat(response.responseIncentive).toFixed(2);
                });

                // console.log(JSON.stringify(res, null, 2));
                this.previousUserWiseRevenue1 = res.userWise;
                this.trimesterWise = res.roleWise;
            })
            .catch(error => {
                console.log(error);
            });

        getRoleWiseRevenue({ dateStr: this.selectedMonth })
            .then(res => {
                res.userWise.forEach(response => {
                    response.roleTarget = parseFloat(response.roleTarget).toFixed(2);
                    response.scheduledtoPrint = parseFloat(response.scheduledtoPrint).toFixed(2);
                    response.published = parseFloat(response.published).toFixed(2);
                    response.invoiceBilled = parseFloat(response.invoiceBilled).toFixed(2);
                    response.PSI = parseFloat(response.PSI).toFixed(2);
                    response.prePSI = parseFloat(response.prePSI).toFixed(2);
                    response.responseIncentive = parseFloat(response.responseIncentive).toFixed(2);
                });
                res.roleWise.forEach(response => {
                    response.roleTarget = parseFloat(response.roleTarget).toFixed(2);
                    response.scheduledtoPrint = parseFloat(response.scheduledtoPrint).toFixed(2);
                    response.published = parseFloat(response.published).toFixed(2);
                    response.invoiceBilled = parseFloat(response.invoiceBilled).toFixed(2);
                    response.PSI = parseFloat(response.PSI).toFixed(2);
                    response.prePSI = parseFloat(response.prePSI).toFixed(2);
                    response.responseIncentive = parseFloat(response.responseIncentive).toFixed(2);
                });
                this.userWiseRevenue = res.userWise;
                this.roleWiseRevenue = res.roleWise;
                

            })
            .catch(error => {
                this.spinner = false;
                console.log(JSON.stringify(error, null, 2));

            })
        setTimeout(() => {
            // Create the TrimesterWrapper-like object
            const trimesterWrapper = {
                T1: 'T1',
                t1value: 0,
                T2: 'T2',
                t2value: 0,
                T3: 'T3',
                t3value: 0
            };

            // Populate the TrimesterWrapper object based on trimesterWise
            this.trimesterWise.forEach(item => {
                if (item.trimesterName.includes('T1')) {
                    console.log(item.trimesterName, 't111');

                    trimesterWrapper.t1value = item.responseIncentive || 0;
                } else if (item.trimesterName.includes('T2')) {
                    console.log(item.trimesterName, 't22');
                    trimesterWrapper.t2value = item.responseIncentive || 0;
                } else if (item.trimesterName.includes('T3')) {
                    console.log(item.trimesterName, 't3');
                    trimesterWrapper.t3value = item.responseIncentive || 0;
                }
            });

            // Log the original list to confirm it's unchanged
            console.log("Original List:");
            console.log(this.trimesterWise);

            // Log the new TrimesterWrapper object
            console.log("TrimesterWrapper Object:");
            console.log(trimesterWrapper);
            const trimesterWrapperJson = JSON.stringify(trimesterWrapper);

            // Call the Apex method, passing the serialized string
            getPayout({ trimester: trimesterWrapperJson })
                .then((res) => {
                // Format the response values to 2 decimal places
                this.currentIncentive = {
                    t1value: (res.t1value || 0).toFixed(2),
                    t2value: (res.t2value || 0).toFixed(2),
                    t3value: (res.t3value || 0).toFixed(2),
                    t1fullPayout: (res.t1fullPayout || 0).toFixed(2),
                    t2fullPayout: (res.t2fullPayout || 0).toFixed(2),
                    t3fullPayout: (res.t3fullPayout || 0).toFixed(2),
                    t1extraPayout: (res.t1extraPayout || 0).toFixed(2),
                    t2extraPayout: (res.t2extraPayout || 0).toFixed(2),
                    t3extraPayout: (res.t3extraPayout || 0).toFixed(2),
                    
                };
                this.trimesterWise = this.trimesterWise.map(item => {
                    let assignedIncentive = 0;
                    let fullIncentive = 0;
                    let extraIncentive = 0;
        
                    // Assign the appropriate incentive value based on the trimester
                    if (item.trimesterName.includes('T1')) {
                        assignedIncentive = this.currentIncentive.t1value;
                        fullIncentive = this.currentIncentive.t1fullPayout;
                        extraIncentive = this.currentIncentive.t1extraPayout;
                    } else if (item.trimesterName.includes('T2')) {
                        assignedIncentive = this.currentIncentive.t2value;
                        fullIncentive = this.currentIncentive.t2fullPayout;
                        extraIncentive = this.currentIncentive.t2extraPayout;
                    } else if (item.trimesterName.includes('T3')) {
                        assignedIncentive = this.currentIncentive.t3value;
                        fullIncentive = this.currentIncentive.t3fullPayout;
                        extraIncentive = this.currentIncentive.t3extraPayout;
                    }
        
                    // Return the modified item with assignedIncentive field
                    return { ...item, assignedIncentive, fullIncentive , extraIncentive };
                });
        
                this.spinner = false;
                })
                .catch((error) => {
                    this.spinner = false;
                    console.error('Error calling Apex method:', error);
                    this.dispatchEvent(new ShowToastEvent({
                        title: "Error!",
                        message: error.body.message,
                        variant: "error"
                    }));
                });
        }, 3000);

    }


    handleMonthChange(event) {
        this.selectedMonth = event.target.value;
        this.spinner = true;
        getRoleWiseRevenue({ dateStr: this.selectedMonth })
            .then(res => {
                res.userWise.forEach(response => {
                    response.roleTarget = parseFloat(response.roleTarget).toFixed(2);
                    response.scheduledtoPrint = parseFloat(response.scheduledtoPrint).toFixed(2);
                    response.published = parseFloat(response.published).toFixed(2);
                    response.invoiceBilled = parseFloat(response.invoiceBilled).toFixed(2);
                    response.PSI = parseFloat(response.PSI).toFixed(2);
                    response.prePSI = parseFloat(response.prePSI).toFixed(2);
                    response.responseIncentive = parseFloat(response.responseIncentive).toFixed(2);
                });
                res.roleWise.forEach(response => {
                    response.roleTarget = parseFloat(response.roleTarget).toFixed(2);
                    response.scheduledtoPrint = parseFloat(response.scheduledtoPrint).toFixed(2);
                    response.published = parseFloat(response.published).toFixed(2);
                    response.invoiceBilled = parseFloat(response.invoiceBilled).toFixed(2);
                    response.PSI = parseFloat(response.PSI).toFixed(2);
                    response.prePSI = parseFloat(response.prePSI).toFixed(2);
                    response.responseIncentive = parseFloat(response.responseIncentive).toFixed(2);
                });
                this.userWiseRevenue = res.userWise;
                this.roleWiseRevenue = res.roleWise;
                this.spinner = false;

            })
            .catch(error => {
                this.spinner = false;
                console.log(JSON.stringify(error, null, 2));

            })
    }
    generateMonthOptions() {
        const today = new Date();
        const currentYear = today.getFullYear();
        const fiscalYear = today.getMonth() < 3 ? currentYear - 1 : currentYear;
        const nextYear = fiscalYear + 1;
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
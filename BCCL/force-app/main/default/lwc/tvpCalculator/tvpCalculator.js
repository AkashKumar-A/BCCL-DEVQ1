import { LightningElement, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getRoleWiseRevenue from '@salesforce/apex/TvpController.getRoleWiseRevenue';
import getPayoutPercentage from '@salesforce/apex/TvpController.getPayoutPercentage';


export default class CommittedFixedTabs extends LightningElement {
    @track spinner = false;
    selectedMonth = '';
    @track tableColumns = [
        { label: 'Role Name', fieldName: 'roleName' },
        { label: 'Role Target', fieldName: 'roleTarget', wrapText: true, hideDefaultActions: true, initialWidth: 100 },
        { label: 'Pipeline P+S', fieldName: 'committedPipline', wrapText: true, hideDefaultActions: true, initialWidth: 140 },
        { label: 'Scheduled to Print', fieldName: 'scheduledtoPrint', wrapText: true, hideDefaultActions: true, initialWidth: 130 },
        { label: 'Published', fieldName: 'published', wrapText: true, hideDefaultActions: true, initialWidth: 100 },
        { label: '% ACHV P+S', fieldName: 'preCommittedAchievement', wrapText: true, hideDefaultActions: true, initialWidth: 160 },
        { label: 'Invoice Billed', fieldName: 'invoiceBilled', wrapText: true, hideDefaultActions: true, initialWidth: 100 },
        { label: '% ACHV', fieldName: 'perFixedAchievement', wrapText: true, hideDefaultActions: true, initialWidth: 150 }
    ];
    @track roleWiseRevenue = [];
    @track userWiseRevenue = [];
    @track previousUserWiseRevenue = [];
    monthOptions;

    connectedCallback() {
        this.generateMonthOptions();
        // Get the current year and month
        const today = new Date();
        const currentMonth = today.getMonth() + 1; // JS months are 0-indexed
        const currentYear = today.getFullYear();
        // Fiscal year starts in April
        const fiscalYear = currentMonth < 4 ? currentYear - 1 : currentYear;

        const FIRST_MONTH_IN_TRIMESTER = currentMonth <= 3 ? 12 : (currentMonth <= 7 ? 4 : (currentMonth <= 11 ? 8 : 12));
        // Array to hold month values from April to the current month
        let monthsToQuery = [];
        this.selectedMonth = `${currentMonth}-${currentYear}`;
        // Add months from First Month of the Current Trimester to December for the fiscal year
        for (let month = FIRST_MONTH_IN_TRIMESTER; month <= 12; month++) {
            if (month <= currentMonth || fiscalYear < currentYear) {
                monthsToQuery.push(`${month.toString().padStart(2, '0')}-${fiscalYear}`);
            }
        }

        // Add months from January to the current month of the next year if applicable
        if (currentMonth < 4) {
            for (let month = 1; month <= currentMonth; month++) {
                monthsToQuery.push(`${month.toString().padStart(2, '0')}-${currentYear}`);
            }
        }

        console.log('Months to query:', monthsToQuery); // Log the months

        this.spinner = true;
        let allRevenues = [];
        let accumulatedRoleWise = [];
        let accumulatedUserWise = [];

        // Separate the current month
        const currentMonthKey = `${currentMonth.toString().padStart(2, '0')}-${currentYear}`;
        this.selectedMonth = currentMonthKey;
        // Fetch data for each month
        Promise.all(
            monthsToQuery.map(month => {
                console.log('Querying for month:', month); // Log each month before the query
                return getRoleWiseRevenue({ dateStr: month });
            })
        )
            .then((responses) => {
                console.log('All responses:', responses); // Log all responses

                this.spinner = false;

                // Temporary accumulators for summing values
                let totalRoleWise = {
                    roleTarget: 0,
                    committedPipline: 0,
                    scheduledtoPrint: 0,
                    published: 0,
                    preCommittedAchievement: 0,
                    invoiceBilled: 0,
                    perFixedAchievement: 0
                };

                let totalUserWise = {
                    roleTarget: 0,
                    committedPipline: 0,
                    scheduledtoPrint: 0,
                    published: 0,
                    preCommittedAchievement: 0,
                    invoiceBilled: 0,
                    perFixedAchievement: 0,
                    fixedIncentivePayout: 0,
                    projectedIncentivePayout: 0
                };

                // Process responses month by month
                responses.forEach((res, index) => {
                    const month = monthsToQuery[index];
                    console.log(`Response for ${month}:`, res); // Log the response for each month

                    // Check if the month is the current month or previous months
                    if (month === currentMonthKey) {
                        // Process current month data separately
                        this.roleWiseRevenue = res.roleWise.map(item => ({
                            ...item,
                            roleTarget: item.roleTarget ? item.roleTarget.toFixed(2) : '0.00',
                            committedPipline: item.committedPipline ? item.committedPipline.toFixed(2) : '0.00',
                            scheduledtoPrint: item.scheduledtoPrint ? item.scheduledtoPrint.toFixed(2) : '0.00',
                            published: item.published ? item.published.toFixed(2) : '0.00',
                            preCommittedAchievement: item.preCommittedAchievement ? item.preCommittedAchievement.toFixed(2) : '0.00',
                            invoiceBilled: item.invoiceBilled ? item.invoiceBilled.toFixed(2) : '0.00',
                            perFixedAchievement: item.perFixedAchievement ? item.perFixedAchievement.toFixed(2) : '0.00',
                        }));
                        this.userWiseRevenue = res.userWise.map(item => ({
                            ...item,
                            roleTarget: item.roleTarget ? item.roleTarget.toFixed(2) : '0.00',
                            committedPipline: item.committedPipline ? item.committedPipline.toFixed(2) : '0.00',
                            scheduledtoPrint: item.scheduledtoPrint ? item.scheduledtoPrint.toFixed(2) : '0.00',
                            published: item.published ? item.published.toFixed(2) : '0.00',
                            preCommittedAchievement: item.preCommittedAchievement ? item.preCommittedAchievement.toFixed(2) : '0.00',
                            invoiceBilled: item.invoiceBilled ? item.invoiceBilled.toFixed(2) : '0.00',
                            perFixedAchievement: item.perFixedAchievement ? item.perFixedAchievement.toFixed(2) : '0.00',
                            fixedIncentivePayout: item.fixedIncentivePayout ? item.fixedIncentivePayout.toFixed(2) : '0.00',
                            projectedIncentivePayout: item.projectedIncentivePayout ? item.projectedIncentivePayout.toFixed(2) : '0.00',
                        }));
                    } else {
                        // Accumulate previous months data
                        let roleWise = res.roleWise.map(item => {
                            totalRoleWise.roleTarget += item.roleTarget || 0;
                            totalRoleWise.committedPipline += item.committedPipline || 0;
                            totalRoleWise.scheduledtoPrint += item.scheduledtoPrint || 0;
                            totalRoleWise.published += item.published || 0;
                            totalRoleWise.preCommittedAchievement += item.preCommittedAchievement || 0;
                            totalRoleWise.invoiceBilled += item.invoiceBilled || 0;
                            totalRoleWise.perFixedAchievement += item.perFixedAchievement || 0;

                            return {
                                ...item,
                                roleTarget: item.roleTarget ? item.roleTarget.toFixed(2) : '0.00',
                                committedPipline: item.committedPipline ? item.committedPipline.toFixed(2) : '0.00',
                                scheduledtoPrint: item.scheduledtoPrint ? item.scheduledtoPrint.toFixed(2) : '0.00',
                                published: item.published ? item.published.toFixed(2) : '0.00',
                                preCommittedAchievement: item.preCommittedAchievement ? item.preCommittedAchievement.toFixed(2) : '0.00',
                                invoiceBilled: item.invoiceBilled ? item.invoiceBilled.toFixed(2) : '0.00',
                                perFixedAchievement: item.perFixedAchievement ? item.perFixedAchievement.toFixed(2) : '0.00',
                            };
                        });

                        let userWise = res.userWise.map(item => {
                            totalUserWise.roleTarget += item.roleTarget || 0;
                            totalUserWise.committedPipline += item.committedPipline || 0;
                            totalUserWise.scheduledtoPrint += item.scheduledtoPrint || 0;
                            totalUserWise.published += item.published || 0;
                            totalUserWise.preCommittedAchievement += item.preCommittedAchievement || 0;
                            totalUserWise.invoiceBilled += item.invoiceBilled || 0;
                            totalUserWise.perFixedAchievement += item.perFixedAchievement || 0;
                            totalUserWise.fixedIncentivePayout += item.fixedIncentivePayout || 0;
                            totalUserWise.projectedIncentivePayout += item.projectedIncentivePayout || 0;

                            return {
                                ...item,
                                roleTarget: item.roleTarget ? item.roleTarget.toFixed(2) : '0.00',
                                committedPipline: item.committedPipline ? item.committedPipline.toFixed(2) : '0.00',
                                scheduledtoPrint: item.scheduledtoPrint ? item.scheduledtoPrint.toFixed(2) : '0.00',
                                published: item.published ? item.published.toFixed(2) : '0.00',
                                preCommittedAchievement: item.preCommittedAchievement ? item.preCommittedAchievement.toFixed(2) : '0.00',
                                invoiceBilled: item.invoiceBilled ? item.invoiceBilled.toFixed(2) : '0.00',
                                perFixedAchievement: item.perFixedAchievement ? item.perFixedAchievement.toFixed(2) : '0.00',
                                fixedIncentivePayout: item.fixedIncentivePayout ? item.fixedIncentivePayout.toFixed(2) : '0.00',
                                projectedIncentivePayout: item.projectedIncentivePayout ? item.projectedIncentivePayout.toFixed(2) : '0.00',
                            };
                        });

                        // Add to the accumulated role-wise and user-wise lists
                        accumulatedRoleWise.push(roleWise);
                        accumulatedUserWise.push(userWise);
                    }
                });

                // Sum of previous months for role-wise revenue
                this.previousRoleWiseRevenue = {
                    roleTarget: totalRoleWise.roleTarget.toFixed(2),
                    committedPipline: totalRoleWise.committedPipline.toFixed(2),
                    scheduledtoPrint: totalRoleWise.scheduledtoPrint.toFixed(2),
                    published: totalRoleWise.published.toFixed(2),
                    preCommittedAchievement: ((totalRoleWise.roleTarget.toFixed(2) / totalRoleWise.preCommittedAchievement.toFixed(2)) * 100).toFixed(2),
                    invoiceBilled: totalRoleWise.invoiceBilled.toFixed(2),
                    perFixedAchievement: ((totalRoleWise.roleTarget.toFixed(2) / totalRoleWise.invoiceBilled.toFixed(2)) * 100).toFixed(2)
                };

                // Sum of previous months for user-wise revenue
                this.previousUserWiseRevenue = {
                    roleTarget: totalUserWise.roleTarget.toFixed(2),
                    committedPipline: totalUserWise.committedPipline.toFixed(2),
                    scheduledtoPrint: totalUserWise.scheduledtoPrint.toFixed(2),
                    published: totalUserWise.published.toFixed(2),
                    preCommittedAchievement: (((totalUserWise.committedPipline) ?? 0)*100/((totalUserWise.roleTarget !=0 ? totalUserWise.roleTarget:1) ?? 1)).toFixed(2),
                    invoiceBilled: totalUserWise.invoiceBilled.toFixed(2),
                    perFixedAchievement: (((totalUserWise.invoiceBilled ?? 0) *100)/((totalUserWise.roleTarget !=0 ? totalUserWise.roleTarget:1) ?? 1)).toFixed(2),
                    fixedIncentivePayout: totalUserWise.fixedIncentivePayout.toFixed(2),
                    projectedIncentivePayout: totalUserWise.projectedIncentivePayout.toFixed(2)
                };
                getPayoutPercentage({dateStr:this.selectedMonth, percentage: this.previousUserWiseRevenue.preCommittedAchievement})
                .then(res=>{
                    this.previousUserWiseRevenue.projectedIncentivePayout = (res ?? 0).toFixed(2);
                })
                getPayoutPercentage({dateStr:this.selectedMonth, percentage: this.previousUserWiseRevenue.perFixedAchievement})
                .then(res=>{
                    this.previousUserWiseRevenue.fixedIncentivePayout = (res ?? 0).toFixed(2);
                })
                .catch(error => {
                    this.spinner = false;
                    console.error('Error:', error); // Log any errors that occur
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error!',
                            message: error.body.message,
                            variant: 'error'
                        })
                    );
                });
                console.log('Previous Role Wise Revenue:', this.previousRoleWiseRevenue); // Log previous role-wise revenue
                console.log('Previous User Wise Revenue:', this.previousUserWiseRevenue); // Log previous user-wise revenue
            })
            .catch(error => {
                this.spinner = false;
                console.error('Error:', error); // Log any errors that occur
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error!',
                        message: error.body.message,
                        variant: 'error'
                    })
                );
            });
    }


    handleMonthChange(event) {
        this.selectedMonth = event.target.value;
        console.log(this.selectedMonth); // Debugging line

        const selectedMonthYear = this.selectedMonth.split('-');
        const selectedMonth = parseInt(selectedMonthYear[0]); // Month as a number (e.g., '06' becomes 6)
        const selectedYear = parseInt(selectedMonthYear[1]); // Year as a number (e.g., '2024')

        // Fiscal year logic
        const currentMonth = selectedMonth; // Use the month selected
        const currentYear = selectedYear;
        const FIRST_MONTH_IN_TRIMESTER = currentMonth <= 3 ? 12 : (currentMonth <= 7 ? 4 : (currentMonth <= 11 ? 8 : 12));
        console.log('FIRST_MONTH_IN_TRIMESTER ==>', FIRST_MONTH_IN_TRIMESTER);
        console.log('currentMonth ==>', currentMonth);

        let monthsToQuery = [];

        // Determine fiscal year
        const fiscalYear = currentMonth < 4 ? currentYear - 1 : currentYear;

        // Collect months from First Month of the trimester up to the selected month
        for (let month = FIRST_MONTH_IN_TRIMESTER; month <= 12; month++) {
            monthsToQuery.push(`${month.toString().padStart(2, '0')}-${fiscalYear}`);
        }

        // If selected month is before April, add months from January to the selected month of the next fiscal year
        if (currentMonth < 4) {
            for (let month = 1; month <= currentMonth; month++) {
                monthsToQuery.push(`${month.toString().padStart(2, '0')}-${currentYear}`);
            }
        }

        console.log('Months to query:', monthsToQuery); // Log the months

        this.spinner = true;
        let allRevenues = [];
        let accumulatedRoleWise = [];
        let accumulatedUserWise = [];

        // Separate the current month
        const currentMonthKey = `${currentMonth.toString().padStart(2, '0')}-${currentYear}`;
        this.selectedMonth = currentMonthKey;
        // Fetch data for each month
        Promise.all(
            monthsToQuery.map(month => {
                console.log('Querying for month:', month); // Log each month before the query
                return getRoleWiseRevenue({ dateStr: month });
            })
        )
            .then((responses) => {
                console.log('All responses:', responses); // Log all responses

                this.spinner = false;

                // Temporary accumulators for summing values
                let totalRoleWise = {
                    roleTarget: 0,
                    committedPipline: 0,
                    scheduledtoPrint: 0,
                    published: 0,
                    preCommittedAchievement: 0,
                    invoiceBilled: 0,
                    perFixedAchievement: 0
                };

                let totalUserWise = {
                    roleTarget: 0,
                    committedPipline: 0,
                    scheduledtoPrint: 0,
                    published: 0,
                    preCommittedAchievement: 0,
                    invoiceBilled: 0,
                    perFixedAchievement: 0,
                    fixedIncentivePayout: 0,
                    projectedIncentivePayout: 0
                };

                // Process responses month by month
                responses.forEach((res, index) => {
                    const month = monthsToQuery[index];
                    console.log(`Response for ${month}:`, res); // Log the response for each month

                    // Check if the month is the current month or previous months
                    if (month === currentMonthKey) {
                        // Process current month data separately
                        this.roleWiseRevenue = res.roleWise.map(item => ({
                            ...item,
                            roleTarget: item.roleTarget ? item.roleTarget.toFixed(2) : '0.00',
                            committedPipline: item.committedPipline ? item.committedPipline.toFixed(2) : '0.00',
                            scheduledtoPrint: item.scheduledtoPrint ? item.scheduledtoPrint.toFixed(2) : '0.00',
                            published: item.published ? item.published.toFixed(2) : '0.00',
                            preCommittedAchievement: item.preCommittedAchievement ? item.preCommittedAchievement.toFixed(2) : '0.00',
                            invoiceBilled: item.invoiceBilled ? item.invoiceBilled.toFixed(2) : '0.00',
                            perFixedAchievement: item.perFixedAchievement ? item.perFixedAchievement.toFixed(2) : '0.00',
                        }));
                        this.userWiseRevenue = res.userWise.map(item => ({
                            ...item,
                            roleTarget: item.roleTarget ? item.roleTarget.toFixed(2) : '0.00',
                            committedPipline: item.committedPipline ? item.committedPipline.toFixed(2) : '0.00',
                            scheduledtoPrint: item.scheduledtoPrint ? item.scheduledtoPrint.toFixed(2) : '0.00',
                            published: item.published ? item.published.toFixed(2) : '0.00',
                            preCommittedAchievement: item.preCommittedAchievement ? item.preCommittedAchievement.toFixed(2) : '0.00',
                            invoiceBilled: item.invoiceBilled ? item.invoiceBilled.toFixed(2) : '0.00',
                            perFixedAchievement: item.perFixedAchievement ? item.perFixedAchievement.toFixed(2) : '0.00',
                            fixedIncentivePayout: item.fixedIncentivePayout ? item.fixedIncentivePayout.toFixed(2) : '0.00',
                            projectedIncentivePayout: item.projectedIncentivePayout ? item.projectedIncentivePayout.toFixed(2) : '0.00',
                        }));
                    } else {
                        // Accumulate previous months data
                        let roleWise = res.roleWise.map(item => {
                            totalRoleWise.roleTarget += item.roleTarget || 0;
                            totalRoleWise.committedPipline += item.committedPipline || 0;
                            totalRoleWise.scheduledtoPrint += item.scheduledtoPrint || 0;
                            totalRoleWise.published += item.published || 0;
                            totalRoleWise.preCommittedAchievement += item.preCommittedAchievement || 0;
                            totalRoleWise.invoiceBilled += item.invoiceBilled || 0;
                            totalRoleWise.perFixedAchievement += item.perFixedAchievement || 0;

                            return {
                                ...item,
                                roleTarget: item.roleTarget ? item.roleTarget.toFixed(2) : '0.00',
                                committedPipline: item.committedPipline ? item.committedPipline.toFixed(2) : '0.00',
                                scheduledtoPrint: item.scheduledtoPrint ? item.scheduledtoPrint.toFixed(2) : '0.00',
                                published: item.published ? item.published.toFixed(2) : '0.00',
                                preCommittedAchievement: item.preCommittedAchievement ? item.preCommittedAchievement.toFixed(2) : '0.00',
                                invoiceBilled: item.invoiceBilled ? item.invoiceBilled.toFixed(2) : '0.00',
                                perFixedAchievement: item.perFixedAchievement ? item.perFixedAchievement.toFixed(2) : '0.00',
                            };
                        });

                        let userWise = res.userWise.map(item => {
                            totalUserWise.roleTarget += item.roleTarget || 0;
                            totalUserWise.committedPipline += item.committedPipline || 0;
                            totalUserWise.scheduledtoPrint += item.scheduledtoPrint || 0;
                            totalUserWise.published += item.published || 0;
                            totalUserWise.preCommittedAchievement += item.preCommittedAchievement || 0;
                            totalUserWise.invoiceBilled += item.invoiceBilled || 0;
                            totalUserWise.perFixedAchievement += item.perFixedAchievement || 0;
                            totalUserWise.fixedIncentivePayout += item.fixedIncentivePayout || 0;
                            totalUserWise.projectedIncentivePayout += item.projectedIncentivePayout || 0;

                            return {
                                ...item,
                                roleTarget: item.roleTarget ? item.roleTarget.toFixed(2) : '0.00',
                                committedPipline: item.committedPipline ? item.committedPipline.toFixed(2) : '0.00',
                                scheduledtoPrint: item.scheduledtoPrint ? item.scheduledtoPrint.toFixed(2) : '0.00',
                                published: item.published ? item.published.toFixed(2) : '0.00',
                                preCommittedAchievement: item.preCommittedAchievement ? item.preCommittedAchievement.toFixed(2) : '0.00',
                                invoiceBilled: item.invoiceBilled ? item.invoiceBilled.toFixed(2) : '0.00',
                                perFixedAchievement: item.perFixedAchievement ? item.perFixedAchievement.toFixed(2) : '0.00',
                                fixedIncentivePayout: item.fixedIncentivePayout ? item.fixedIncentivePayout.toFixed(2) : '0.00',
                                projectedIncentivePayout: item.projectedIncentivePayout ? item.projectedIncentivePayout.toFixed(2) : '0.00',
                            };
                        });

                        // Add to the accumulated role-wise and user-wise lists
                        accumulatedRoleWise.push(roleWise);
                        accumulatedUserWise.push(userWise);
                    }
                });

                // Sum of previous months for role-wise revenue
                this.previousRoleWiseRevenue = {
                    roleTarget: totalRoleWise.roleTarget.toFixed(2),
                    committedPipline: totalRoleWise.committedPipline.toFixed(2),
                    scheduledtoPrint: totalRoleWise.scheduledtoPrint.toFixed(2),
                    published: totalRoleWise.published.toFixed(2),
                    preCommittedAchievement: ((totalRoleWise.roleTarget.toFixed(2) / totalRoleWise.preCommittedAchievement.toFixed(2)) * 100).toFixed(2),
                    invoiceBilled: totalRoleWise.invoiceBilled.toFixed(2),
                    perFixedAchievement: ((totalRoleWise.roleTarget.toFixed(2) / totalRoleWise.invoiceBilled.toFixed(2)) * 100).toFixed(2)
                };
                console.log('user----'+(((totalUserWise.committedPipline) ?? 0)*100 +'  '+ ((totalUserWise.roleTarget ==0?1:totalUserWise.roleTarget) ?? 1)));
                
                console.log(JSON.stringify(totalUserWise,null,2));
                
                // Sum of previous months for user-wise revenue
                this.previousUserWiseRevenue = {
                    roleTarget: totalUserWise.roleTarget.toFixed(2),
                    committedPipline: totalUserWise.committedPipline.toFixed(2),
                    scheduledtoPrint: totalUserWise.scheduledtoPrint.toFixed(2),
                    published: totalUserWise.published.toFixed(2),
                    preCommittedAchievement: (((totalUserWise.committedPipline) ?? 0)*100/((totalUserWise.roleTarget !=0 ? totalUserWise.roleTarget:1) ?? 1)).toFixed(2),
                    invoiceBilled: totalUserWise.invoiceBilled,
                    perFixedAchievement: (((totalUserWise.invoiceBilled ?? 0) *100)/((totalUserWise.roleTarget !=0 ? totalUserWise.roleTarget:1) ?? 1)).toFixed(2),
                    fixedIncentivePayout: totalUserWise.fixedIncentivePayout.toFixed(2),
                    projectedIncentivePayout: totalUserWise.projectedIncentivePayout.toFixed(2)
                };
                getPayoutPercentage({dateStr:this.selectedMonth, percentage: this.previousUserWiseRevenue.preCommittedAchievement})
                .then(res=>{
                    this.previousUserWiseRevenue.projectedIncentivePayout = (res ?? 0).toFixed(2);
                })
                getPayoutPercentage({dateStr:this.selectedMonth, percentage: this.previousUserWiseRevenue.perFixedAchievement})
                .then(res=>{
                    this.previousUserWiseRevenue.fixedIncentivePayout = (res ?? 0).toFixed(2);
                })
                .catch(error => {
                    this.spinner = false;
                    console.error('Error:', error); // Log any errors that occur
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error!',
                            message: error.body.message,
                            variant: 'error'
                        })
                    );
                });
                console.log('Previous Role Wise Revenue:', this.previousRoleWiseRevenue); // Log previous role-wise revenue
                console.log('Previous User Wise Revenue:', this.previousUserWiseRevenue); // Log previous user-wise revenue
            })
            .catch(error => {
                this.spinner = false;
                console.error('Error:', error); // Log any errors that occur
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error!',
                        message: error.body.message,
                        variant: 'error'
                    })
                );
            });


        // this.spinner = true;
        // let allRevenues = [];
        // let accumulatedRoleWise = [];
        // let accumulatedUserWise = [];

        // // Separate the current month
        // const currentMonthKey = `${currentMonth.toString().padStart(2, '0')}-${currentYear}`;
        // this.selectedMonth = currentMonthKey;





        // getRoleWiseRevenue({ dateStr: this.selectedMonth })
        //     .then(res => {
        //         this.spinner = false;
        //         //console.log(JSON.stringify(res,null,2));

        //         // Format roleWiseRevenue decimals to two decimal places
        //         this.roleWiseRevenue = res.roleWise.map(item => ({
        //             ...item,
        //             roleTarget: item.roleTarget ? item.roleTarget.toFixed(2) : '0.00',
        //             committedPipline: item.committedPipline ? item.committedPipline.toFixed(2) : '0.00',
        //             scheduledtoPrint: item.scheduledtoPrint ? item.scheduledtoPrint.toFixed(2) : '0.00',
        //             published: item.published ? item.published.toFixed(2) : '0.00',
        //             preCommittedAchievement: item.preCommittedAchievement ? item.preCommittedAchievement.toFixed(2) : '0.00',
        //             invoiceBilled: item.invoiceBilled ? item.invoiceBilled.toFixed(2) : '0.00',
        //             perFixedAchievement: item.perFixedAchievement ? item.perFixedAchievement.toFixed(2) : '0.00',
        //         }));

        //         // Format userWiseRevenue decimals to two decimal places
        //         this.userWiseRevenue = res.userWise.map(item => ({
        //             ...item,
        //             roleTarget: item.roleTarget ? item.roleTarget.toFixed(2) : '0.00',
        //             committedPipline: item.committedPipline ? item.committedPipline.toFixed(2) : '0.00',
        //             scheduledtoPrint: item.scheduledtoPrint ? item.scheduledtoPrint.toFixed(2) : '0.00',
        //             published: item.published ? item.published.toFixed(2) : '0.00',
        //             preCommittedAchievement: item.preCommittedAchievement ? item.preCommittedAchievement.toFixed(2) : '0.00',
        //             invoiceBilled: item.invoiceBilled ? item.invoiceBilled.toFixed(2) : '0.00',
        //             perFixedAchievement: item.perFixedAchievement ? item.perFixedAchievement.toFixed(2) : '0.00',
        //             fixedIncentivePayout: item.fixedIncentivePayout ? item.fixedIncentivePayout.toFixed(2) : '0.00',
        //             projectedIncentivePayout: item.projectedIncentivePayout ? item.projectedIncentivePayout.toFixed(2) : '0.00',
        //         }));
        //     })
        //     .catch(error => {
        //         this.spinner = false;
        //         this.dispatchEvent(new ShowToastEvent({
        //             title: "Error!",
        //             message: error.body.message,
        //             variant: "error"
        //         }));
        //     });

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
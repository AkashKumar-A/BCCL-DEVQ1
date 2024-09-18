global class bccl_TrackUserActivityBatch implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful{

    global Database.QueryLocator start(Database.BatchableContext BC){
        String query ='select id,profile.userLicense.name from User where profile.userLicense.name=\'Salesforce\' limit 1';
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<User> scope){
        list<bccl_Track_User_Activity__c> trackUserActivityList=new list<bccl_Track_User_Activity__c>();
        
        string LicenseName='';
        date todaysDate=system.today();
        date sixdaysDate=system.today()-7;
        system.debug('sixdaysDate-'+sixdaysDate);
        date thirtydaysDate=system.today()-30;
        system.debug('thirtydaysDate-'+thirtydaysDate);
        date yesterdaysDate=todaysDate-1;
        date previousDate=todaysDate-2;
        

        string stringDate = string.valueOf(previousDate.year()) + '-' + string.valueOf(previousDate.month()) + '-' + string.valueOf(previousDate.day()) + ' ' + '05' + ':' + '30' +  ':' + '00';
        
        string stringDateYesterday = string.valueOf(yesterdaysDate.year()) + '-' + string.valueOf(yesterdaysDate.month()) + '-' + string.valueOf(yesterdaysDate.day()) + ' '  + '05' + ':' + '30' +  ':' + '00';
        
        string stringDateFuture = string.valueOf(yesterdaysDate.year()) + '-' + string.valueOf(yesterdaysDate.month()) + '-' + string.valueOf(yesterdaysDate.day()+1) + ' '  + '05' + ':' + '30' +  ':' + '00';
        
        string string6DatePast = string.valueOf(sixdaysDate.year()) + '-' + string.valueOf(sixdaysDate.month()) + '-' + string.valueOf(sixdaysDate.day()) + ' '  + '05' + ':' + '30' +  ':' + '00';
        
        string string30DatePast = string.valueOf(thirtydaysDate.year()) + '-' + string.valueOf(thirtydaysDate.month()) + '-' + string.valueOf(thirtydaysDate.day()) + ' '  + '05' + ':' + '30' +  ':' + '00';
        
        //dateTime prevDateTime=dateTime.newInstance(previousDate.year(),previousDate.month(),previousDate.day(),05,30,00);
        dateTime prevDateTime=Datetime.valueOf(stringDate);
        String prevIST = prevDateTime.format('yyyy-MM-dd HH:mm:ss', 'IST');
        dateTime prev=Datetime.valueOf(prevIST);
        system.debug('prevDateTime-'+prevDateTime);
        system.debug('prev-'+prev);
        
        
        dateTime todayDateTime=Datetime.valueOf(stringDateYesterday);
        String todayIST = todayDateTime.format('yyyy-MM-dd HH:mm:ss', 'IST');
        dateTime todayDt=Datetime.valueOf(todayIST);
        system.debug('todayDateTime-'+todayDateTime);
        system.debug('todayDt-'+todayDt);
        
        dateTime tommorrowDateTime=Datetime.valueOf(stringDateFuture);
        String tomIST = tommorrowDateTime.format('yyyy-MM-dd HH:mm:ss', 'IST');
        dateTime tomDt=Datetime.valueOf(tomIST);
        system.debug('tommorrowDateTime-'+tommorrowDateTime);
        system.debug('tomDt-'+tomDt);
        
        dateTime sixDateTime=Datetime.valueOf(string6DatePast);
        String sixIST = sixDateTime.format('yyyy-MM-dd HH:mm:ss', 'IST');
        dateTime sixDt=Datetime.valueOf(sixIST);
        system.debug('sixDateTime-'+sixDateTime);
        system.debug('sixDt-'+sixDt);
        
        dateTime thirtyDateTime=Datetime.valueOf(string30DatePast);
        string thirtyIST = thirtyDateTime.format('yyyy-MM-dd HH:mm:ss', 'IST');
        system.debug('thirtyIST-'+thirtyIST);
        dateTime thirtyDt=Datetime.valueOf(thirtyIST);
        system.debug('thirtyDateTime-'+thirtyDateTime);
        system.debug('thirtyDt-'+thirtyDt);
        
        integer totalLicense=0;
        string query=system.label.bccl_License_Query;
        AggregateResult[] groupedResultsForLic = database.query(query);
        /*AggregateResult[] groupedResultsForLic = [Select count(Id), Profile.UserLicenseId,Profile.UserLicense.name From User 
                                                Group By Profile.UserLicenseId,Profile.UserLicense.name];*/
        for (AggregateResult ar : groupedResultsForLic)  
        {
            if(ar.get('Name')=='Salesforce'){
                totalLicense=integer.valueOf(ar.get('expr0'));
                LicenseName=string.valueOf(ar.get('Name'));
            }
        }
        
        integer totalActiveUsers=0;
        AggregateResult[] groupedResultsForActive = [select count(id) from user where isActive=true 
                                                    and Profile.UserLicense.name='Salesforce'];
        for (AggregateResult ar : groupedResultsForActive)  
        {
            totalActiveUsers=integer.valueOf(ar.get('expr0'));
        }
        
        integer countFor30days=0;
        AggregateResult[] groupedResultsFor30 =[select count(id),profile.userLicense.name from user 
                                                where lastlogindate=last_N_days:29
                                                and profile.userLicense.name='Salesforce' 
                                                and isActive=true 
                                                group by profile.userLicense.name];
                                                /*[select count(id),profile.userLicense.name from user 
                                                where lastlogindate>=:thirtyDt and lastlogindate<:tomDt
                                                and profile.userLicense.name='Salesforce' 
                                                and isActive=true 
                                                group by profile.userLicense.name];*/
                                                
        for (AggregateResult ar : groupedResultsFor30)  
        {
            countFor30days=integer.valueOf(ar.get('expr0'));
        }
        
        integer countFor7days=0;
        AggregateResult[] groupedResultsFor7 = [select count(id),profile.userLicense.name from user 
                                                where lastlogindate=last_N_days:6
                                                and profile.userLicense.name='Salesforce' 
                                                and isActive=true 
                                                group by profile.userLicense.name];
                                                /*[select count(id),profile.userLicense.name from user 
                                                where lastlogindate>=:sixDt and lastlogindate<:tomDt
                                                and profile.userLicense.name='Salesforce' 
                                                and isActive=true 
                                                group by profile.userLicense.name];*/
                                                
        for (AggregateResult ar : groupedResultsFor7)  
        {
            countFor7days=integer.valueOf(ar.get('expr0'));
        }

        integer countForyesterday=0;
        AggregateResult[] groupedResultsForYesterday = [select count(id),profile.userLicense.name from user 
                                                where lastlogindate=last_N_days:2
                                                and profile.userLicense.name='Salesforce' 
                                                and isActive=true 
                                                group by profile.userLicense.name];
                                                        /*[select count(id),profile.userLicense.name from user 
                                                where lastlogindate>=:prev and lastlogindate<:todayDt 
                                                and profile.userLicense.name='Salesforce' and isActive=true 
                                                group by profile.userLicense.name];*/
                                                
        for (AggregateResult ar : groupedResultsForYesterday)  
        {
            countForyesterday=integer.valueOf(ar.get('expr0'));
        }
                            
        integer countForToday=0;
        AggregateResult[] groupedResultsForToday = [select count(id),profile.userLicense.name from user 
                                                    where lastlogindate=last_N_days:1
                                                    and profile.userLicense.name='Salesforce' 
                                                    and isActive=true 
                                                    group by profile.userLicense.name];
                                                    /*[select count(id),profile.userLicense.name from user 
                                                        where lastlogindate>=:todayDt and lastlogindate<:tomDt
                                                        and profile.userLicense.name='Salesforce' and isActive=true 
                                                        group by profile.userLicense.name];*/
                                                
        for (AggregateResult ar : groupedResultsForToday)  
        {
            countForToday=integer.valueOf(ar.get('expr0'));
        }

        for(User usr : scope)
        {
            bccl_Track_User_Activity__c trackUserActivity=new bccl_Track_User_Activity__c();
            trackUserActivity.Name=String.ValueOf(yesterdaysDate);
            //trackUserActivity.bccl_Type_Of_User_License__c='Salesforce';
            trackUserActivity.bccl_Type_Of_User_License__c=LicenseName;
            trackUserActivity.bccl_Activity_Date__c=yesterdaysDate;
            trackUserActivity.bccl_Active_SF_User_Count_Yesterday__c=countForyesterday;
            trackUserActivity.bccl_Active_Salesforce_User_Count_Today__c=countForToday;
            trackUserActivity.bccl_Active_SF_User_Count_last_7_days__c=countFor7days;
            trackUserActivity.bccl_Active_SF_User_Count_for_30_days__c=countFor30days;
            trackUserActivity.bccl_Total_Salesforce_License__c=totalLicense;
            trackUserActivity.bccl_Total_Active_Users__c=totalActiveUsers;
            trackUserActivityList.add(trackUserActivity);
        }
        
        if(trackUserActivityList.size()>0)
            insert trackUserActivityList;
        
    }
    
    global void finish(Database.BatchableContext BC){ 
        system.debug('**Job Finished**');
    }
}
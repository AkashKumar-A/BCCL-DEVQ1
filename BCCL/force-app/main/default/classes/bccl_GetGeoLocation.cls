public class bccl_GetGeoLocation{

        @AuraEnabled
        public static decimal testMethodd(decimal latit,decimal longit)
        {
            system.debug('lattitude-'+latit);
            //latit=latit;
            system.debug('longitude-'+longit);
            //longit=longit;
            system.debug('CALLED');
            return latit;
        }

        public string GeoTagValues{ get; set;}
        public string GeoTagCheckIn{ get; set;}
        public string GeoTagCheckOut{ get; set;}
        public string GeoTagOut{ get; set;}
        public string GeoTagIn{ get; set;}
        
        public void testdirect(){
            system.debug(GeoTagValues);
        }
        
        public string OppId{get;set;}
        //public Id eId{get;set;}
        public static decimal latit{get;set;}
        public static decimal longit{get;set;}
        public string callfunc{get;set;}
        public Event EventVal{get;set;}
        public Task TaskVal{get;set;}
        public static string addressVal{get;set;}
        public boolean retrieveAddress{get;set;}
        public boolean checkIn{get;set;}
        public boolean checkOut{get;set;}
        public boolean disableBtn{get;set;}
        public boolean GeoFailed{get;set;}

        public bccl_GetGeoLocation(ApexPages.StandardController controller) {
         
            OppId=controller.getRecord().Id;
            //eId=controller.getRecord().Id;
            system.debug('OppId-'+OppId);
            callfunc='<script> checkIn(); </script>';
            EventVal=new Event();
            TaskVal=new Task();
            addressVal='';
            retrieveAddress=false;
            checkIn=false;
            checkOut=false;
            disableBtn=false;
            GeoTagOut='';
            GeoTagIn='';
            GeoFailed=false;

            if(OppId.startswith('00U'))
            {
               Event ConCheckIn=[select id,bccl_CheckIn_Date_Time__c,bccl_Checkout_Date_time__c,bccl_GeoLocation__latitude__s,
                                bccl_GeoLocation__longitude__s,bccl_Address__c,bccl_Check_In_Address__c,bccl_Check_Out_Address__c
                                from Event where id=:OppId];
                system.debug('ConCheckIn-'+ConCheckIn.bccl_Check_In_Address__c);
                if(!String.isEmpty(ConCheckIn.bccl_Check_In_Address__c)){
                    checkIn=true;
                }
                
            }
            if(OppId.startswith('00T'))
            {
                Task ConCheckIn=[select id,bccl_CheckIn_Date_Time__c,bccl_Checkout_Date_time__c,bccl_GeoLocation__latitude__s,
                                bccl_GeoLocation__longitude__s,bccl_Address__c,bccl_Check_In_Address__c,bccl_Check_Out_Address__c
                                from Task where id=:OppId];
                
                system.debug('ConCheckIn-'+ConCheckIn.bccl_Check_In_Address__c);
                if(!String.isEmpty(ConCheckIn.bccl_Check_In_Address__c))
                    checkIn=true;
            }

            if(OppId.startswith('00U'))
            {
               Event ConCheckIn=[select id,bccl_CheckIn_Date_Time__c,bccl_Checkout_Date_time__c,bccl_GeoLocation__latitude__s,
                                bccl_GeoLocation__longitude__s,bccl_Address__c,bccl_Check_In_Address__c,bccl_Check_Out_Address__c
                                from Event where id=:OppId];

                system.debug('checkOut-'+ConCheckIn.bccl_Check_Out_Address__c);
                if(!String.isEmpty(ConCheckIn.bccl_Check_Out_Address__c))
                    checkOut=true;
                
            }
            if(OppId.startswith('00T'))
            {
                Task ConCheckIn=[select id,bccl_CheckIn_Date_Time__c,bccl_Checkout_Date_time__c,bccl_GeoLocation__latitude__s,
                                bccl_GeoLocation__longitude__s,bccl_Address__c,bccl_Check_In_Address__c,bccl_Check_Out_Address__c
                                from Task where id=:OppId];
                
                system.debug('checkOut-'+ConCheckIn.bccl_Check_Out_Address__c);
                if(!String.isEmpty(ConCheckIn.bccl_Check_Out_Address__c))
                    checkOut=true;
            }
            system.debug('checkOut-'+checkOut);
            system.debug('checkIn-'+checkIn);
        }
        
        public bccl_GetGeoLocation()
        {
            
        }
        
        @AuraEnabled
        public static Event fecthEventRecord(string eId){
            system.debug('eId fetch-'+eId);
            Event ConCheckIn;
            if(eId.startswith('00U'))
            {
                ConCheckIn=[select id,bccl_CheckIn_Date_Time__c,bccl_Checkout_Date_time__c,bccl_GeoLocation__latitude__s,
                                bccl_GeoLocation__longitude__s,bccl_Address__c
                                from Event where id=:eId];
                
            }
            return ConCheckIn;
            /*if(eId.startswith('00T'))
            {
                Task ConCheckIn=[select id,bccl_CheckIn_Date_Time__c,bccl_Checkout_Date_time__c,bccl_GeoLocation__latitude__s,
                                bccl_GeoLocation__longitude__s,bccl_Address__c
                                from Task where id=:eId];
                return ConCheckIn;
            }*/
        }
        
        @AuraEnabled
        public static Task fecthTaskRecord(string eId){
            system.debug('eId fetch-'+eId);
            //if(eId.startswith('00T'))
            //{
                Task ConCheckIn=[select id,bccl_CheckIn_Date_Time__c,bccl_Checkout_Date_time__c,bccl_GeoLocation__latitude__s,
                                bccl_GeoLocation__longitude__s,bccl_Address__c
                                from Task where id=:eId];
                return ConCheckIn;
            //}
        }
        
        @AuraEnabled
        public static string addGeoLocation(string eId, decimal latit, decimal longit){
            system.debug('lattitude-'+latit);
            system.debug('longitude-'+longit);
            system.debug('eId-'+eId);
            
            if(eId.startswith('00U'))
            {
                Event ConCheckIn=[select id,bccl_CheckIn_Date_Time__c,bccl_Checkout_Date_time__c,bccl_GeoLocation__latitude__s,
                                    bccl_GeoLocation__longitude__s,bccl_Address__c,bccl_Check_In_Address__c,bccl_Check_Out_Address__c
                                    from Event where id=:eId];
                                    
                system.debug('ConCheckIn-'+ConCheckIn);
                if(ConCheckIn.bccl_GeoLocation__latitude__s==null)
                    ConCheckIn.bccl_GeoLocation__latitude__s=latit;
                //else if(ConCheckIn.bccl_GeoLocation__latitude__s!=null && ConCheckIn.bccl_GeoLocation__latitude__s!=latit)
                    //ConCheckIn.bccl_GeoLocation__latitude__s=latit;
                
                if(ConCheckIn.bccl_GeoLocation__longitude__s==null)
                    ConCheckIn.bccl_GeoLocation__longitude__s=longit;
                //else if(ConCheckIn.bccl_GeoLocation__longitude__s!=null && ConCheckIn.bccl_GeoLocation__longitude__s!=longit)
                    //ConCheckIn.bccl_GeoLocation__longitude__s=longit;
                
                if(!Test.isRunningTest()){
                    addressVal=fetchAddress(latit,longit);
                    //retrieveAddress=true;
                }

                update ConCheckIn;
            }
            
            if(eId.startswith('00T'))
            {
                Task ConCheckIn=[select id,bccl_CheckIn_Date_Time__c,bccl_Checkout_Date_time__c,bccl_GeoLocation__latitude__s,
                                    bccl_GeoLocation__longitude__s,bccl_Address__c,bccl_Check_In_Address__c,bccl_Check_Out_Address__c
                                    from Task where id=:eId];
                                    
                system.debug('ConCheckIn-'+ConCheckIn);
                if(ConCheckIn.bccl_GeoLocation__latitude__s==null)
                    ConCheckIn.bccl_GeoLocation__latitude__s=latit;
                //else if(ConCheckIn.bccl_GeoLocation__latitude__s!=null && ConCheckIn.bccl_GeoLocation__latitude__s!=latit)
                    //ConCheckIn.bccl_GeoLocation__latitude__s=latit;
                
                if(ConCheckIn.bccl_GeoLocation__longitude__s==null)
                    ConCheckIn.bccl_GeoLocation__longitude__s=longit;
                //else if(ConCheckIn.bccl_GeoLocation__longitude__s!=null && ConCheckIn.bccl_GeoLocation__longitude__s!=longit)
                    //ConCheckIn.bccl_GeoLocation__longitude__s=longit;
                
                if(!Test.isRunningTest()){
                    addressVal=fetchAddress(latit,longit);
                    //retrieveAddress=true;
                }
                
                update ConCheckIn;
            }
            return addressVal;
        }
     
        @AuraEnabled
        public static string addCheckIns(string eId, decimal latit, decimal longit){
            system.debug('lattitude-'+latit);
            system.debug('longitude-'+longit);
            system.debug('eId-'+eId);
            
            if(eId.startswith('00U')){
                Event ConCheckIn=[select id,bccl_CheckIn_Date_Time__c,bccl_Checkout_Date_time__c,bccl_GeoLocation__latitude__s,
                                    bccl_GeoLocation__longitude__s,bccl_Address__c,bccl_Check_In_Address__c,bccl_Check_Out_Address__c
                                    from Event where id=:eId];
                                    
                system.debug('ConCheckIn-'+ConCheckIn);
                ConCheckIn.bccl_CheckIn_Date_Time__c=system.now();
                if(ConCheckIn.bccl_GeoLocation__latitude__s==null)
                    ConCheckIn.bccl_GeoLocation__latitude__s=latit;
                else if(ConCheckIn.bccl_GeoLocation__latitude__s!=null && ConCheckIn.bccl_GeoLocation__latitude__s!=latit)
                    ConCheckIn.bccl_GeoLocation__latitude__s=latit;
                
                if(ConCheckIn.bccl_GeoLocation__longitude__s==null)
                    ConCheckIn.bccl_GeoLocation__longitude__s=longit;
                else if(ConCheckIn.bccl_GeoLocation__longitude__s!=null && ConCheckIn.bccl_GeoLocation__longitude__s!=longit)
                    ConCheckIn.bccl_GeoLocation__longitude__s=longit;
                        
                if(!Test.isRunningTest()){
                    ConCheckIn.bccl_Check_In_Address__c=fetchAddress(latit,longit);
                    addressVal=ConCheckIn.bccl_Check_In_Address__c;
                    //retrieveAddress=true;
                }

                update ConCheckIn;
            }
            
            if(eId.startswith('00T'))
            {
                Task ConCheckIn=[select id,bccl_CheckIn_Date_Time__c,bccl_Checkout_Date_time__c,bccl_GeoLocation__latitude__s,
                                    bccl_GeoLocation__longitude__s,bccl_Address__c,bccl_Check_In_Address__c,bccl_Check_Out_Address__c
                                    from Task where id=:eId];
                                    
                system.debug('ConCheckIn-'+ConCheckIn);
                ConCheckIn.bccl_CheckIn_Date_Time__c=system.now();
                if(ConCheckIn.bccl_GeoLocation__latitude__s==null)
                    ConCheckIn.bccl_GeoLocation__latitude__s=latit;
                else if(ConCheckIn.bccl_GeoLocation__latitude__s!=null && ConCheckIn.bccl_GeoLocation__latitude__s!=latit)
                    ConCheckIn.bccl_GeoLocation__latitude__s=latit;
                
                if(ConCheckIn.bccl_GeoLocation__longitude__s==null)
                    ConCheckIn.bccl_GeoLocation__longitude__s=longit;
                else if(ConCheckIn.bccl_GeoLocation__longitude__s!=null && ConCheckIn.bccl_GeoLocation__longitude__s!=longit)
                    ConCheckIn.bccl_GeoLocation__longitude__s=longit;
                        
                if(!Test.isRunningTest()){
                    ConCheckIn.bccl_Check_In_Address__c=fetchAddress(latit,longit);
                    addressVal=ConCheckIn.bccl_Check_In_Address__c;
                    //retrieveAddress=true;
                }

                update ConCheckIn;
            }
            return addressVal;
        }
        
        @AuraEnabled
        public static void addNewCheckIns(string eId){
        system.debug('ConCheckIn-');
            if(eId.startswith('00U')){
                Event ConCheckIn=[select id,bccl_CheckIn_Date_Time__c,bccl_Checkout_Date_time__c,bccl_GeoLocation__latitude__s,
                                    bccl_GeoLocation__longitude__s,bccl_Address__c,bccl_Check_In_Address__c,bccl_Check_Out_Address__c
                                    from Event where id=:eId];
                                    
                system.debug('ConCheckIn-'+ConCheckIn);
                ConCheckIn.bccl_Checkout_Date_time__c=system.now();
                update ConCheckIn;
            }
            
            if(eId.startswith('00T'))
            {
                Task ConCheckIn=[select id,bccl_CheckIn_Date_Time__c,bccl_Checkout_Date_time__c,bccl_GeoLocation__latitude__s,
                                    bccl_GeoLocation__longitude__s,bccl_Address__c,bccl_Check_In_Address__c,bccl_Check_Out_Address__c
                                    from Task where id=:eId];
                                    
                system.debug('ConCheckIn-'+ConCheckIn);
                ConCheckIn.bccl_Checkout_Date_time__c=system.now();
                update ConCheckIn;
            }
        }
        
        @AuraEnabled
        public static void addCheckOuts(string eId){
        system.debug('ConCheckIn-');
            if(eId.startswith('00U')){
                Event ConCheckIn=[select id,bccl_CheckIn_Date_Time__c,bccl_Checkout_Date_time__c,bccl_GeoLocation__latitude__s,
                                    bccl_GeoLocation__longitude__s,bccl_Address__c,bccl_Check_Out_Location__latitude__s,
                                    bccl_Check_Out_Location__longitude__s,bccl_Check_In_Address__c,bccl_Check_Out_Address__c
                                    from Event where id=:eId];
                                    
                system.debug('ConCheckIn-'+ConCheckIn);
                ConCheckIn.bccl_Checkout_Date_time__c=system.now();
                update ConCheckIn;
            }
            
            if(eId.startswith('00T'))
            {
                Task ConCheckIn=[select id,bccl_CheckIn_Date_Time__c,bccl_Checkout_Date_time__c,bccl_GeoLocation__latitude__s,
                                    bccl_GeoLocation__longitude__s,bccl_Address__c,bccl_Check_Out_Location__latitude__s,
                                    bccl_Check_Out_Location__longitude__s,bccl_Check_In_Address__c,bccl_Check_Out_Address__c
                                    from Task where id=:eId];
                                    
                system.debug('ConCheckIn-'+ConCheckIn);
                ConCheckIn.bccl_Checkout_Date_time__c=system.now();
                update ConCheckIn;
            }
        }
        
        @AuraEnabled
        public static string addNewCheckOuts(string eId, decimal latit, decimal longit){
            system.debug('lattitude-'+latit);
            system.debug('longitude-'+longit);
            system.debug('eId-'+eId);
            if(eId.startswith('00U')){
                Event ConCheckIn=[select id,bccl_CheckIn_Date_Time__c,bccl_Checkout_Date_time__c,bccl_GeoLocation__latitude__s,
                                    bccl_GeoLocation__longitude__s,bccl_Address__c,bccl_Check_Out_Location__latitude__s,
                                    bccl_Check_Out_Location__longitude__s,bccl_Check_In_Address__c,bccl_Check_Out_Address__c
                                    from Event where id=:eId];
                                    
                system.debug('ConCheckIn-'+ConCheckIn);
                ConCheckIn.bccl_Checkout_Date_time__c=system.now();
                ConCheckIn.bccl_Check_Out_Location__latitude__s=latit;
                ConCheckIn.bccl_Check_Out_Location__longitude__s=longit;
                
                if(!Test.isRunningTest()){
                    ConCheckIn.bccl_Check_Out_Address__c=fetchAddress(latit,longit);
                    addressVal=ConCheckIn.bccl_Check_Out_Address__c;
                    //retrieveAddress=true;
                }

                update ConCheckIn;
            }
            
            if(eId.startswith('00T'))
            {
                Task ConCheckIn=[select id,bccl_CheckIn_Date_Time__c,bccl_Checkout_Date_time__c,bccl_GeoLocation__latitude__s,
                                    bccl_GeoLocation__longitude__s,bccl_Address__c,bccl_Check_Out_Location__latitude__s,
                                    bccl_Check_Out_Location__longitude__s,bccl_Check_In_Address__c,bccl_Check_Out_Address__c
                                    from Task where id=:eId];
                                    
                system.debug('ConCheckIn-'+ConCheckIn);
                ConCheckIn.bccl_Checkout_Date_time__c=system.now();
                ConCheckIn.bccl_Check_Out_Location__latitude__s=latit;
                ConCheckIn.bccl_Check_Out_Location__longitude__s=longit;
                
                if(!Test.isRunningTest()){
                    ConCheckIn.bccl_Check_Out_Address__c=fetchAddress(latit,longit);
                    addressVal=ConCheckIn.bccl_Check_Out_Address__c;
                    //retrieveAddress=true;
                }

                update ConCheckIn;
            }
            return addressVal;
        }
        
        @AuraEnabled
        public static String getMessage() {
            return 'Spinner Called';
        }

        public void testinput(){
            system.debug('**CALLED**');
            GeoTagValues = apexpages.currentPage().getParameters().get('inpval');
            system.debug(GeoTagValues);
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,'GeoTagValues-'+GeoTagValues));
        }

        public PageReference addGeoLocationClassic(){
            system.debug('**CALLED**'+UserInfo.getUiTheme());
            GeoTagValues = apexpages.currentPage().getParameters().get('inpval');
            system.debug(GeoTagValues);
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,'GeoTagValues-'+GeoTagValues));
            string[] MainValue;
            string Lat='';
            string Lng='';

            if(Test.isRunningTest()){
                GeoTagValues='Latitude: 18.9423653<br>Longitude: 72.8346294<br>accuracy: 30<br>heading: null<br>speed: null<br>timestamp: 1579494467613';
            }

            if(String.isNotBlank(GeoTagValues))
            {
                MainValue=GeoTagValues.split('<br>');
                system.debug(MainValue[0]);
                system.debug(MainValue[1]);

                Lat=MainValue[0];
                Lng=MainValue[1];
                Lat=Lat.substringafter('Latitude: ');
                system.debug(Lat);
                Lng=Lng.substringafter('Longitude: ');
                system.debug(Lng);

                latit=decimal.valueOf(Lat);
                longit=decimal.valueOf(Lng);

                if(OppId.startswith('00U'))
                {
                    Event ConCheckIn=[select id,bccl_CheckIn_Date_Time__c,bccl_Checkout_Date_time__c,bccl_GeoLocation__latitude__s,
                                        bccl_GeoLocation__longitude__s,bccl_Address__c,bccl_Check_In_Address__c,bccl_Check_Out_Address__c,
                                        bccl_Logged_In_UI__c
                                        from Event where id=:OppId ];
                                        
                    system.debug('ConCheckIn-'+ConCheckIn);
                    if(ConCheckIn.bccl_GeoLocation__latitude__s==null)
                        ConCheckIn.bccl_GeoLocation__latitude__s=latit;
                    //else if(ConCheckIn.bccl_GeoLocation__latitude__s!=null && ConCheckIn.bccl_GeoLocation__latitude__s!=latit)
                        //ConCheckIn.bccl_GeoLocation__latitude__s=latit;
                    
                    if(ConCheckIn.bccl_GeoLocation__longitude__s==null)
                        ConCheckIn.bccl_GeoLocation__longitude__s=longit;
                    //else if(ConCheckIn.bccl_GeoLocation__longitude__s!=null && ConCheckIn.bccl_GeoLocation__longitude__s!=longit)
                        //ConCheckIn.bccl_GeoLocation__longitude__s=longit;
                    
                    if(!String.isEmpty(ConCheckIn.bccl_Check_In_Address__c))
                        checkIn=true;

                    if(!String.isEmpty(ConCheckIn.bccl_Check_Out_Address__c))
                        checkOut=true;

                    if(!Test.isRunningTest()){
                        addressVal=fetchAddress(latit,longit);
                        system.debug('addressVal-'+addressVal);
                    }
                    try{
                        update ConCheckIn;
                        retrieveAddress=true;
                    }
                    catch(exception e)
                    {
                        system.debug('Error-'+e);
                        addressVal='You are tagging the wrong Field Visit. Please check for right Field Visit and tag again.';
                        GeoFailed=true;
                    }
                }

                if(OppId.startswith('00T'))
                {
                    Task ConCheckIn=[select id,bccl_CheckIn_Date_Time__c,bccl_Checkout_Date_time__c,bccl_GeoLocation__latitude__s,
                                        bccl_GeoLocation__longitude__s,bccl_Address__c,bccl_Check_In_Address__c,bccl_Check_Out_Address__c,
                                        bccl_Logged_In_UI__c
                                        from Task where id=:OppId];
                                        
                    system.debug('ConCheckIn-'+ConCheckIn);
                    if(ConCheckIn.bccl_GeoLocation__latitude__s==null)
                        ConCheckIn.bccl_GeoLocation__latitude__s=latit;
                    //else if(ConCheckIn.bccl_GeoLocation__latitude__s!=null && ConCheckIn.bccl_GeoLocation__latitude__s!=latit)
                        //ConCheckIn.bccl_GeoLocation__latitude__s=latit;
                    
                    if(ConCheckIn.bccl_GeoLocation__longitude__s==null)
                        ConCheckIn.bccl_GeoLocation__longitude__s=longit;
                    //else if(ConCheckIn.bccl_GeoLocation__longitude__s!=null && ConCheckIn.bccl_GeoLocation__longitude__s!=longit)
                        //ConCheckIn.bccl_GeoLocation__longitude__s=longit;

                    if(!String.isEmpty(ConCheckIn.bccl_Check_In_Address__c))
                        checkIn=true;

                    if(!String.isEmpty(ConCheckIn.bccl_Check_Out_Address__c))
                        checkOut=true;
                    
                    if(!Test.isRunningTest()){
                        addressVal=fetchAddress(latit,longit);
                    }
                    system.debug('bccl_GeoLocation__latitude__s-'+ConCheckIn.bccl_GeoLocation__latitude__s);
                    system.debug('bccl_GeoLocation__longitude__s-'+ConCheckIn.bccl_GeoLocation__longitude__s);
                    try{
                        update ConCheckIn;
                        retrieveAddress=true;
                    }
                    catch(exception e)
                    {
                        system.debug('Error-'+e);
                        addressVal='You are tagging the wrong Field Visit. Please check for right Field Visit and tag again.';
                        GeoFailed=true;
                    }
                }
            }
            latit=0;
            longit=0;
            return null;
        }

        public PageReference addCheckInsClassic(){
            system.debug('**CALLED checkIn**'+UserInfo.getUiTheme());
            GeoTagCheckIn = apexpages.currentPage().getParameters().get('inpval1');
            system.debug(GeoTagCheckIn);
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,'GeoTagCheckIn-'+GeoTagCheckIn));
            string[] MainValue;
            string Lat='';
            string Lng='';
            string Accuracy='';
            string Heading='';
            string Speed='';
            string TimeStamp='';

            if(Test.isRunningTest()){
                GeoTagCheckIn='Latitude: 18.9423653<br>Longitude: 72.8346294<br>accuracy: 30<br>heading: null<br>speed: null<br>timestamp: 1579494467613';
            }

            if(String.isNotBlank(GeoTagCheckIn))
            {
                MainValue=GeoTagCheckIn.split('<br>');
                system.debug(MainValue[0]);
                system.debug(MainValue[1]);

                Lat=MainValue[0];
                Lng=MainValue[1];
                Accuracy=MainValue[2];
                Heading=MainValue[3];
                Speed=MainValue[4];
                TimeStamp=MainValue[5];

                Lat=Lat.substringafter('Latitude: ');
                system.debug(Lat);
                Lng=Lng.substringafter('Longitude: ');
                system.debug(Lng);

                Accuracy=Accuracy.substringafter('Accuracy: ');
                Heading=Heading.substringafter('Heading: ');
                Speed=Speed.substringafter('Speed: ');
                TimeStamp=TimeStamp.substringafter('TimeStamp: ');

                latit=decimal.valueOf(Lat);
                longit=decimal.valueOf(Lng);

                if(!string.isBlank(OppId) && OppId.startswith('00U'))
                {
                    Event ConCheckIn=[select id,bccl_CheckIn_Date_Time__c,bccl_Checkout_Date_time__c,bccl_GeoLocation__latitude__s,
                                        bccl_GeoLocation__longitude__s,bccl_Address__c,bccl_Check_In_Address__c,bccl_Check_Out_Address__c,
                                        bccl_Logged_In_UI__c,bccl_Check_in_Location__latitude__s,bccl_Check_in_Location__longitude__s,
                                        bccl_Check_In_Location_Accuracy__c,bccl_Check_Out_Location_Accuracy__c,bccl_Check_In_Location_Heading__c,
                                        bccl_Check_Out_Location_Heading__c,bccl_Check_In_Location_Speed__c,bccl_Check_Out_Location_Speed__c,
                                        bccl_Check_In_Timestamp__c,bccl_Check_Out_Timestamp__c
                                        from Event where id=:OppId ];//and isChild=false
                                        
                    system.debug('ConCheckIn-'+ConCheckIn.bccl_Check_In_Address__c);
                    ConCheckIn.bccl_CheckIn_Date_Time__c=system.now();
                    /*if(ConCheckIn.bccl_GeoLocation__latitude__s==null)
                        ConCheckIn.bccl_GeoLocation__latitude__s=latit;
                    else if(ConCheckIn.bccl_GeoLocation__latitude__s!=null && ConCheckIn.bccl_GeoLocation__latitude__s!=latit)
                        ConCheckIn.bccl_GeoLocation__latitude__s=latit;
                    
                    if(ConCheckIn.bccl_GeoLocation__longitude__s==null)
                        ConCheckIn.bccl_GeoLocation__longitude__s=longit;
                    else if(ConCheckIn.bccl_GeoLocation__longitude__s!=null && ConCheckIn.bccl_GeoLocation__longitude__s!=longit)
                        ConCheckIn.bccl_GeoLocation__longitude__s=longit;*/

                    ConCheckIn.bccl_Check_in_Location__latitude__s=latit;
                    ConCheckIn.bccl_Check_in_Location__longitude__s=longit;

                    ConCheckIn.bccl_Check_In_Location_Accuracy__c=Accuracy;
                    ConCheckIn.bccl_Check_In_Location_Heading__c=Heading;
                    ConCheckIn.bccl_Check_In_Location_Speed__c=Speed;
                    ConCheckIn.bccl_Check_In_Timestamp__c=TimeStamp;
                            
                    if(!Test.isRunningTest()){
                        if(String.isEmpty(ConCheckIn.bccl_Check_In_Address__c))
                        {
                            system.debug('Here');
                            ConCheckIn.bccl_Check_In_Address__c=fetchAddress(latit,longit);
                            GeoTagIn=ConCheckIn.bccl_Check_In_Address__c;
                             system.debug('GeoTagIn-'+GeoTagIn);
                            ConCheckIn.bccl_Logged_In_UI__c=UserInfo.getUiTheme();

                            update ConCheckIn;
                            retrieveAddress=true;
                            checkIn =true;
                        }
                    }
                }
                else if(string.isBlank(OppId)){
                    GeoTagIn='Sorry! We encountered an error. Please refresh and try again.';
                }
                
                if(!string.isBlank(OppId) && OppId.startswith('00T'))
                {
                    Task ConCheckIn=[select id,bccl_CheckIn_Date_Time__c,bccl_Checkout_Date_time__c,bccl_GeoLocation__latitude__s,
                                        bccl_GeoLocation__longitude__s,bccl_Address__c,bccl_Check_In_Address__c,bccl_Check_Out_Address__c,
                                        bccl_Logged_In_UI__c,bccl_Check_in_Location__latitude__s,bccl_Check_in_Location__longitude__s,
                                        bccl_Check_In_Location_Accuracy__c,bccl_Check_Out_Location_Accuracy__c,bccl_Check_In_Location_Heading__c,
                                        bccl_Check_Out_Location_Heading__c,bccl_Check_In_Location_Speed__c,bccl_Check_Out_Location_Speed__c,
                                        bccl_Check_In_Timestamp__c,bccl_Check_Out_Timestamp__c
                                        from Task where id=:OppId];
                                        
                    system.debug('ConCheckIn-'+ConCheckIn.bccl_Check_In_Address__c);
                    ConCheckIn.bccl_CheckIn_Date_Time__c=system.now();
                    /*if(ConCheckIn.bccl_GeoLocation__latitude__s==null)
                        ConCheckIn.bccl_GeoLocation__latitude__s=latit;
                    else if(ConCheckIn.bccl_GeoLocation__latitude__s!=null && ConCheckIn.bccl_GeoLocation__latitude__s!=latit)
                        ConCheckIn.bccl_GeoLocation__latitude__s=latit;
                    
                    if(ConCheckIn.bccl_GeoLocation__longitude__s==null)
                        ConCheckIn.bccl_GeoLocation__longitude__s=longit;
                    else if(ConCheckIn.bccl_GeoLocation__longitude__s!=null && ConCheckIn.bccl_GeoLocation__longitude__s!=longit)
                        ConCheckIn.bccl_GeoLocation__longitude__s=longit;*/

                    ConCheckIn.bccl_Check_in_Location__latitude__s=latit;
                    ConCheckIn.bccl_Check_in_Location__longitude__s=longit;

                    ConCheckIn.bccl_Check_In_Location_Accuracy__c=Accuracy;
                    ConCheckIn.bccl_Check_In_Location_Heading__c=Heading;
                    ConCheckIn.bccl_Check_In_Location_Speed__c=Speed;
                    ConCheckIn.bccl_Check_In_Timestamp__c=TimeStamp;
                            
                    if(!Test.isRunningTest()){
                        if(String.isEmpty(ConCheckIn.bccl_Check_In_Address__c))
                        {
                            ConCheckIn.bccl_Check_In_Address__c=fetchAddress(latit,longit);
                            GeoTagIn=ConCheckIn.bccl_Check_In_Address__c;
                            ConCheckIn.bccl_Logged_In_UI__c=UserInfo.getUiTheme();

                            update ConCheckIn;
                            retrieveAddress=true;
                            checkIn =true;
                        }
                    }
                }
                else if(string.isBlank(OppId)){
                    GeoTagIn='Sorry! We encountered an error. Please refresh and try again.';
                }
            }
            latit=0;
            longit=0;
            return null;
        }

        public PageReference addNewCheckOutsClssic(){
            GeoTagIn='';
            system.debug('**CALLED checkOut**'+UserInfo.getUiTheme());
            GeoTagCheckOut = apexpages.currentPage().getParameters().get('inpval2');
            system.debug(GeoTagCheckOut);
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,'GeoTagCheckOut-'+GeoTagCheckOut));
            string[] MainValue;
            string Lat='';
            string Lng='';
            string Accuracy='';
            string Heading='';
            string Speed='';
            string TimeStamp='';

            if(Test.isRunningTest()){
                GeoTagCheckOut='Latitude: 18.9423653<br>Longitude: 72.8346294<br>accuracy: 30<br>heading: null<br>speed: null<br>timestamp: 1579494467613';
            }

            if(String.isNotBlank(GeoTagCheckOut))
            {
                MainValue=GeoTagCheckOut.split('<br>');
                system.debug(MainValue[0]);
                system.debug(MainValue[1]);

                Lat=MainValue[0];
                Lng=MainValue[1];
                Accuracy=MainValue[2];
                Heading=MainValue[3];
                Speed=MainValue[4];
                TimeStamp=MainValue[5];
                
                Lat=Lat.substringafter('Latitude: ');
                system.debug(Lat);
                Lng=Lng.substringafter('Longitude: ');
                system.debug(Lng);

                Accuracy=Accuracy.substringafter('Accuracy: ');
                Heading=Heading.substringafter('Heading: ');
                Speed=Speed.substringafter('Speed: ');
                TimeStamp=TimeStamp.substringafter('TimeStamp: ');

                latit=decimal.valueOf(Lat);
                longit=decimal.valueOf(Lng);
                if(!string.isBlank(OppId) && OppId.startswith('00U')){
                    Event ConCheckIn=[select id,bccl_CheckIn_Date_Time__c,bccl_Checkout_Date_time__c,bccl_GeoLocation__latitude__s,
                                        bccl_GeoLocation__longitude__s,bccl_Address__c,bccl_Check_Out_Location__latitude__s,
                                        bccl_Check_Out_Location__longitude__s,bccl_Check_In_Address__c,bccl_Check_Out_Address__c,
                                        bccl_Logged_in_UI_Check_Out__c,
                                        bccl_Check_In_Location_Accuracy__c,bccl_Check_Out_Location_Accuracy__c,bccl_Check_In_Location_Heading__c,
                                        bccl_Check_Out_Location_Heading__c,bccl_Check_In_Location_Speed__c,bccl_Check_Out_Location_Speed__c,
                                        bccl_Check_In_Timestamp__c,bccl_Check_Out_Timestamp__c
                                        from Event where id=:OppId ];//and isChild=false
                                        
                    system.debug('ConCheckIn-'+ConCheckIn);
                    ConCheckIn.bccl_Checkout_Date_time__c=system.now();
                    ConCheckIn.bccl_Check_Out_Location__latitude__s=latit;
                    ConCheckIn.bccl_Check_Out_Location__longitude__s=longit;

                    ConCheckIn.bccl_Check_Out_Location_Accuracy__c=Accuracy;
                    ConCheckIn.bccl_Check_Out_Location_Heading__c=Heading;
                    ConCheckIn.bccl_Check_Out_Location_Speed__c=Speed;
                    ConCheckIn.bccl_Check_Out_Timestamp__c=TimeStamp;

                    if(!Test.isRunningTest()){
                        if(String.isEmpty(ConCheckIn.bccl_Check_Out_Address__c))
                        {
                            ConCheckIn.bccl_Check_Out_Address__c=fetchAddress(latit,longit);
                            GeoTagOut=ConCheckIn.bccl_Check_Out_Address__c;
                            system.debug('GeoTagOut-'+GeoTagOut);
                            ConCheckIn.bccl_Logged_in_UI_Check_Out__c=UserInfo.getUiTheme();

                            update ConCheckIn;
                            retrieveAddress=true;
                            checkOut =true;                            
                        }
                    }
                }
                else if(string.isBlank(OppId)){
                    GeoTagOut='Sorry! We encountered an error. Please refresh and try again.';
                }
                
                if(!string.isBlank(OppId) && OppId.startswith('00T'))
                {
                    Task ConCheckIn=[select id,bccl_CheckIn_Date_Time__c,bccl_Checkout_Date_time__c,bccl_GeoLocation__latitude__s,
                                        bccl_GeoLocation__longitude__s,bccl_Address__c,bccl_Check_Out_Location__latitude__s,
                                        bccl_Check_Out_Location__longitude__s,bccl_Check_In_Address__c,bccl_Check_Out_Address__c,
                                        bccl_Logged_in_UI_Check_Out__c,
                                        bccl_Check_In_Location_Accuracy__c,bccl_Check_Out_Location_Accuracy__c,bccl_Check_In_Location_Heading__c,
                                        bccl_Check_Out_Location_Heading__c,bccl_Check_In_Location_Speed__c,bccl_Check_Out_Location_Speed__c,
                                        bccl_Check_In_Timestamp__c,bccl_Check_Out_Timestamp__c
                                        from Task where id=:OppId];
                                        
                    system.debug('ConCheckIn-'+ConCheckIn);
                    ConCheckIn.bccl_Checkout_Date_time__c=system.now();
                    ConCheckIn.bccl_Check_Out_Location__latitude__s=latit;
                    ConCheckIn.bccl_Check_Out_Location__longitude__s=longit;

                    ConCheckIn.bccl_Check_Out_Location_Accuracy__c=Accuracy;
                    ConCheckIn.bccl_Check_Out_Location_Heading__c=Heading;
                    ConCheckIn.bccl_Check_Out_Location_Speed__c=Speed;
                    ConCheckIn.bccl_Check_Out_Timestamp__c=TimeStamp;
                    
                    if(!Test.isRunningTest()){
                        if(String.isEmpty(ConCheckIn.bccl_Check_Out_Address__c))
                        {
                            ConCheckIn.bccl_Check_Out_Address__c=fetchAddress(latit,longit);
                            GeoTagOut=ConCheckIn.bccl_Check_Out_Address__c;
                            system.debug('GeoTagOut-'+GeoTagOut);
                            ConCheckIn.bccl_Logged_in_UI_Check_Out__c=UserInfo.getUiTheme();

                            update ConCheckIn;
                            retrieveAddress=true;
                            checkOut =true;
                        }
                    }
                }
                else if(string.isBlank(OppId)){
                    GeoTagOut='Sorry! We encountered an error. Please refresh and try again.';
                }
            }
            latit=0;
            longit=0;

            /*PageReference editList = Page.bccl_CheckMap;
            editList.getParameters().put('id', OppId);
            editList.setRedirect(true);
            return editList;*/
            return null;
        }
        
        public static String fetchAddress(decimal lattitudeValue, decimal longitudeValue) {
            String addressValue = '';
            String endpoint = 'https://www.google.com/maps/place/' + String.valueOf(lattitudeValue) + ',' + String.valueOf(longitudeValue) + '?hl=en';
            HttpRequest req = new HttpRequest();
            req.setEndpoint(endpoint);
            req.setMethod('GET');

            HttpResponse res = new Http().send(req);

            if (res.getBody() != null) {
                System.debug(res.getBody());
                String str = res.getBody().substringBefore('itemprop="description"').substringAfterLast('meta');
                System.debug(str);
                addressValue = str.substringBetween('"', '"');
            }

            System.debug('addressValue: ' + addressValue);
            return addressValue;
        }
    }
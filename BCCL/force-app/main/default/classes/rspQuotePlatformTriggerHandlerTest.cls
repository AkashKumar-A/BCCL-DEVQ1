/* ---------------------------------------------------------------------------------------------
@author :- Sushant Ujlayan
@Company :- Saasfocus
@description :- 'Test class for rspQuotePlatformTriggerHandler'
Created Date: 13-December-2018
-----------------------------------------------------------------------------------------------*/
@isTest
public class rspQuotePlatformTriggerHandlerTest 
{
    public static final string defaultStage = 'Discovery';
    public static final string deafultStr = '1234';
    static testMethod void testMethod1()
    {   
        
        Account accObj = rsp_TestDataHelper.createAccount();
        insert accObj;
        System.assertnotEquals(accObj.Id , null);
        rsp_vertical__c verticalObj = rsp_TestDataHelper.createVertical();
        insert verticalObj;
        System.assertnotEquals(verticalObj.Id , null);
        Opportunity oppObj = rsp_TestDataHelper.createOpportunity(accObj,verticalObj);
        oppObj.vertical__c = verticalObj.Id;
        oppObj.StageName = defaultStage;
        insert oppObj;
        System.assertnotEquals(oppObj.Id , null);
        Quote objQuote = rsp_TestDataHelper.createQuote(oppObj);
        insert objQuote;
        System.assertnotEquals(objQuote.Id , null);
        Approval.ProcessSubmitRequest req1 = 
            new Approval.ProcessSubmitRequest();
        req1.setObjectId(objQuote.id);
        list<Id> userIds = new list<Id>();
        userIds.add(userInfo.getUserId());
        // Submit on behalf of a specific submitter
        req1.setNextApproverIds(userIds); 
        // Submit the approval request for the account
        Approval.ProcessResult result = Approval.process(req1);
        String returnVaalue = rspQuotePlatformTriggerHandler.getQuoteHtmlData(result.getNewWorkitemIds().get(0));
        System.assertnotEquals(returnVaalue, null);
        
    }
    
    static testMethod void testMethod2()
    {   
        
        Account accObj = rsp_TestDataHelper.createAccount();
        insert accObj;
        System.assertnotEquals(accObj.Id , null);
        rsp_vertical__c verticalObj = rsp_TestDataHelper.createVertical();
        insert verticalObj;
        System.assertnotEquals(verticalObj.Id , null);
        Opportunity oppObj = rsp_TestDataHelper.createOpportunity(accObj,verticalObj);
        oppObj.vertical__c = verticalObj.Id;
        oppObj.StageName = defaultStage;
        insert oppObj;
        System.assertnotEquals(oppObj.Id , null);
        Quote objQuote = rsp_TestDataHelper.createQuote(oppObj);
        objQuote.Stage_1_Decision__c = 'Approved';
        objQuote.Stage_2_Decision__c = 'Approved';
        objQuote.rsp_QRN_No__c = deafultStr;
        objQuote.status = 'Approved';
        insert objQuote;
        System.assertnotEquals(objQuote.Id , null);
        rsp_Sap_Quote_Platform_Event__e quotePlatformEventObj = new rsp_Sap_Quote_Platform_Event__e();
        quotePlatformEventObj.rsp_QRN_No__c = deafultStr;
        quotePlatformEventObj.rsp_Quote_JSON__c = '{ "header": { "mandt": "014", "agrno": "1234", "descr": "", "inserent": "", "zzvercd": "0", "begda": "20181127", "endda": "00000000", "avm_nr": "", "appr_no": "", "userid": "aditya.tripathi1@timesgroup.com", "cpt_val": 0, "quotevalue": 1300, "ratevalue": 1300, "final_rate": 0, "final_value": 0, "client_name": "QWERTY", "inhk_eint": "", "qrn_type": "S", "user_name": "aditya.tripathi1@timesgroup.com", "erfdate": "20181127", "rev_calculated": "", "parent": "", "init_floor_value": 0, "init_final_value": 0, "xstorniert": "", "kampagne": "", "deal_value": 41210, "volume": 32, "object_id": "'+oppObj.Id+'", "innovation_new": "0", "pricing_new": "1", "qrn_time": "13:52:18", "vkorg": "", "item_count": 1, "cube_processflg": "", "spart": "02", "extraln_val": 0, "final_val_bextra": 0, "last_extra_ln": 0, "zus_berech": "", "campexpectedval": 0, "campfeasibiltval": 0, "campdate": "", "horizontal": "0", "campid": "", "spl_adtype": "CD MULTICOLUMN", "camptext": "", "billing_block": "", "approval_date": "00000000", "approval_time": "00:00:00", "ros": "", "supersizing": "", "lastauthcode": "", "zzactexicd_d": "", "pricing_rational": "", "qrn_stage": "", "weekdayonly": "", "guar_jacket": "", "com_cobran": "", "co_branded_partn": "", "qrn_fest_schem": "", "auth": "", "unauth": "", "prefinal_val": 0, "upgrade_tag": "", "fallow_inv": "", "is_client": "", "auth_brand_name": "", "ad_type": "", "blk_flexi_addon": "", "groupcd": "", "special_rate": "", "second_section": "", "send_flag": "", "agencycode": "", "agency_name": "", "pricing_grp_par": "", "pricing_grp_name": "", "authtype": "" }, "detail": [ { "mandt": "014", "agrno": "P167544306DC", "pos_nr": "001", "ein_nr": "000001", "konda": "H3", "beleinh": "TOID", "e_termin": "20181128", "inhk_eint": "RE", "inhk_plaz": "INRE", "azart_farb": "4C", "azart_plaz": "RHS", "anz_wnfs": "000", "breite_s": 6.34, "breite_seh": "", "hoehe_s": 5, "hoehe_seh": "", "netpr": 0, "waers": "INR", "zzinov_cd": "", "final_value": 0, "final_rate": 0, "ref_avm_nr": "", "ref_pos_nr": "000", "begda": "20181128", "endda": "20181128", "rev_cal_value": 0, "entry_type": "", "s_heft": "", "xstorniert": "", "pstyv": "0001", "azart_gest": "", "ad_size": 0, "inv_description": "", "metro_nonmetro": "", "zus_menge": 0, "zus_berech": "ZL", "score": "", "docalc": "", "original_endda": "00000000", "org_tcc": "", "upgrade_value": 0, "upgrade_percent": "000", "quot_app_block": false, "changed_by": "", "changed_on": "00000000", "changed_at": "00:00:00", "is_cancelled": "", "send_flag": "" }, { "mandt": "014", "agrno": "P167544306DC", "pos_nr": "002", "ein_nr": "000001", "konda": "H3", "beleinh": "STOID", "e_termin": "20181202", "inhk_eint": "RE", "inhk_plaz": "INRE", "azart_farb": "4C", "azart_plaz": "RHS", "anz_wnfs": "000", "breite_s": 6.34, "breite_seh": "", "hoehe_s": 5, "hoehe_seh": "", "netpr": 0, "waers": "INR", "zzinov_cd": "", "final_value": 0, "final_rate": 0, "ref_avm_nr": "", "ref_pos_nr": "000", "begda": "20181202", "endda": "20181202", "rev_cal_value": 0, "entry_type": "", "s_heft": "", "xstorniert": "", "pstyv": "0001", "azart_gest": "", "ad_size": 0, "inv_description": "", "metro_nonmetro": "", "zus_menge": 0, "zus_berech": "ZL", "score": "", "docalc": "", "original_endda": "00000000", "org_tcc": "", "upgrade_value": 0, "upgrade_percent": "000", "quot_app_block": false, "changed_by": "", "changed_on": "00000000", "changed_at": "00:00:00", "is_cancelled": "", "send_flag": "" }, { "mandt": "014", "agrno": "P167544306DC", "pos_nr": "003", "ein_nr": "000001", "konda": "H3", "beleinh": "ETD", "e_termin": "20181128", "inhk_eint": "RE", "inhk_plaz": "INRE", "azart_farb": "4C", "azart_plaz": "RHS", "anz_wnfs": "000", "breite_s": 6.34, "breite_seh": "", "hoehe_s": 5, "hoehe_seh": "", "netpr": 0, "waers": "INR", "zzinov_cd": "", "final_value": 0, "final_rate": 0, "ref_avm_nr": "", "ref_pos_nr": "000", "begda": "20181128", "endda": "20181128", "rev_cal_value": 0, "entry_type": "", "s_heft": "", "xstorniert": "", "pstyv": "0001", "azart_gest": "", "ad_size": 0, "inv_description": "", "metro_nonmetro": "", "zus_menge": 0, "zus_berech": "ZL", "score": "", "docalc": "", "original_endda": "00000000", "org_tcc": "", "upgrade_value": 0, "upgrade_percent": "000", "quot_app_block": false, "changed_by": "", "changed_on": "00000000", "changed_at": "00:00:00", "is_cancelled": "", "send_flag": "" }, { "mandt": "014", "agrno": "P167544306DC", "pos_nr": "004", "ein_nr": "000001", "konda": "H3", "beleinh": "TOIDGR", "e_termin": "20181128", "inhk_eint": "RE", "inhk_plaz": "INRE", "azart_farb": "4C", "azart_plaz": "RHS", "anz_wnfs": "000", "breite_s": 6.34, "breite_seh": "", "hoehe_s": 5, "hoehe_seh": "", "netpr": 0, "waers": "INR", "zzinov_cd": "", "final_value": 0, "final_rate": 0, "ref_avm_nr": "", "ref_pos_nr": "000", "begda": "20181128", "endda": "20181128", "rev_cal_value": 0, "entry_type": "", "s_heft": "", "xstorniert": "", "pstyv": "0001", "azart_gest": "", "ad_size": 0, "inv_description": "", "metro_nonmetro": "", "zus_menge": 0, "zus_berech": "ZL", "score": "", "docalc": "", "original_endda": "00000000", "org_tcc": "", "upgrade_value": 0, "upgrade_percent": "000", "quot_app_block": false, "changed_by": "", "changed_on": "00000000", "changed_at": "00:00:00", "is_cancelled": "", "send_flag": "" }, { "mandt": "014", "agrno": "P167544306DC", "pos_nr": "005", "ein_nr": "000001", "konda": "H3", "beleinh": "TOIWUTK", "e_termin": "20181128", "inhk_eint": "RE", "inhk_plaz": "INRE", "azart_farb": "4C", "azart_plaz": "RHS", "anz_wnfs": "000", "breite_s": 6.34, "breite_seh": "", "hoehe_s": 5, "hoehe_seh": "", "netpr": 0, "waers": "INR", "zzinov_cd": "", "final_value": 0, "final_rate": 0, "ref_avm_nr": "", "ref_pos_nr": "000", "begda": "20181128", "endda": "20181128", "rev_cal_value": 0, "entry_type": "", "s_heft": "", "xstorniert": "", "pstyv": "0001", "azart_gest": "", "ad_size": 0, "inv_description": "", "metro_nonmetro": "", "zus_menge": 0, "zus_berech": "ZL", "score": "", "docalc": "", "original_endda": "00000000", "org_tcc": "", "upgrade_value": 0, "upgrade_percent": "000", "quot_app_block": false, "changed_by": "", "changed_on": "00000000", "changed_at": "00:00:00", "is_cancelled": "", "send_flag": "" } ] }';
        Test.startTest();
        // Publish test event
        Database.SaveResult sr = EventBus.publish(quotePlatformEventObj);
            
        Test.stopTest();
        
    }
    static testMethod void testMethod3()
    {   
        
        rsp_Horizontal__c horObj = rsp_TestDataHelper.createHorizontal();
        insert horObj;
        System.assertnotEquals(horObj.Id , null);
        rsp_Geography__c geoObj = rsp_TestDataHelper.createGeography();
        insert geoObj;
        System.assertnotEquals(geoObj.Id , null);
        Account accObj = rsp_TestDataHelper.createAccount();
        accObj.rsp_Geography__c = geoObj.Id;
        accObj.rsp_Sales_office__c = geoObj.Id;
        insert accObj;
        System.assertnotEquals(accObj.Id , null);
        rsp_vertical__c verticalObj = rsp_TestDataHelper.createVertical();
        verticalObj.Name = 'APPOINTMENTS';
        insert verticalObj;
        System.assertnotEquals(verticalObj.Id , null);
        
       rsp_Role__c roleObj=rsp_TestDataHelper.createRole('Vertical',verticalObj.Id,null,geoObj.Id);
       Profile__c profileObj=rsp_TestDataHelper.createProfile();
       profileObj.Name = 'President';
       profileObj.rsp_Profile_Initials__c = 'BVH';
       insert profileObj;
       roleObj.rsp_Profile__c = profileObj.Id;
       roleObj.rsp_Current_User__c = userInfo.getUserId();
      insert roleObj;
        Opportunity oppObj = rsp_TestDataHelper.createOpportunity(accObj,verticalObj);
        oppObj.vertical__c = verticalObj.Id;
        oppObj.StageName = defaultStage;
        insert oppObj;
        insert rsp_TestDataHelper.createGroup();
        
        
        rsp_Sap_Authorization_Det_Platform_Event__e authPlatformEventObj = new rsp_Sap_Authorization_Det_Platform_Event__e();
        authPlatformEventObj.rsp_Qrn__c = deafultStr;
        authPlatformEventObj.rsp_Authorization_data__c = '{ "header": { "mandt": "014", "agrno": "1234", "descr": "", "inserent": "", "zzvercd": "0", "begda": "20181127", "endda": "00000000", "avm_nr": "", "appr_no": "", "userid": "aditya.tripathi1@timesgroup.com", "cpt_val": 0, "quotevalue": 1300, "ratevalue": 1300, "final_rate": 0, "final_value": 0, "client_name": "QWERTY", "inhk_eint": "", "qrn_type": "S", "user_name": "aditya.tripathi1@timesgroup.com", "erfdate": "20181127", "rev_calculated": "", "parent": "", "init_floor_value": 0, "init_final_value": 0, "xstorniert": "", "kampagne": "", "deal_value": 41210, "volume": 32, "object_id": "", "innovation_new": "0", "pricing_new": "1", "qrn_time": "13:52:18", "vkorg": "", "item_count": 1, "cube_processflg": "", "spart": "02", "extraln_val": 0, "final_val_bextra": 0, "last_extra_ln": 0, "zus_berech": "", "campexpectedval": 0, "campfeasibiltval": 0, "campdate": "", "horizontal": "0", "campid": "", "spl_adtype": "CD MULTICOLUMN", "camptext": "", "billing_block": "", "approval_date": "00000000", "approval_time": "00:00:00", "ros": "", "supersizing": "", "lastauthcode": "", "zzactexicd_d": "", "pricing_rational": "", "qrn_stage": "", "weekdayonly": "", "guar_jacket": "", "com_cobran": "", "co_branded_partn": "", "qrn_fest_schem": "", "auth": "", "unauth": "", "prefinal_val": 0, "upgrade_tag": "", "fallow_inv": "", "is_client": "", "auth_brand_name": "", "ad_type": "", "blk_flexi_addon": "", "groupcd": "", "special_rate": "", "second_section": "", "send_flag": "", "agencycode": "", "agency_name": "", "pricing_grp_par": "", "pricing_grp_name": "", "authtype": "" }, "detail": [ { "mandt": "014", "agrno": "P167544306DC", "pos_nr": "001", "ein_nr": "000001", "konda": "H3", "beleinh": "TOID", "e_termin": "20181128", "inhk_eint": "RE", "inhk_plaz": "INRE", "azart_farb": "4C", "azart_plaz": "RHS", "anz_wnfs": "000", "breite_s": 6.34, "breite_seh": "", "hoehe_s": 5, "hoehe_seh": "", "netpr": 0, "waers": "INR", "zzinov_cd": "", "final_value": 0, "final_rate": 0, "ref_avm_nr": "", "ref_pos_nr": "000", "begda": "20181128", "endda": "20181128", "rev_cal_value": 0, "entry_type": "", "s_heft": "", "xstorniert": "", "pstyv": "0001", "azart_gest": "", "ad_size": 0, "inv_description": "", "metro_nonmetro": "", "zus_menge": 0, "zus_berech": "ZL", "score": "", "docalc": "", "original_endda": "00000000", "org_tcc": "", "upgrade_value": 0, "upgrade_percent": "000", "quot_app_block": false, "changed_by": "", "changed_on": "00000000", "changed_at": "00:00:00", "is_cancelled": "", "send_flag": "" }, { "mandt": "014", "agrno": "P167544306DC", "pos_nr": "002", "ein_nr": "000001", "konda": "H3", "beleinh": "STOID", "e_termin": "20181202", "inhk_eint": "RE", "inhk_plaz": "INRE", "azart_farb": "4C", "azart_plaz": "RHS", "anz_wnfs": "000", "breite_s": 6.34, "breite_seh": "", "hoehe_s": 5, "hoehe_seh": "", "netpr": 0, "waers": "INR", "zzinov_cd": "", "final_value": 0, "final_rate": 0, "ref_avm_nr": "", "ref_pos_nr": "000", "begda": "20181202", "endda": "20181202", "rev_cal_value": 0, "entry_type": "", "s_heft": "", "xstorniert": "", "pstyv": "0001", "azart_gest": "", "ad_size": 0, "inv_description": "", "metro_nonmetro": "", "zus_menge": 0, "zus_berech": "ZL", "score": "", "docalc": "", "original_endda": "00000000", "org_tcc": "", "upgrade_value": 0, "upgrade_percent": "000", "quot_app_block": false, "changed_by": "", "changed_on": "00000000", "changed_at": "00:00:00", "is_cancelled": "", "send_flag": "" }, { "mandt": "014", "agrno": "P167544306DC", "pos_nr": "003", "ein_nr": "000001", "konda": "H3", "beleinh": "ETD", "e_termin": "20181128", "inhk_eint": "RE", "inhk_plaz": "INRE", "azart_farb": "4C", "azart_plaz": "RHS", "anz_wnfs": "000", "breite_s": 6.34, "breite_seh": "", "hoehe_s": 5, "hoehe_seh": "", "netpr": 0, "waers": "INR", "zzinov_cd": "", "final_value": 0, "final_rate": 0, "ref_avm_nr": "", "ref_pos_nr": "000", "begda": "20181128", "endda": "20181128", "rev_cal_value": 0, "entry_type": "", "s_heft": "", "xstorniert": "", "pstyv": "0001", "azart_gest": "", "ad_size": 0, "inv_description": "", "metro_nonmetro": "", "zus_menge": 0, "zus_berech": "ZL", "score": "", "docalc": "", "original_endda": "00000000", "org_tcc": "", "upgrade_value": 0, "upgrade_percent": "000", "quot_app_block": false, "changed_by": "", "changed_on": "00000000", "changed_at": "00:00:00", "is_cancelled": "", "send_flag": "" }, { "mandt": "014", "agrno": "P167544306DC", "pos_nr": "004", "ein_nr": "000001", "konda": "H3", "beleinh": "TOIDGR", "e_termin": "20181128", "inhk_eint": "RE", "inhk_plaz": "INRE", "azart_farb": "4C", "azart_plaz": "RHS", "anz_wnfs": "000", "breite_s": 6.34, "breite_seh": "", "hoehe_s": 5, "hoehe_seh": "", "netpr": 0, "waers": "INR", "zzinov_cd": "", "final_value": 0, "final_rate": 0, "ref_avm_nr": "", "ref_pos_nr": "000", "begda": "20181128", "endda": "20181128", "rev_cal_value": 0, "entry_type": "", "s_heft": "", "xstorniert": "", "pstyv": "0001", "azart_gest": "", "ad_size": 0, "inv_description": "", "metro_nonmetro": "", "zus_menge": 0, "zus_berech": "ZL", "score": "", "docalc": "", "original_endda": "00000000", "org_tcc": "", "upgrade_value": 0, "upgrade_percent": "000", "quot_app_block": false, "changed_by": "", "changed_on": "00000000", "changed_at": "00:00:00", "is_cancelled": "", "send_flag": "" }, { "mandt": "014", "agrno": "P167544306DC", "pos_nr": "005", "ein_nr": "000001", "konda": "H3", "beleinh": "TOIWUTK", "e_termin": "20181128", "inhk_eint": "RE", "inhk_plaz": "INRE", "azart_farb": "4C", "azart_plaz": "RHS", "anz_wnfs": "000", "breite_s": 6.34, "breite_seh": "", "hoehe_s": 5, "hoehe_seh": "", "netpr": 0, "waers": "INR", "zzinov_cd": "", "final_value": 0, "final_rate": 0, "ref_avm_nr": "", "ref_pos_nr": "000", "begda": "20181128", "endda": "20181128", "rev_cal_value": 0, "entry_type": "", "s_heft": "", "xstorniert": "", "pstyv": "0001", "azart_gest": "", "ad_size": 0, "inv_description": "", "metro_nonmetro": "", "zus_menge": 0, "zus_berech": "ZL", "score": "", "docalc": "", "original_endda": "00000000", "org_tcc": "", "upgrade_value": 0, "upgrade_percent": "000", "quot_app_block": false, "changed_by": "", "changed_on": "00000000", "changed_at": "00:00:00", "is_cancelled": "", "send_flag": "" } ] }';
        authPlatformEventObj.Opportunity_Id__c = oppObj.Id;
        authPlatformEventObj.rsp_Authorization_Id__c = '1111';
        authPlatformEventObj.rsp_Floor_Rate__c = '11';
        Test.startTest();
        
        // Publish test event
        Database.SaveResult sr = EventBus.publish(authPlatformEventObj);
            
        Test.stopTest();
        
    }
    static testMethod void testMethod4()
    {   
        
        rsp_Horizontal__c horObj = rsp_TestDataHelper.createHorizontal();
        insert horObj;
        System.assertnotEquals(horObj.Id , null);
        rsp_Geography__c geoObj = rsp_TestDataHelper.createGeography();
        insert geoObj;
        System.assertnotEquals(geoObj.Id , null);
        Account accObj = rsp_TestDataHelper.createAccount();
        accObj.rsp_Geography__c = geoObj.Id;
        accObj.rsp_Sales_office__c = geoObj.Id;
        insert accObj;
        System.assertnotEquals(accObj.Id , null);
        rsp_vertical__c verticalObj = rsp_TestDataHelper.createVertical();
        verticalObj.Name = 'CLASSIFIEDS';
        insert verticalObj;
        System.assertnotEquals(accObj.Id , null);
        rsp_Role__c roleObj=rsp_TestDataHelper.createRole('Vertical',verticalObj.Id,null,geoObj.Id);
       Profile__c profileObj=rsp_TestDataHelper.createProfile();
       profileObj.Name = 'President';
       profileObj.rsp_Profile_Initials__c = 'NVH';
       insert profileObj;
       System.assertnotEquals(profileObj.Id , null);
       roleObj.rsp_Profile__c = profileObj.Id;
       roleObj.rsp_Current_User__c = userInfo.getUserId();
      insert roleObj;
      System.assertnotEquals(roleObj.Id , null);
        Opportunity oppObj = rsp_TestDataHelper.createOpportunity(accObj,verticalObj);
        oppObj.vertical__c = verticalObj.Id;
        oppObj.StageName = defaultStage;
        insert oppObj;
        
        insert rsp_TestDataHelper.createGroup();
        
        System.assertnotEquals(oppObj.Id , null);
        
        
        rsp_Sap_Authorization_Det_Platform_Event__e authPlatformEventObj = new rsp_Sap_Authorization_Det_Platform_Event__e();
        authPlatformEventObj.rsp_Qrn__c = deafultStr;
        authPlatformEventObj.rsp_Authorization_data__c = '{ "header": { "mandt": "014", "agrno": "1234", "descr": "", "inserent": "", "zzvercd": "0", "begda": "20181127", "endda": "00000000", "avm_nr": "", "appr_no": "", "userid": "aditya.tripathi1@timesgroup.com", "cpt_val": 0, "quotevalue": 1300, "ratevalue": 1300, "final_rate": 0, "final_value": 0, "client_name": "QWERTY", "inhk_eint": "", "qrn_type": "S", "user_name": "aditya.tripathi1@timesgroup.com", "erfdate": "20181127", "rev_calculated": "", "parent": "", "init_floor_value": 0, "init_final_value": 0, "xstorniert": "", "kampagne": "", "deal_value": 41210, "volume": 32, "object_id": "", "innovation_new": "0", "pricing_new": "1", "qrn_time": "13:52:18", "vkorg": "", "item_count": 1, "cube_processflg": "", "spart": "02", "extraln_val": 0, "final_val_bextra": 0, "last_extra_ln": 0, "zus_berech": "", "campexpectedval": 0, "campfeasibiltval": 0, "campdate": "", "horizontal": "0", "campid": "", "spl_adtype": "CD MULTICOLUMN", "camptext": "", "billing_block": "", "approval_date": "00000000", "approval_time": "00:00:00", "ros": "", "supersizing": "", "lastauthcode": "", "zzactexicd_d": "", "pricing_rational": "", "qrn_stage": "", "weekdayonly": "", "guar_jacket": "", "com_cobran": "", "co_branded_partn": "", "qrn_fest_schem": "", "auth": "", "unauth": "", "prefinal_val": 0, "upgrade_tag": "", "fallow_inv": "", "is_client": "", "auth_brand_name": "", "ad_type": "", "blk_flexi_addon": "", "groupcd": "", "special_rate": "", "second_section": "", "send_flag": "", "agencycode": "", "agency_name": "", "pricing_grp_par": "", "pricing_grp_name": "", "authtype": "" }, "detail": [ { "mandt": "014", "agrno": "P167544306DC", "pos_nr": "001", "ein_nr": "000001", "konda": "H3", "beleinh": "TOID", "e_termin": "20181128", "inhk_eint": "RE", "inhk_plaz": "INRE", "azart_farb": "4C", "azart_plaz": "RHS", "anz_wnfs": "000", "breite_s": 6.34, "breite_seh": "", "hoehe_s": 5, "hoehe_seh": "", "netpr": 0, "waers": "INR", "zzinov_cd": "", "final_value": 0, "final_rate": 0, "ref_avm_nr": "", "ref_pos_nr": "000", "begda": "20181128", "endda": "20181128", "rev_cal_value": 0, "entry_type": "", "s_heft": "", "xstorniert": "", "pstyv": "0001", "azart_gest": "", "ad_size": 0, "inv_description": "", "metro_nonmetro": "", "zus_menge": 0, "zus_berech": "ZL", "score": "", "docalc": "", "original_endda": "00000000", "org_tcc": "", "upgrade_value": 0, "upgrade_percent": "000", "quot_app_block": false, "changed_by": "", "changed_on": "00000000", "changed_at": "00:00:00", "is_cancelled": "", "send_flag": "" }, { "mandt": "014", "agrno": "P167544306DC", "pos_nr": "002", "ein_nr": "000001", "konda": "H3", "beleinh": "STOID", "e_termin": "20181202", "inhk_eint": "RE", "inhk_plaz": "INRE", "azart_farb": "4C", "azart_plaz": "RHS", "anz_wnfs": "000", "breite_s": 6.34, "breite_seh": "", "hoehe_s": 5, "hoehe_seh": "", "netpr": 0, "waers": "INR", "zzinov_cd": "", "final_value": 0, "final_rate": 0, "ref_avm_nr": "", "ref_pos_nr": "000", "begda": "20181202", "endda": "20181202", "rev_cal_value": 0, "entry_type": "", "s_heft": "", "xstorniert": "", "pstyv": "0001", "azart_gest": "", "ad_size": 0, "inv_description": "", "metro_nonmetro": "", "zus_menge": 0, "zus_berech": "ZL", "score": "", "docalc": "", "original_endda": "00000000", "org_tcc": "", "upgrade_value": 0, "upgrade_percent": "000", "quot_app_block": false, "changed_by": "", "changed_on": "00000000", "changed_at": "00:00:00", "is_cancelled": "", "send_flag": "" }, { "mandt": "014", "agrno": "P167544306DC", "pos_nr": "003", "ein_nr": "000001", "konda": "H3", "beleinh": "ETD", "e_termin": "20181128", "inhk_eint": "RE", "inhk_plaz": "INRE", "azart_farb": "4C", "azart_plaz": "RHS", "anz_wnfs": "000", "breite_s": 6.34, "breite_seh": "", "hoehe_s": 5, "hoehe_seh": "", "netpr": 0, "waers": "INR", "zzinov_cd": "", "final_value": 0, "final_rate": 0, "ref_avm_nr": "", "ref_pos_nr": "000", "begda": "20181128", "endda": "20181128", "rev_cal_value": 0, "entry_type": "", "s_heft": "", "xstorniert": "", "pstyv": "0001", "azart_gest": "", "ad_size": 0, "inv_description": "", "metro_nonmetro": "", "zus_menge": 0, "zus_berech": "ZL", "score": "", "docalc": "", "original_endda": "00000000", "org_tcc": "", "upgrade_value": 0, "upgrade_percent": "000", "quot_app_block": false, "changed_by": "", "changed_on": "00000000", "changed_at": "00:00:00", "is_cancelled": "", "send_flag": "" }, { "mandt": "014", "agrno": "P167544306DC", "pos_nr": "004", "ein_nr": "000001", "konda": "H3", "beleinh": "TOIDGR", "e_termin": "20181128", "inhk_eint": "RE", "inhk_plaz": "INRE", "azart_farb": "4C", "azart_plaz": "RHS", "anz_wnfs": "000", "breite_s": 6.34, "breite_seh": "", "hoehe_s": 5, "hoehe_seh": "", "netpr": 0, "waers": "INR", "zzinov_cd": "", "final_value": 0, "final_rate": 0, "ref_avm_nr": "", "ref_pos_nr": "000", "begda": "20181128", "endda": "20181128", "rev_cal_value": 0, "entry_type": "", "s_heft": "", "xstorniert": "", "pstyv": "0001", "azart_gest": "", "ad_size": 0, "inv_description": "", "metro_nonmetro": "", "zus_menge": 0, "zus_berech": "ZL", "score": "", "docalc": "", "original_endda": "00000000", "org_tcc": "", "upgrade_value": 0, "upgrade_percent": "000", "quot_app_block": false, "changed_by": "", "changed_on": "00000000", "changed_at": "00:00:00", "is_cancelled": "", "send_flag": "" }, { "mandt": "014", "agrno": "P167544306DC", "pos_nr": "005", "ein_nr": "000001", "konda": "H3", "beleinh": "TOIWUTK", "e_termin": "20181128", "inhk_eint": "RE", "inhk_plaz": "INRE", "azart_farb": "4C", "azart_plaz": "RHS", "anz_wnfs": "000", "breite_s": 6.34, "breite_seh": "", "hoehe_s": 5, "hoehe_seh": "", "netpr": 0, "waers": "INR", "zzinov_cd": "", "final_value": 0, "final_rate": 0, "ref_avm_nr": "", "ref_pos_nr": "000", "begda": "20181128", "endda": "20181128", "rev_cal_value": 0, "entry_type": "", "s_heft": "", "xstorniert": "", "pstyv": "0001", "azart_gest": "", "ad_size": 0, "inv_description": "", "metro_nonmetro": "", "zus_menge": 0, "zus_berech": "ZL", "score": "", "docalc": "", "original_endda": "00000000", "org_tcc": "", "upgrade_value": 0, "upgrade_percent": "000", "quot_app_block": false, "changed_by": "", "changed_on": "00000000", "changed_at": "00:00:00", "is_cancelled": "", "send_flag": "" } ] }';
        authPlatformEventObj.Opportunity_Id__c = oppObj.Id;
        authPlatformEventObj.rsp_Authorization_Id__c = '1111';
        authPlatformEventObj.rsp_Floor_Rate__c = '11';
        Test.startTest();
        
        // Publish test event
        Database.SaveResult sr = EventBus.publish(authPlatformEventObj);
            
        Test.stopTest();
        
    }
    static testMethod void testMethod5()
    {   
        
        rsp_Horizontal__c horObj = rsp_TestDataHelper.createHorizontal();
        insert horObj;
        System.assertnotEquals(horObj.Id , null);
        rsp_Geography__c geoObj = rsp_TestDataHelper.createGeography();
        insert geoObj;
        System.assertnotEquals(geoObj.Id , null);
        Account accObj = rsp_TestDataHelper.createAccount();
        accObj.rsp_Geography__c = geoObj.Id;
        accObj.rsp_Sales_office__c = geoObj.Id;
        insert accObj;
        System.assertnotEquals(accObj.Id , null);
        rsp_vertical__c verticalObj = rsp_TestDataHelper.createVertical();
        //verticalObj.Name = 'CLASSIFIEDS';
        insert verticalObj;
        System.assertnotEquals(verticalObj.Id , null);
        rsp_Role__c roleObj=rsp_TestDataHelper.createRole('Vertical',verticalObj.Id,null,geoObj.Id);
       Profile__c profileObj=rsp_TestDataHelper.createProfile();
       profileObj.Name = 'President';
       profileObj.rsp_Profile_Initials__c = 'NVH';
       insert profileObj;
       System.assertnotEquals(profileObj.Id , null);
       roleObj.rsp_Profile__c = profileObj.Id;
       roleObj.rsp_Current_User__c = userInfo.getUserId();
      insert roleObj;
      System.assertnotEquals(roleObj.Id , null);
        Opportunity oppObj = rsp_TestDataHelper.createOpportunity(accObj,verticalObj);
        oppObj.vertical__c = verticalObj.Id;
        oppObj.StageName = defaultStage;
        insert oppObj;
        System.assertnotEquals(oppObj.Id , null);
        insert rsp_TestDataHelper.createGroup();
        
        rsp_Sap_Authorization_Det_Platform_Event__e authPlatformEventObj = new rsp_Sap_Authorization_Det_Platform_Event__e();
        authPlatformEventObj.rsp_Qrn__c = deafultStr;
        authPlatformEventObj.rsp_Authorization_data__c = '{ "header": { "mandt": "014", "agrno": "1234", "descr": "", "inserent": "", "zzvercd": "0", "begda": "20181127", "endda": "00000000", "avm_nr": "", "appr_no": "", "userid": "aditya.tripathi1@timesgroup.com", "cpt_val": 0, "quotevalue": 1300, "ratevalue": 1300, "final_rate": 0, "final_value": 0, "client_name": "QWERTY", "inhk_eint": "", "qrn_type": "S", "user_name": "aditya.tripathi1@timesgroup.com", "erfdate": "20181127", "rev_calculated": "", "parent": "", "init_floor_value": 0, "init_final_value": 0, "xstorniert": "", "kampagne": "", "deal_value": 41210, "volume": 32, "object_id": "", "innovation_new": "0", "pricing_new": "1", "qrn_time": "13:52:18", "vkorg": "", "item_count": 1, "cube_processflg": "", "spart": "02", "extraln_val": 0, "final_val_bextra": 0, "last_extra_ln": 0, "zus_berech": "", "campexpectedval": 0, "campfeasibiltval": 0, "campdate": "", "horizontal": "0", "campid": "", "spl_adtype": "CD MULTICOLUMN", "camptext": "", "billing_block": "", "approval_date": "00000000", "approval_time": "00:00:00", "ros": "", "supersizing": "", "lastauthcode": "", "zzactexicd_d": "", "pricing_rational": "", "qrn_stage": "", "weekdayonly": "", "guar_jacket": "", "com_cobran": "", "co_branded_partn": "", "qrn_fest_schem": "", "auth": "", "unauth": "", "prefinal_val": 0, "upgrade_tag": "", "fallow_inv": "", "is_client": "", "auth_brand_name": "", "ad_type": "", "blk_flexi_addon": "", "groupcd": "", "special_rate": "", "second_section": "", "send_flag": "", "agencycode": "", "agency_name": "", "pricing_grp_par": "", "pricing_grp_name": "", "authtype": "" }, "detail": [ { "mandt": "014", "agrno": "P167544306DC", "pos_nr": "001", "ein_nr": "000001", "konda": "H3", "beleinh": "TOID", "e_termin": "20181128", "inhk_eint": "RE", "inhk_plaz": "INRE", "azart_farb": "4C", "azart_plaz": "RHS", "anz_wnfs": "000", "breite_s": 6.34, "breite_seh": "", "hoehe_s": 5, "hoehe_seh": "", "netpr": 0, "waers": "INR", "zzinov_cd": "", "final_value": 0, "final_rate": 0, "ref_avm_nr": "", "ref_pos_nr": "000", "begda": "20181128", "endda": "20181128", "rev_cal_value": 0, "entry_type": "", "s_heft": "", "xstorniert": "", "pstyv": "0001", "azart_gest": "", "ad_size": 0, "inv_description": "", "metro_nonmetro": "", "zus_menge": 0, "zus_berech": "ZL", "score": "", "docalc": "", "original_endda": "00000000", "org_tcc": "", "upgrade_value": 0, "upgrade_percent": "000", "quot_app_block": false, "changed_by": "", "changed_on": "00000000", "changed_at": "00:00:00", "is_cancelled": "", "send_flag": "" }, { "mandt": "014", "agrno": "P167544306DC", "pos_nr": "002", "ein_nr": "000001", "konda": "H3", "beleinh": "STOID", "e_termin": "20181202", "inhk_eint": "RE", "inhk_plaz": "INRE", "azart_farb": "4C", "azart_plaz": "RHS", "anz_wnfs": "000", "breite_s": 6.34, "breite_seh": "", "hoehe_s": 5, "hoehe_seh": "", "netpr": 0, "waers": "INR", "zzinov_cd": "", "final_value": 0, "final_rate": 0, "ref_avm_nr": "", "ref_pos_nr": "000", "begda": "20181202", "endda": "20181202", "rev_cal_value": 0, "entry_type": "", "s_heft": "", "xstorniert": "", "pstyv": "0001", "azart_gest": "", "ad_size": 0, "inv_description": "", "metro_nonmetro": "", "zus_menge": 0, "zus_berech": "ZL", "score": "", "docalc": "", "original_endda": "00000000", "org_tcc": "", "upgrade_value": 0, "upgrade_percent": "000", "quot_app_block": false, "changed_by": "", "changed_on": "00000000", "changed_at": "00:00:00", "is_cancelled": "", "send_flag": "" }, { "mandt": "014", "agrno": "P167544306DC", "pos_nr": "003", "ein_nr": "000001", "konda": "H3", "beleinh": "ETD", "e_termin": "20181128", "inhk_eint": "RE", "inhk_plaz": "INRE", "azart_farb": "4C", "azart_plaz": "RHS", "anz_wnfs": "000", "breite_s": 6.34, "breite_seh": "", "hoehe_s": 5, "hoehe_seh": "", "netpr": 0, "waers": "INR", "zzinov_cd": "", "final_value": 0, "final_rate": 0, "ref_avm_nr": "", "ref_pos_nr": "000", "begda": "20181128", "endda": "20181128", "rev_cal_value": 0, "entry_type": "", "s_heft": "", "xstorniert": "", "pstyv": "0001", "azart_gest": "", "ad_size": 0, "inv_description": "", "metro_nonmetro": "", "zus_menge": 0, "zus_berech": "ZL", "score": "", "docalc": "", "original_endda": "00000000", "org_tcc": "", "upgrade_value": 0, "upgrade_percent": "000", "quot_app_block": false, "changed_by": "", "changed_on": "00000000", "changed_at": "00:00:00", "is_cancelled": "", "send_flag": "" }, { "mandt": "014", "agrno": "P167544306DC", "pos_nr": "004", "ein_nr": "000001", "konda": "H3", "beleinh": "TOIDGR", "e_termin": "20181128", "inhk_eint": "RE", "inhk_plaz": "INRE", "azart_farb": "4C", "azart_plaz": "RHS", "anz_wnfs": "000", "breite_s": 6.34, "breite_seh": "", "hoehe_s": 5, "hoehe_seh": "", "netpr": 0, "waers": "INR", "zzinov_cd": "", "final_value": 0, "final_rate": 0, "ref_avm_nr": "", "ref_pos_nr": "000", "begda": "20181128", "endda": "20181128", "rev_cal_value": 0, "entry_type": "", "s_heft": "", "xstorniert": "", "pstyv": "0001", "azart_gest": "", "ad_size": 0, "inv_description": "", "metro_nonmetro": "", "zus_menge": 0, "zus_berech": "ZL", "score": "", "docalc": "", "original_endda": "00000000", "org_tcc": "", "upgrade_value": 0, "upgrade_percent": "000", "quot_app_block": false, "changed_by": "", "changed_on": "00000000", "changed_at": "00:00:00", "is_cancelled": "", "send_flag": "" }, { "mandt": "014", "agrno": "P167544306DC", "pos_nr": "005", "ein_nr": "000001", "konda": "H3", "beleinh": "TOIWUTK", "e_termin": "20181128", "inhk_eint": "RE", "inhk_plaz": "INRE", "azart_farb": "4C", "azart_plaz": "RHS", "anz_wnfs": "000", "breite_s": 6.34, "breite_seh": "", "hoehe_s": 5, "hoehe_seh": "", "netpr": 0, "waers": "INR", "zzinov_cd": "", "final_value": 0, "final_rate": 0, "ref_avm_nr": "", "ref_pos_nr": "000", "begda": "20181128", "endda": "20181128", "rev_cal_value": 0, "entry_type": "", "s_heft": "", "xstorniert": "", "pstyv": "0001", "azart_gest": "", "ad_size": 0, "inv_description": "", "metro_nonmetro": "", "zus_menge": 0, "zus_berech": "ZL", "score": "", "docalc": "", "original_endda": "00000000", "org_tcc": "", "upgrade_value": 0, "upgrade_percent": "000", "quot_app_block": false, "changed_by": "", "changed_on": "00000000", "changed_at": "00:00:00", "is_cancelled": "", "send_flag": "" } ] }';
        authPlatformEventObj.Opportunity_Id__c = oppObj.Id;
        authPlatformEventObj.rsp_Authorization_Id__c = '1111';
        authPlatformEventObj.rsp_Floor_Rate__c = '11';
        Test.startTest();
        
        // Publish test event
        Database.SaveResult sr = EventBus.publish(authPlatformEventObj);
            
        Test.stopTest();
        
    }
}
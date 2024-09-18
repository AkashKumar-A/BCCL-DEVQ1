@RestResource(urlMapping='/iq/qrn')
global class IqQrnWebService {
    @HttpPost
    global static void handlePostMethod() {
        String jsonBody = RestContext.request.requestBody.toString();
        System.debug('json: ' + jsonBody);
    }

    public class RequestWrapper {
        public QrnMasterClass tblUpdateQRNMst;
        public List<QrnDetailClass> tblUpdateQRNDtl;
    }

    public class QrnMasterClass {
        public Integer IQID;
        public String QRNNO;
        public String AGRNO;
        public String DESCR;
        public Integer ZZVERCD;
        public String HORIZONTAL;
        public String INNOVATION_NEW;
        public String QRN_TYPE;
        public String VKORG;
        public String CLIENT_NAME;
        public String INSERENT;
        public String SPART;
        public String OBJECT_ID;
        public Datetime QRN_TIME;
        public Decimal RATEVALUE;
        public Decimal FINAL_VALUE;
        public Decimal DEAL_VALUE;
        public Decimal CPT_VAL;
        public Decimal QUOTEVALUE;
        public String QRNValidity;
        public String USERID;
        public String LOGINID;
        public String PRINTDIGITAL;
        public Datetime BEGDA;
        public String INHK_EINT;
        public Datetime ERFDATE;
        public Decimal INIT_FLOOR_VALUE;
        public Decimal INIT_FINAL_VALUE;
        public Integer VOLUME;
        public Integer ITEM_COUNT;
        public Decimal NON_PRNTPKG_VAL;
        public Decimal TOTALQRNVALUE;
        public String REV_CALCULATED;
        public String COM_COBRAN;
        public String CO_BRANDED_PARTN;
        public String AD_TYPE;
        public String AGENCY_NAME;
        public String LASTAUTHCODE;
        public String WEEKDAYONLY;
        public String ROS;
        public Decimal DISCOUNT_PERCENT;
        public Decimal DISCOUNTED_VALUE;
        public String PRICING_NEW;
        public String UpdatedBy;
        public Datetime UpdatedDate;
        public Boolean IsActive;
    }

    public class QrnDetailClass {
        public Integer Id;
        public Integer NEW_ID;
        public Integer Insertion;
        public Integer LineItemNo;
        public String MANDT;
        public String AGRNO;
        public String BELEINH;
        public String AZART_FARB;
        public String REF_AVM_NR;
        public Datetime BEGDA;
        public Datetime ENDDA;
        public Datetime E_TERMIN;
        public String AZART_PLAZ;
        public String KONDA;
        public Integer POS_NR;
        public Integer EIN_NR;
        public String WAERS;
        public String INHK_EINT;
        public String INHK_PLAZ;
        public Integer ANZ_WNFS;
        public Decimal BREITE_S;
        public Decimal HOEHE_S;
        public String ZZINOV_CD;
        public Integer S_HEFT;
        public Integer PSTYV;
        public String ROS;
        public String WEEKDAYKEY;
        public String S_HEFT1;
        public Decimal NETPR;
        public Decimal REV_CAL_VALUE;
        public Decimal PRICING_VALUE;
        public Decimal DISCOUNT_PERCENT;
        public Decimal DISCOUNTED_VALUE;
        public String I_UPDATE;
    }
}
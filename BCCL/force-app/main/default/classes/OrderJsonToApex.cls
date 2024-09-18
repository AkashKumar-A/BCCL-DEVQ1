/*@author :- Laxman Singh
    @Company :- Saasfocus
    @description :- This wrapper class is used in rspOrderPlatformTriggerHandler class for parsing the JSON for order
                    coming through platfrom event.
    Created Date: 10-Oct-2018 
  */
public class OrderJsonToApex {

    public class Orderlineitem {
        public String pos_nr;
        public String packetid;
        public String avm_nr;
        public String bu;
        public String bcc;
        public String e_termin;
        public Double size;
        public Double width;
        public Double height;
        public String innovation;
        public String horizontal;
        public String horiz_group_mr;
        public String horiz_group_et;
        public String horiz_group_ls;
        public String horiz_group_lang;
        public String horiz_group_imr;
        public String amount;
        public String status;
        public String pstyv;
        public String subcategory;
        public String category;
        // Added by Kewal Sharma on 27-October-2022 for Item level response Revenue
        public String rsp_response_revenue;
        // Added by Kewal Sharma on 29-Aug-2024 for Collections;
        public String due_date;
        public String agency_due_date;
    }
    public String distribution_channel;
    public String subcategory;
    public String packetid;        
    public String category;
    public String avm_nr;
    public String agrno;
    public String advertiser;
    public String agency;
    public String rono;
    public String rodate;
    public string orderdate;
    public String vkorg;
    public String vkbur;
    public String qrn;
    public String vertical;
    public String barter;
    public String zzoppid;
    public String spart;
    public String amount;
    public String insertions;
    public String status;
    //Tag Activation Code
    public String activationcode;
    public List<Orderlineitem> orderlineitem;
    // Added by Kewal Sharma on 29-Aug-2024 for Order Payment Terms
    public String zterm;

    public static OrderJsonToApex parse(String json) {
        return (OrderJsonToApex) System.JSON.deserialize(json, OrderJsonToApex.class);
    }
}
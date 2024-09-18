public class rsp_ResponseConstants {
    
    public static boolean SKIP_TRIGGER = false;
    //Added by laxman for skip distribution channel
    public static final Set<String> ORDER_DISTRIBUTION_CHANNEL = new SET<String>{'IN'};
    public static final String ACCOUNT_STATUS_PERMANENT = 'Permanent';
    public static final String ACCOUNT_STATUS_TEMPORARY = 'Temporary';
    public static final String BEHAVIOUR_KRA = 'BEHAVIOUR';
    public static final String SUCCESS_MESSAGE = 'SUCCESS';
    public static final String ERROR_MESSAGE = 'ERROR';
    public static final String CURRENT_FINANCIAL_YEAR = '{CurrentFinancialYear}';
    public static final String USER_NAME = '{UserName}';
    public static final String ACHIEVEMENT_CLAIM_APPROVED = 'Approved';
    public static final String ACHIEVEMENT_CLAIM_REJECTED = 'Rejected';
    public static final String ACHIEVEMENT_CANCELLED = 'Cancelled';
    public static final String ACHIEVEMENT_ASSIGNED = 'Assigned';
    public static final String ACHIEVEMENT_OPEN = 'Open';
    public static final String ACHIEVED_TARGET_APPROVED = 'Approved';
    
    //Profiles
    public static final String BRANCH_VERTICAL_HEAD = 'Branch Vertical Head';
    public static final String NATIONAL_VERTICAL_HEAD = 'National Vertical Head';
    public static final String SALES_TEAM_MEMBER = 'Sales Team Member';
    public static final String TARGET_TYPE_MARKET_SHARE = 'Market Share';
    public static final String TARGET_TYPE_BEHAVIOURAL = 'Behaviour';
    public static final String SUB_OFFICE_HEAD = 'SUB-OFFICE HEAD';
    public static final String Pricing_Head= 'Pricing Head';
    public static final String President= 'President';
    public static final String RA_Team_Lead= 'RA Team Lead';
    public static final String Pricing_Team_Lead= 'Pricing Team Lead';
    public static final String Operation_Team_Lead= 'Operation Team Lead';
    public static final String Creative_Team_Lead= 'Creative Team Lead';
    public static final String Pricing_Team_Member= 'Pricing Team Member';
    public static final String Director= 'Director';

    
    //Target
    public static final String TARGET_TYPE_REVENUE = 'Revenue';
    public static final String TARGET_TYPE_YIELD = 'Yield';
    // updated by Laxman 05-03-2020, as we dont need Yield AT
    public static final String TARGET_TYPE_NOT_YIELD = 'No Yield';
    public static final String TARGET_APPROVED = 'Approved';
    
    public static final String ORDER_ITEM_BILLED = 'Invoiced / billed';
    public static final String BRANCH_HORIZONTAL_HEAD = 'Branch Horizontal Head';
    public static final String NATIONAL_HORIZONTAL_HEAD = 'National Horizontal Head';
    public static final String BRANCH_HEAD = 'Branch Head';
    public static final String ORDER_ITEM_CANCELLED = 'Cancelled';
    
    public static final String KRA_MAIN_FUNCTION = 'Development';
    public static final String KRA_FUNCTION_DEVELOPMENT = 'Development';
    public static final String GEOGRAPHY_TYPE_SALES_OFFICE = 'Sales Office';
    public static final String GEOGRAPHY_TYPE_SALES_ORG = 'Sales Org';
    
    public static final String HIERARCHY_TYPE_VERTICAL = 'Vertical';
    public static final String HIERARCHY_TYPE_HORIZONTAL = 'Horizontal';
    
    //Lead Reccord Type
    public static final String LEAD_RT_BCCL_NON_PRINT_REVENUE = 'BCCL_Non_Print_Revenue';
    public static final String LEAD_RT_BCCL_ONLY_PRINT_CLIENTS_BUYING_NON_PRINT_FROM_GROUP_COMPANIES = 'BCCL_Only_Print_Clients_buying_Non_Print_from_Group_Companies';
    public static final String LEAD_RT_COMPETITION_EXCLUSIVE_CLIENTS = 'Competition_exclusive_clients';
    public static final String LEAD_RT_COMPETITION_EXCLUSIVE_PRINT_ADEX = 'competition_exclusive_print_Adex';
    public static final String LEAD_RT_COMPETITION_EXCLUSIVE_PRINT_TAM = 'competition_exclusive_print_TAM';
    public static final String LEAD_RT_FESTIVE_PERIOD_REVENUE_ANALYSIS_COMP_EXCLUSIVE = 'Festive_period_Revenue_analysis_Comp_Exclusive ';
    public static final String LEAD_RT_FESTIVE_PERIOD_REVENUE_ANALYSIS_REVENUE_DECLINE_NON_ADVERTISER_IN_PY = 'Festive_period_Revenue_analysis_Revenue_Decline_Non_advertiser_in_PY';
    public static final String LEAD_RT_INVENTORY_BASED_OPPORTUNITY_CONSOLIDATE_ON_MOST_PREMIUM_PG = 'Inventory_based_opportunity_Consolidate_on_most_premium_pg';
    public static final String LEAD_RT_INVENTORY_BASED_OPPORTUNITY_FIRST_TIME_UPGRADE = 'Inventory_based_opportunity_First_time_upgrade';
    public static final String LEAD_RT_INVENTORY_BASED_OPPORTUNITY_UPGRADE_FROM_RD_TO_PREMIUM_POSITIONS = 'Inventory_based_opportunity_Upgrade_from_RD_to_premium_positions';
    public static final String LEAD_RT_MS_DECLINE = 'MS_decline';
    public static final String LEAD_RT_MOVING_CLIENTS_FROM_ONLY_BASE_BUYING_TO_ADDONPACKAGESCOSS_SELLINGUP_SELLING = 'Moving_clients_from_only_base_buying_to_addonpackagescoss_sellingup_selling';
    public static final String LEAD_RT_MOVING_UP_THE_VALUE_CHAIN_CLASSIFIEDS_TO_DISPLAY = 'Moving_up_the_value_chain_Classifieds_to_Display';
    public static final String LEAD_RT_OPTIMISE_CLIENT_CHURN_AND_IMPROVE_RETENTION = 'Optimise_client_churn_and_improve_retention';
    public static final String LEAD_RT_TARGETING_AND_CONVERSION_OF_TV_RADIO_EXCLUSIVE_CLIENTS = 'Targeting_and_conversion_of_TV_Radio_exclusive_clients';
    
    //rsp_PackageProductTriggerHandler constants
    public static final String LANGUAGE_HORIZONTAL = 'Languages';
    public static final String MIRRORS_HORIZONTAL = 'MIRRORS';
    public static final String LONGTAIL_HORIZONTAL = 'LONGTAIL';
    public static final String BRANCHSALES_HORIZONTAL = 'BRANCH SALES';
    public static final String ALLIANCES_HORIZONTAL = 'ALLIANCES';
    public static final String IMR_HORIZONTAL = 'IMR';
    public static final String ET_HORIZONTAL = 'ET,ET AFP';
    
    public static boolean IS_ACHIEVEMENT_TRANSFER = false;
    public static final String BEHAVIOURAL_KRA_SHORTCODE = 'BEH';
}
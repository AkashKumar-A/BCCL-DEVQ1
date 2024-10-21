public class TvpController {
	@AuraEnabled
	public static ResponseWrapper getRoleWiseRevenue(String dateStr){
		try {
			String userId = UserInfo.getUserId();
			ResponseWrapper response = new ResponseWrapper();
			List<rsp_Role__c> listOfRole = getRole(userId);
			Map<Id,rsp_Target__c> mapRoleToTarget = getCurrentMonthTarget(listOfRole, userId, dateStr);
			List<Response> listToResponse = new List<Response>();
			Decimal userTarget = 0;
			Decimal committedPiplineUser =0;
			Decimal scheduledtoPrintUser =0;
			Decimal publishedUser =0;
			Decimal invoiceBilledUser =0;
			if(listOfRole != null && listOfRole.size() > 0 ) {
				for(rsp_Role__c each :listOfRole) {
					Response revenueObj = new Response();
					revenueObj.roleName = each.Name;
					Response res = getRevenueForCommitted(each, dateStr);
					if(res != null) {
						revenueObj.committedPipline = ((res.committedPipline)/100000).setScale(2);
						revenueObj.scheduledtoPrint = ((res.scheduledtoPrint)/100000).setScale(2);
						revenueObj.published = ((res.published)/100000).setScale(2);
					}
					else {
						revenueObj.committedPipline = 0;
						revenueObj.scheduledtoPrint = 0;
						revenueObj.published = 0;
					}
					revenueObj.invoiceBilled = getRevenueForFixed(each,dateStr) != null? (getRevenueForFixed(each,dateStr)/100000).setScale(2):0.00;
					revenueObj.roleTarget = mapRoleToTarget.get(each.Id)?.rsp_Assigned_Target__c != null ? ((mapRoleToTarget.get(each.Id)?.rsp_Assigned_Target__c)/100000 ).setScale(2): 0.00;
					userTarget += revenueObj.roleTarget != null ? (revenueObj.roleTarget).setScale(2) :0.00;
					committedPiplineUser += revenueObj.committedPipline != null ? (revenueObj.committedPipline).setScale(2) :0.00;
					scheduledtoPrintUser += revenueObj.scheduledtoPrint != null ? (revenueObj.scheduledtoPrint).setScale(2) :0.00;
					publishedUser += revenueObj.published != null ? (revenueObj.published).setScale(2) :0.00;
					invoiceBilledUser += revenueObj.invoiceBilled != null ? (revenueObj.invoiceBilled).setScale(2) :0.00;
					if (revenueObj.committedPipline != null && revenueObj.roleTarget != null && revenueObj.roleTarget > 0) {
						revenueObj.preCommittedAchievement = ((revenueObj.committedPipline / revenueObj.roleTarget) * 100).setScale(2);
					} else {
						revenueObj.preCommittedAchievement = 0.00;
					}
					if (revenueObj.invoiceBilled != null && revenueObj.roleTarget != null && revenueObj.roleTarget > 0) {
						revenueObj.perFixedAchievement = ((revenueObj.invoiceBilled / revenueObj.roleTarget) * 100).setScale(2);
					} else {
						revenueObj.perFixedAchievement = 0.00;
					}
					listToResponse.add(revenueObj);
				}
			}
			response.roleWise = listToResponse;
			List<Response> listToUser = new List<Response>();
			Response res = new Response();
			res.roleTarget = userTarget;
			res.committedPipline = (committedPiplineUser).setScale(2);
			res.scheduledtoPrint = (scheduledtoPrintUser).setScale(2);
			res.published = (publishedUser).setScale(2);
			res.preCommittedAchievement = ((res.committedPipline / ((res.roleTarget != null && res.roleTarget >0) ? res.roleTarget :1))*100).setScale(2);
			res.invoiceBilled  = (invoiceBilledUser).setScale(2);
			res.perFixedAchievement = ((res.invoiceBilled /((res.roleTarget != null && res.roleTarget >0) ? res.roleTarget :1))*100).setScale(2);
			res.fixedIncentivePayout = getPayoutPercentage(dateStr, res.perFixedAchievement);
			Decimal projectPercentage = (((res.committedPipline != null ? res.committedPipline :0) + (res.invoiceBilled != null ? res.invoiceBilled : 0 ))/((res.roleTarget != null && res.roleTarget >0) ? res.roleTarget :1))*100;
			res.projectedIncentivePayout = getPayoutPercentage(dateStr, projectPercentage);
			listToUser.add(res);
			response.userWise = listToUser;
			return response;
		} catch (Exception e) {
			throw new AuraHandledException(e.getMessage());
		}
	}
	private Static List<rsp_Role__c> getRole(String userId) {
		List<rsp_Role__c> listOfRole = [
			SELECT Id, rsp_Hierarchy_Type__c, Name, rsp_Geography__r.rsp_Type__c, rsp_Current_User__c, rsp_Vertical__r.Name, rsp_Horizontal__r.Name,
			rsp_Geography__r.rsp_Geo_Code__c
			FROM rsp_Role__c WHERE
			rsp_Current_User__c = :userId
		];
		return listOfRole;
	}
	private static Decimal getRevenueForFixed(rsp_Role__c role, String dateStr) {
		currentMonthDate dateRange = getCurrentMonth(dateStr);
		List<AggregateResult> resultList = [
			SELECT Id, SUM(rsp_Achievement_Value__c) totalValue
			FROM rsp_Achievement__c WHERE
			rsp_Role__c = :role.Id AND
			rsp_Achievement_Date__c >= :dateRange.startDate AND
			rsp_Achievement_Date__c <= :dateRange.endDate AND
			rsp_Credit_Split_Status__c = 'Assigned' GROUP BY Id
		];
    	if (!resultList.isEmpty()) {
    	    // Access the SUM value from the first (and only) result
			Decimal totalPrice = 0;
			for(AggregateResult result :resultList){
    	    	totalPrice += (Decimal) result.get('totalValue');
			}
    	    
    	    return totalPrice != null ? totalPrice : 0;
    	} else {
    	    return 0; 
    	}
	}
	private static Response getRevenueForCommitted(rsp_Role__c role, String dateStr) {
		String verticalAndHorizontal = role.rsp_Vertical__c != null ? role.rsp_Vertical__r.Name : (role.rsp_Horizontal__r != null ? role.rsp_Horizontal__r.Name :'');
		Boolean isSalesOrg = role.rsp_Geography__c != null ? role.rsp_Geography__r.rsp_Type__c == 'SALES ORG': false;
		Boolean isVertical = role.rsp_Hierarchy_Type__c != null ? role.rsp_Hierarchy_Type__c == 'Vertical' : false;
		currentMonthDate dateRange = getCurrentMonth(dateStr);
		System.debug(String.valueOf(dateRange.startDate));
		String query = 'SELECT Id,TotalPrice, rsp_Status__c FROM OrderItem WHERE Publishing_Date__c >= '+ String.valueOf(dateRange.startDate) + ' AND Publishing_Date__c <= '+String.valueOf(dateRange.endDate) +' AND (rsp_Status__c = \'Scheduled to print\' OR rsp_Status__c = \'Published\')';
		if(isSalesOrg) {
			query += ' AND Order.rsp_Geography__c = \''+role.rsp_Geography__r.rsp_Geo_Code__c+'\'';
		}
		else {
			query += ' AND Order.rsp2_Sales_Office_Geo_Code__c = \''+role.rsp_Geography__r.rsp_Geo_Code__c + '\'';
		}
		if(isVertical) {
			query += ' AND Order.rsp_Vertical__c = \''+ role.rsp_Vertical__c+ '\'';
		}
		else{
			query += ' AND rsp_Horizontals__c  INCLUDES (\'' + role.rsp_Horizontal__r.Name + '\')';
		}
		System.debug(query);
		List<OrderItem> resultList = Database.query(query);
		Decimal scheduledtoPrint = 0;
		Decimal published = 0;
		Response resObj = new Response();
    	if (!resultList.isEmpty()) {
    	    for(OrderItem each :resultList) {
				if(each.rsp_Status__c ==  'Scheduled to print') {
					scheduledtoPrint += each.totalPrice != null ? each.totalPrice :0;
				}
				if(each.rsp_Status__c == 'Published') {
					published += each.totalPrice != null ? each.totalPrice :0;
				}
			}
			resObj.committedPipline = scheduledtoPrint + published;
			resObj.scheduledtoPrint = scheduledtoPrint;
			resObj.published = published;
			return resObj;
    	} else {
    	    return null; 
    	}
	}
	private static Map<Id,rsp_Target__c> getCurrentMonthTarget(List<rsp_Role__c> listOfRole, String userId, String dateStr) {
		currentMonthDate currentMonthDates = getCurrentMonth(dateStr);
		Map<Id,rsp_Target__c> roleToTarget = new Map<Id,rsp_Target__c>();
		list<rsp_Target__c> listOfTarget = [
			SELECT Id, rsp_Target_Month__c, OwnerId, rsp_Role__c, rsp_Assigned_Target__c, rsp_Target_Type__c, rsp_Start_Date__c, rsp_End_Date__c, rsp_Is_Roll_Up_target__c 
			FROM rsp_Target__c  WHERE
			rsp_Start_Date__c >= :currentMonthDates.startDate AND
			rsp_End_Date__c <= :currentMonthDates.endDate AND
			rsp_Is_Roll_Up_target__c = false AND
			rsp_Target_Type__c = 'Revenue' AND
			rsp_Role__c IN :listOfRole
		];
		if(listOfTarget != null && listOfTarget.size() > 0) {
			for(rsp_Target__c each :listOfTarget) {
				if (roleToTarget.containsKey(each.rsp_Role__c)) {
					if (each.OwnerId == userId) {
						roleToTarget.put(each.rsp_Role__c, each);
					}
				} else {
					roleToTarget.put(each.rsp_Role__c, each);
				}
			}
		}
		return roleToTarget;
	}

	@AuraEnabled
	public static Decimal  getPayoutPercentage(String dateStr, Decimal percentage) {
		currentMonthDate dateOfMoth = getCurrentMonth(dateStr);
		List<rsp_Incentive_Mapping__c> listOfMapping = [
			SELECT id, Min_Achievement__c, Max_Achievement__c, Min_Payout__c, Max_Payout__c, rsp_Start_Date__c, rsp_End_Date__c 
			FROM rsp_Incentive_Mapping__c WHERE
			rsp_Start_Date__c <= :dateOfMoth.startDate AND
			rsp_End_Date__c >= :dateOfMoth.endDate
		];
		rsp_Incentive_Mapping__c incentiveMapping = null;
		if(listOfMapping != null && listOfMapping.size() > 0 ) {
			for (rsp_Incentive_Mapping__c mapping : listOfMapping) {
				if (percentage >= mapping.Min_Achievement__c && percentage <= mapping.Max_Achievement__c) {
					incentiveMapping =  mapping;
				}
			}
		}
		if(incentiveMapping != null && percentage > 0) {
			Decimal incentivePercentage = incentiveMapping.Min_Payout__c + ((incentiveMapping.Max_Payout__c - incentiveMapping.Min_Payout__c) * (percentage - incentiveMapping.Min_Achievement__c))/(incentiveMapping.Max_Achievement__c - incentiveMapping.Min_Achievement__c);
			return incentivePercentage;
		}
		return 0;		
	}
	private static currentMonthDate getCurrentMonth(String dateStr) {
		String[] parts = dateStr.split('-');
        Integer month = Integer.valueOf(parts[0]);
        Integer year = Integer.valueOf(parts[1]);
        Date startDate = (Date.newInstance(year, month, 1));
        Date endDate;
        if (month == 12) {
            endDate = (Date.newInstance(year + 1, 1, 1).addDays(-1));
        } else {
            endDate = (Date.newInstance(year, month + 1, 1).addDays(-1));
        }
		currentMonthDate obj = new currentMonthDate();
		obj.startDate = startDate;
		obj.endDate = endDate;
		return obj;
	}
	public class currentMonthDate {
		public Date startDate;
		public Date endDate;
	}
	public class ResponseWrapper {
		@AuraEnabled public List<Response> roleWise;
		@AuraEnabled public List<Response> userWise;
	}
	public class Response {
		@AuraEnabled public String roleName;
		@AuraEnabled public Decimal roleTarget;
		@AuraEnabled public Decimal committedPipline;
		@AuraEnabled public Decimal scheduledtoPrint;
		@AuraEnabled public Decimal published;
		@AuraEnabled public Decimal preCommittedAchievement;
		@AuraEnabled public Decimal invoiceBilled;
		@AuraEnabled public Decimal perFixedAchievement;
		@AuraEnabled public Decimal fixedIncentivePayout;
		@AuraEnabled public Decimal projectedIncentivePayout;
	}
}
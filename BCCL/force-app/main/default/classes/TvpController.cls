public class TvpController {
	@AuraEnabled
	public static ResponseWrapper getRoleWiseRevenue(String dateStr){
		try {
			/*
			currentMonthDate dateOfMonth = getCurrentMonth(dateStr);
			Date startDate = dateOfMonth.startDate;
			Date endDate = dateOfMonth.endDate;
			String userId = UserInfo.getUserId();
			ResponseWrapper response = new ResponseWrapper();
			List<rsp_Role__c> listOfRole = getRole(userId);
			Map<Id,rsp_Target__c> mapRoleToTarget = getCurrentMonthTarget(listOfRole, userId, startDate, endDate);
			List<Response> listToResponse = new List<Response>();
			Decimal userTarget = 0;
			Decimal committedPiplineUser =0;
			Decimal scheduledtoPrintUser =0;
			Decimal publishedUser =0;
			Decimal invoiceBilledUser =0;
			Decimal psiSum = 0;
			if(listOfRole != null && listOfRole.size() > 0 ) {
				for(rsp_Role__c each :listOfRole) {
					Response revenueObj = new Response();
					revenueObj.roleName = each.Name;
					Response res = getRevenueForCommitted(each, startDate, endDate);
					if(res != null) {
						revenueObj.committedPipline = ((res.committedPipline)/100000);
						revenueObj.scheduledtoPrint = ((res.scheduledtoPrint)/100000);
						revenueObj.published = ((res.published)/100000);
					}
					else {
						revenueObj.committedPipline = 0;
						revenueObj.scheduledtoPrint = 0;
						revenueObj.published = 0;
					}
					Decimal invoiceAmount = getRevenueForFixed(each, startDate, endDate);
					revenueObj.invoiceBilled = invoiceAmount != null? (invoiceAmount/100000):0.00;
					revenueObj.PSI = revenueObj.committedPipline + revenueObj.invoiceBilled;
					psiSum += revenueObj.PSI;
					revenueObj.roleTarget = mapRoleToTarget.get(each.Id)?.rsp_Assigned_Target__c != null ? ((mapRoleToTarget.get(each.Id)?.rsp_Assigned_Target__c)/100000 ).setScale(2): 0.00;
					userTarget += revenueObj.roleTarget != null ? (revenueObj.roleTarget) :0.00;
					committedPiplineUser += revenueObj.committedPipline != null ? (revenueObj.committedPipline) :0.00;
					scheduledtoPrintUser += revenueObj.scheduledtoPrint != null ? (revenueObj.scheduledtoPrint) :0.00;
					publishedUser += revenueObj.published != null ? (revenueObj.published) :0.00;
					invoiceBilledUser += revenueObj.invoiceBilled != null ? (revenueObj.invoiceBilled).setScale(2) :0.00;
					revenueObj.prePSI = (((revenueObj.PSI != null ? revenueObj.PSI :0)/((revenueObj.roleTarget != null && revenueObj.roleTarget >0?revenueObj.roleTarget:1))) *100).setScale(2);
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
			res.PSI = (psiSum).setScale(2);
			res.prePSI = ((res.PSI / ((res.roleTarget != null && res.roleTarget >0)?res.roleTarget :1))*100).setScale(2);
			res.preCommittedAchievement = ((res.committedPipline / ((res.roleTarget != null && res.roleTarget >0) ? res.roleTarget :1))*100).setScale(2);
			res.invoiceBilled  = (invoiceBilledUser).setScale(2);
			res.perFixedAchievement = ((res.invoiceBilled /((res.roleTarget != null && res.roleTarget >0) ? res.roleTarget :1))*100).setScale(2);
			// res.fixedIncentivePayout = (getPayoutPercentage(dateStr, res.perFixedAchievement)).setScale(2);
			Decimal projectPercentage = (((res.committedPipline != null ? res.committedPipline :0) + (res.invoiceBilled != null ? res.invoiceBilled : 0 ))/((res.roleTarget != null && res.roleTarget >0) ? res.roleTarget :1))*100;
			// res.projectedIncentivePayout = (getPayoutPercentage(dateStr, projectPercentage)).setScale(2);
			res.responseIncentive = (getPayoutPercentage(startDate, endDate, res.prePSI)).setScale(2);
			listToUser.add(res);
			response.userWise = listToUser;
			return response;
			*/

			String userId = UserInfo.getUserId();
			List<Trimester> trimesters = getCurrentFiscalYearTrimesters();
			Integer currentYear = Date.today().year();
			Integer fiscalYearStartYear = Date.today().month() >= 4 ? currentYear : currentYear - 1;
			List<Response> listOfResponse = new List<Response>();
			ResponseWrapper response = new ResponseWrapper();

			Decimal userTarget = 0;
			Decimal committedPiplineUser = 0;
			Decimal scheduledtoPrintUser = 0;
			Decimal publishedUser = 0;
			Decimal invoiceBilledUser = 0;
			Decimal psiSum = 0;
			currentMonthDate dateOfMonth = getCurrentMonth(dateStr);
			Date startDate = dateOfMonth.startDate;
			Date endDate = dateOfMonth.endDate;
			List<rsp_Role__c> listOfRole = getRole(userId);
			Map<Id, Decimal> roleToAchievedTarget = getRevenueForFixed(listOfRole, startDate, endDate);
			Map<Id, Decimal> roleToTarget = getMonthlyTarget(listOfRole, userId, startDate, endDate);
			Map<Id, Response> roleToCommittedRevenue = getRevenueForCommitted(listOfRole, startDate, endDate);
			
			if(listOfRole != null && listOfRole.size() > 0 ) {
				for(rsp_Role__c each :listOfRole) {
					Response revenueObj = new Response();
					revenueObj.roleName = each.Name;
					Response res = roleToCommittedRevenue.get(each.Id);
					if(res != null) {
						revenueObj.committedPipline = ((res.committedPipline)/100000);
						revenueObj.scheduledtoPrint = ((res.scheduledtoPrint)/100000);
						revenueObj.published = ((res.published)/100000);
					}
					else {
						revenueObj.committedPipline = 0;
						revenueObj.scheduledtoPrint = 0;
						revenueObj.published = 0;
					}
					Decimal invoiceAmount = roleToAchievedTarget.get(each.Id);
					revenueObj.invoiceBilled = invoiceAmount != null? (invoiceAmount/100000):0;
					revenueObj.PSI = revenueObj.committedPipline + revenueObj.invoiceBilled;
					revenueObj.roleTarget = roleToTarget.get(each.Id) != null ? ((roleToTarget.get(each.Id))/100000 ): 0.00;
					revenueObj.prePSI = (((revenueObj.PSI != null ? revenueObj.PSI :0)/((revenueObj.roleTarget != null && revenueObj.roleTarget > 0?revenueObj.roleTarget:1))) *100);
					revenueObj.responseIncentive = (getPayoutPercentage(startDate, endDate, revenueObj.prePSI)).setScale(2);
					
					listOfResponse.add(revenueObj);
					userTarget += revenueObj.roleTarget != null ? (revenueObj.roleTarget) :0;
					invoiceBilledUser += revenueObj.invoiceBilled;
					scheduledtoPrintUser += revenueObj.scheduledtoPrint;
					publishedUser += revenueObj.published;
					psiSum += revenueObj.PSI;
				}	
			}
			
			List<Response> anunalList = new List<Response>();
			Response res = new Response();
			res.roleTarget = userTarget;
			res.scheduledtoPrint = scheduledtoPrintUser;
			res.published = publishedUser;
			res.invoiceBilled = invoiceBilledUser;
			res.PSI = psiSum;
			res.prePSI = (res.PSI / ((res.roleTarget != null && res.roleTarget != 0) ? res.roleTarget : 1))*100;
			res.responseIncentive = getPayoutPercentage(startDate, endDate, res.prePSI);
			anunalList.add(res);
			response.userWise = anunalList;
			response.roleWise = listOfResponse;
			return response;
		} catch (Exception e) {
			throw new AuraHandledException(e.getMessage());
		}
	}
	/*
	private Static List<rsp_Role__c> getRole(String userId) {
		List<rsp_Role__c> listOfRole = [
			SELECT Id, rsp_Hierarchy_Type__c, Name, rsp_Geography__r.rsp_Type__c, rsp_Current_User__c, rsp_Vertical__r.Name, rsp_Horizontal__r.Name,
			rsp_Geography__r.rsp_Geo_Code__c
			FROM rsp_Role__c WHERE
			rsp_Current_User__c = :userId
		];
		return listOfRole;
	}
	private static Decimal getRevenueForFixed(rsp_Role__c role, Date startDate, Date endDate) {
		List<AggregateResult> resultList = [
			SELECT Id, SUM(rsp_Achievement_Value__c) totalValue
			FROM rsp_Achievement__c WHERE
			rsp_Role__c = :role.Id AND
			rsp_Achievement_Date__c >= :startDate AND
			rsp_Achievement_Date__c <= :endDate AND
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
	private static Response getRevenueForCommitted(rsp_Role__c role, Date startDate, Date endDate) {
		String verticalAndHorizontal = role.rsp_Vertical__c != null ? role.rsp_Vertical__r.Name : (role.rsp_Horizontal__r != null ? role.rsp_Horizontal__r.Name :'');
		Boolean isSalesOrg = role.rsp_Geography__c != null ? role.rsp_Geography__r.rsp_Type__c == 'SALES ORG': false;
		Boolean isVertical = role.rsp_Hierarchy_Type__c != null ? role.rsp_Hierarchy_Type__c == 'Vertical' : false;
		System.debug(String.valueOf(startDate));
		String query = 'SELECT Id,TotalPrice, rsp_Status__c FROM OrderItem WHERE Publishing_Date__c >= '+ String.valueOf(startDate) + ' AND Publishing_Date__c <= '+String.valueOf(endDate) +' AND (rsp_Status__c = \'Scheduled to print\' OR rsp_Status__c = \'Published\')';
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
	private static Map<Id,rsp_Target__c> getCurrentMonthTarget(List<rsp_Role__c> listOfRole, String userId, Date startDate, Date endDate) {
		Map<Id,rsp_Target__c> roleToTarget = new Map<Id,rsp_Target__c>();
		list<rsp_Target__c> listOfTarget = [
			SELECT Id, rsp_Target_Month__c, OwnerId, rsp_Role__c, rsp_Assigned_Target__c, rsp_Target_Type__c, rsp_Start_Date__c, rsp_End_Date__c, rsp_Is_Roll_Up_target__c 
			FROM rsp_Target__c  WHERE
			rsp_Start_Date__c >= :startDate AND
			rsp_End_Date__c <= :endDate AND
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
	*/
	@AuraEnabled
	public static Decimal  getPayoutPercentage(Date startDate, Date endDate, Decimal percentage) {
		List<rsp_Incentive_Mapping__c> listOfMapping = [
			SELECT id, Min_Achievement__c, Max_Achievement__c, Min_Payout__c, Max_Payout__c, rsp_Start_Date__c, rsp_End_Date__c 
			FROM rsp_Incentive_Mapping__c WHERE
			rsp_Start_Date__c <= :startDate AND
			rsp_End_Date__c >= :endDate
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
			Decimal incentivePercentage = (incentiveMapping.Min_Payout__c ?? 0) + (((incentiveMapping.Max_Payout__c ?? 0) - (incentiveMapping.Min_Payout__c ?? 0)) * (percentage - (incentiveMapping.Min_Achievement__c ?? 0)))/(((incentiveMapping.Max_Achievement__c ?? 0) - (incentiveMapping.Min_Achievement__c ?? 0)) != 0 ?((incentiveMapping.Max_Achievement__c ?? 0) - (incentiveMapping.Min_Achievement__c ?? 0)):1);
			return incentivePercentage;
		}
		return 0;		
	}
	/* -----------------------------New code-------------------------------*/

	@AuraEnabled
	public static ResponseWrapper getTrimester(){
		try {
			String userId = UserInfo.getUserId();
			List<Trimester> trimesters = getCurrentFiscalYearTrimesters();
			Integer currentYear = Date.today().year();
			Integer fiscalYearStartYear = Date.today().month() >= 4 ? currentYear : currentYear - 1;
        	Date fiscalYearStartDate = Date.newInstance(fiscalYearStartYear, 4, 1); 
        	Date fiscalYearEndDate = Date.newInstance(fiscalYearStartYear + 1, 3, 31);
			List<Response> listOfResponse = new List<Response>();
			ResponseWrapper response = new ResponseWrapper();

			Decimal userTarget = 0;
			Decimal committedPiplineUser = 0;
			Decimal scheduledtoPrintUser = 0;
			Decimal publishedUser = 0;
			Decimal invoiceBilledUser = 0;
			Decimal psiSum = 0;


			for(Integer i = 0; i < trimesters.size(); i++) {
				Decimal userTargetTrimester = 0;
				Decimal committedPiplineUserTrimester = 0;
				Decimal scheduledtoPrintUserTrimester = 0;
				Decimal publishedUserTrimester = 0;
				Decimal invoiceBilledUserTrimester = 0;
				Decimal psiSumTrimester = 0;
				Date startDate = trimesters[i].startDate;
				Date endDate = trimesters[i].endDate;
				List<rsp_Role__c> listOfRole = getRole(userId);
				Map<Id, Decimal> roleToAchievedTarget = getRevenueForFixed(listOfRole, startDate, endDate);
				Map<Id, Decimal> roleToTarget = getMonthlyTarget(listOfRole, userId, startDate, endDate);
				Map<Id, Response> roleToCommittedRevenue = getRevenueForCommitted(listOfRole, startDate, endDate);

				
				if(listOfRole != null && listOfRole.size() > 0 ) {
					for(rsp_Role__c each :listOfRole) {
						Response revenueObj = new Response();
						revenueObj.roleName = each.Name;
						Response res = roleToCommittedRevenue.get(each.Id);
						if(res != null) {
							revenueObj.committedPipline = ((res.committedPipline)/100000);
							revenueObj.scheduledtoPrint = ((res.scheduledtoPrint)/100000);
							revenueObj.published = ((res.published)/100000);
						}
						else {
							revenueObj.committedPipline = 0;
							revenueObj.scheduledtoPrint = 0;
							revenueObj.published = 0;
						}
						Decimal invoiceAmount = roleToAchievedTarget.get(each.Id);
						revenueObj.invoiceBilled = invoiceAmount != null? (invoiceAmount/100000):0;
						revenueObj.PSI = revenueObj.committedPipline + revenueObj.invoiceBilled;
						revenueObj.roleTarget = roleToTarget.get(each.Id) != null ? ((roleToTarget.get(each.Id))/100000 ): 0.00;
						revenueObj.prePSI = (((revenueObj.PSI != null ? revenueObj.PSI :0)/((revenueObj.roleTarget != null && revenueObj.roleTarget >0?revenueObj.roleTarget:1))) *100);
						//revenueObj.responseIncentive = (getPayoutPercentage(startDate, endDate, revenueObj.prePSI)).setScale(2);
						revenueObj.trimesterName = trimesters[i].name;
						
						userTarget += revenueObj.roleTarget != null ? (revenueObj.roleTarget) :0;
						invoiceBilledUser += revenueObj.invoiceBilled;
						scheduledtoPrintUser += revenueObj.scheduledtoPrint;
						publishedUser += revenueObj.published;
						psiSum += revenueObj.PSI;

						userTargetTrimester += revenueObj.roleTarget != null ? (revenueObj.roleTarget) :0;
						scheduledtoPrintUserTrimester += revenueObj.scheduledtoPrint;
						publishedUserTrimester +=  revenueObj.published;
						invoiceBilledUserTrimester += revenueObj.invoiceBilled;
						psiSumTrimester += revenueObj.PSI;


					}	
				}
				Response revenueTri = new Response();
				revenueTri.trimesterName = trimesters[i].name;
				revenueTri.roleTarget = userTargetTrimester;
				revenueTri.scheduledtoPrint = scheduledtoPrintUserTrimester;
				revenueTri.published = publishedUserTrimester;
				revenueTri.invoiceBilled = invoiceBilledUserTrimester;
				revenueTri.PSI = psiSumTrimester;
				revenueTri.prePSI = ((revenueTri.PSI / ((revenueTri.roleTarget != null && revenueTri.roleTarget != 0) ? revenueTri.roleTarget : 1))*100);
				revenueTri.responseIncentive = (getPayoutPercentage(startDate, endDate, revenueTri.prePSI));
				listOfResponse.add(revenueTri);
			}
			List<Response> anunalList = new List<Response>();
			Response res = new Response();
			res.roleTarget = userTarget;
			res.scheduledtoPrint = scheduledtoPrintUser;
			res.published = publishedUser;
			res.invoiceBilled = invoiceBilledUser;
			res.PSI = psiSum;
			res.prePSI = (res.PSI / ((res.roleTarget != null && res.roleTarget != 0) ? res.roleTarget : 1))*100;
			res.responseIncentive = getPayoutPercentage(fiscalYearStartDate, fiscalYearEndDate, res.prePSI);
			res.trimesterName = '(APR '+fiscalYearStartDate.year() +' - MAR ' + fiscalYearEndDate.year() +')';
			anunalList.add(res);
			response.userWise = anunalList;
			response.roleWise = listOfResponse;
			return response;

		} catch (Exception e) {
			throw new AuraHandledException(e.getMessage());
		}
	}

	private Static List<rsp_Role__c> getRole(String userId) {
		List<rsp_Role__c> listOfRole = [
			SELECT Id, rsp_Hierarchy_Type__c, Name, rsp_Geography__r.rsp_Type__c, rsp_Current_User__c, rsp_Vertical__r.Name, rsp_Horizontal__r.Name,
			Trimester_Incentive_Classification__c, rsp_Geography__r.rsp_Geo_Code__c
			FROM rsp_Role__c WHERE
			rsp_Current_User__c = :userId
		];
		return listOfRole;
	}

	private static Map<Id, Decimal> getRevenueForFixed(List<rsp_Role__c> roleList, Date startDate, Date endDate) {
		Map<Id, Decimal> roleToAchievedTarget = new Map<Id, Decimal>();
		List<Id> roleListIds = new List<Id>();
		for (rsp_Role__c role : roleList) {
			roleListIds.add(role.Id);
		}
		List<rsp_Achievement__c> resultList = [
			SELECT Id, rsp_Achievement_Value__c, rsp_Role__c
			FROM rsp_Achievement__c
			WHERE rsp_Role__c IN :roleListIds
			AND rsp_Achievement_Date__c >= :startDate
			AND rsp_Achievement_Date__c <= :endDate
			AND rsp_Credit_Split_Status__c = 'Assigned'
			AND Response_Revenue_Print__c = true
		];
	
		for (rsp_Achievement__c each : resultList) {
			if (!roleToAchievedTarget.containsKey(each.rsp_Role__c)) {
				roleToAchievedTarget.put(each.rsp_Role__c, 0);
			}
			Decimal total = roleToAchievedTarget.get(each.rsp_Role__c);
			total += each.rsp_Achievement_Value__c;
			roleToAchievedTarget.put(each.rsp_Role__c, total);
		}
	
		return roleToAchievedTarget;
	}
	
	private static Map<Id, Decimal> getMonthlyTarget(List<rsp_Role__c> listOfRole, String userId, Date startDate, Date endDate) {
		Map<Id, Decimal> roleToTarget = new Map<Id, Decimal>();
		List<Id> roleIds = new List<Id>();
		for (rsp_Role__c role : listOfRole) {
			roleIds.add(role.Id);
		}
		List<rsp_Target__c> listOfTarget = [
			SELECT Id, rsp_Target_Month__c, OwnerId, rsp_Role__c, rsp_Assigned_Target__c, rsp_Target_Type__c, rsp_Start_Date__c, rsp_End_Date__c, rsp_Is_Roll_Up_target__c
			FROM rsp_Target__c
			WHERE rsp_Start_Date__c >= :startDate
			AND rsp_End_Date__c <= :endDate
			AND rsp_Is_Roll_Up_target__c = false
			AND rsp_Target_Type__c = 'Revenue'
			AND rsp_Role__c IN :roleIds
		];
	
		for (rsp_Target__c each : listOfTarget) {
			if (!roleToTarget.containsKey(each.rsp_Role__c)) {
				roleToTarget.put(each.rsp_Role__c, 0);
			}
			if (each.OwnerId == userId) {
				Decimal targetValue = roleToTarget.get(each.rsp_Role__c);
				targetValue += each.rsp_Assigned_Target__c;
				roleToTarget.put(each.rsp_Role__c , targetValue);
			}
		}
		return roleToTarget;
	}

	private static Map<Id, Response> getRevenueForCommitted(List<rsp_Role__c> roles, Date startDate, Date endDate) {
		// Map to hold the response objects for each role ID
		Map<Id, Response> responseMap = new Map<Id, Response>();
		
		// Collect geography codes and other properties for each role
		Map<Id, String> geographyMap = new Map<Id, String>();
		Map<Id, Boolean> isSalesOrgMap = new Map<Id, Boolean>();
		Map<Id, Boolean> isVerticalMap = new Map<Id, Boolean>();
		Map<Id, String> verticalAndHorizontalMap = new Map<Id, String>();
		
		for (rsp_Role__c role : roles) {
			String geographyCode = role.rsp_Geography__c != null ? role.rsp_Geography__r.rsp_Geo_Code__c : '';
			geographyMap.put(role.Id, geographyCode);
			isSalesOrgMap.put(role.Id, role.rsp_Geography__c != null && role.rsp_Geography__r != null && role.rsp_Geography__r.rsp_Type__c == 'SALES ORG');
			isVerticalMap.put(role.Id, role.rsp_Hierarchy_Type__c != null && role.rsp_Hierarchy_Type__c == 'Vertical');
			verticalAndHorizontalMap.put(role.Id, role.rsp_Vertical__c != null && role.rsp_Vertical__r != null ? role.rsp_Vertical__r.Name : (role.rsp_Horizontal__r != null ? role.rsp_Horizontal__r.Name : ''));
	
			// Initialize the response object for each role
			Response resObj = new Response();
			resObj.roleName = role.Name; // Assuming you want to store the role name
			resObj.committedPipline = 0;
			resObj.scheduledtoPrint = 0;
			resObj.published = 0;
			responseMap.put(role.Id, resObj); // Map role ID to response object
		}
		
		// Build query using the set of all relevant geography codes and vertical/horizontal values
		String query = 'SELECT Id, TotalPrice, rsp_Status__c, Order.rsp_Geography__c, Order.rsp2_Sales_Office_Geo_Code__c, Order.rsp_Vertical__c, Order.rsp_Vertical__r.Name , rsp_Horizontals__c ' + 
					   'FROM OrderItem WHERE Publishing_Date__c >= :startDate AND Publishing_Date__c <= :endDate ' + 
					   'AND (rsp_Status__c = \'Scheduled to print\' OR rsp_Status__c = \'Published\') AND Product2.Response_Revenue_Print__c = true';
	
		// Execute query
		List<OrderItem> orderItems = Database.query(query);
	
		// Iterate over query results to accumulate revenue data by role
		for (OrderItem item : orderItems) {
			for (Id roleId : geographyMap.keySet()) {
				// Fetch role attributes from maps
				String roleGeoCode = geographyMap.get(roleId);
				Boolean isSalesOrg = isSalesOrgMap.get(roleId);
				Boolean isVertical = isVerticalMap.get(roleId);
				String verticalOrHorizontal = verticalAndHorizontalMap.get(roleId);
				
				// Check and match Order geography and vertical/horizontal fields with role attributes
				Boolean geoMatches = (isSalesOrg && item.Order != null && item.Order.rsp_Geography__c == roleGeoCode) || 
									 (!isSalesOrg && item.Order != null && item.Order.rsp2_Sales_Office_Geo_Code__c == roleGeoCode);
				Boolean vertMatches = (isVertical && item.Order != null && item.Order.rsp_Vertical__c != null &&  item.Order.rsp_Vertical__r.Name == verticalAndHorizontalMap.get(roleId)) || 
									  (!isVertical && item.rsp_Horizontals__c != null && item.rsp_Horizontals__c.contains(verticalOrHorizontal));
	
				// Only process item if geography and vertical/horizontal match
				if (geoMatches && vertMatches) {
					Response res = responseMap.get(roleId);
					
					// Update response object based on the status of the OrderItem
					if (item.rsp_Status__c == 'Scheduled to print') {
						res.scheduledtoPrint += item.TotalPrice != null ? item.TotalPrice : 0;
					} 
					if (item.rsp_Status__c == 'Published') {
						res.published += item.TotalPrice != null ? item.TotalPrice : 0;
					}
					res.committedPipline = res.scheduledtoPrint + res.published;
				}
			}
		}
		
		// Return the map of responses by role ID
		return responseMap;
	}
	
	
	/* -----------------------------------------------------------------------------*/
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

	public static List<Trimester> getCurrentFiscalYearTrimesters() {
		List<Trimester> trimesters = new List<Trimester>();

		// Determine the current fiscal year based on today's date
		Integer currentYear = Date.today().year();
		Integer fiscalYearStartYear = Date.today().month() >= 4 ? currentYear : currentYear - 1;
		String fiscalYearShort = String.valueOf(fiscalYearStartYear).substring(2, 4);
    	String nextYearShort = String.valueOf(fiscalYearStartYear + 1).substring(2, 4);
		// Trimester 1: April to July
		Date trimester1Start = Date.newInstance(fiscalYearStartYear, 4, 1); // April 1st
		Date trimester1End = Date.newInstance(fiscalYearStartYear, 7, 31); // July 31st
		String t1 = 'T1 (APR ' + fiscalYearShort + ' - JUL ' + fiscalYearShort +')';
		trimesters.add(new Trimester(t1, trimester1Start, trimester1End));

		// Trimester 2: August to November
		Date trimester2Start = Date.newInstance(fiscalYearStartYear, 8, 1); // August 1st
		Date trimester2End = Date.newInstance(fiscalYearStartYear, 11, 30); // November 30th
		String t2 = 'T2 (AUG ' + fiscalYearShort + ' - NOV ' + fiscalYearShort +')';
		trimesters.add(new Trimester(t2, trimester2Start, trimester2End));

		// Trimester 3: December to March (of the next year)
		Date trimester3Start = Date.newInstance(fiscalYearStartYear, 12, 1); // December 1st
		Date trimester3End = Date.newInstance(fiscalYearStartYear + 1, 3, 31); // March 31st of the next year
		String t3 = 'T3 (DEC ' + fiscalYearShort + ' - MAR ' + nextYearShort +')';
		trimesters.add(new Trimester(t3, trimester3Start, trimester3End));

		return trimesters;
	}
	
	@AuraEnabled
	public static TrimesterWrapper getPayout(String trimester){
		try {
			String userId = UserInfo.getUserId();
			User currentUser = [SELECT Id, Sap_User_Id__c
				FROM User WHERE
				Id =: userId
				];
			TrimesterWrapper trimesterResponce = (TrimesterWrapper) JSON.deserialize(trimester, TrimesterWrapper.class);
			Map<Id, rsp_Role__c> roleMap = new Map<Id, rsp_Role__c>();
			Map<Id, List<rsp_Target__c>> roleToListOfTargetMap = new Map<Id, List<rsp_Target__c>>();
			Map<Id, Decimal> roleToYearlyTargetMap = new Map<Id, Decimal>();
			Decimal percentage = 0;
			Decimal forOneTrimester = 0;
			EmployeeDetailsWrapper employeeDetails = getIncentive(currentUser.Sap_User_Id__c ?? '');
			Integer year = Date.today().year();
        	Integer month = Date.today().month();
        	Integer day = Date.today().day();
        	Date startDate;
        	Date endDate;
        	if (month >= 4) {
        	    startDate = Date.newInstance(year, 4, 1);
        	    endDate = Date.newInstance(year + 1, 3, 31);
        	} else {
        	    startDate = Date.newInstance(year - 1, 4, 1);
        	    endDate = Date.newInstance(year, 3, 31);
        	}
			
			List<rsp_Role__c> listOfRole = getRole(userId);
			for(rsp_Role__c role :listOfRole) {
				roleMap.put(role.id, role);
			}
			for(rsp_Target__c target :[
				SELECT Id, rsp_Target_Month__c, OwnerId, rsp_Role__c, rsp_Assigned_Target__c, rsp_Target_Type__c, rsp_Start_Date__c, rsp_End_Date__c, rsp_Is_Roll_Up_target__c
				FROM rsp_Target__c
				WHERE rsp_Start_Date__c >= :startDate
				AND rsp_End_Date__c <= :endDate
				AND rsp_Is_Roll_Up_target__c = false
				AND rsp_Target_Type__c = 'Revenue'
				AND rsp_Role__c IN :roleMap.keySet()
			]) {
				if(!roleToListOfTargetMap.containsKey(target.rsp_Role__c)) {
					roleToListOfTargetMap.put(target.rsp_Role__c, new List<rsp_Target__c>());
				}
				roleToListOfTargetMap.get(target.rsp_Role__c).add(target);

				if (!roleToYearlyTargetMap.containsKey(target.rsp_Role__c)) {
					roleToYearlyTargetMap.put(target.rsp_Role__c, 0);
				}
				roleToYearlyTargetMap.put(target.rsp_Role__c, roleToYearlyTargetMap.get(target.rsp_Role__c) + target.rsp_Assigned_Target__c);
			}
			Id highestTargetRoleId = null;
        	Decimal highestTarget = 0;

        	for (Id roleId : roleToYearlyTargetMap.keySet()) {
        	    Decimal yearlyTarget = roleToYearlyTargetMap.get(roleId);
        	    if (yearlyTarget > highestTarget) {
        	        highestTarget = yearlyTarget;
        	        highestTargetRoleId = roleId;
        	    }
        	}
			if (roleMap.get(highestTargetRoleId).Trimester_Incentive_Classification__c == System.Label.Trimester_Incentive_Classification_Sales_Team_Member) {
				percentage = Decimal.valueOf(System.Label.Sales_Team_member_Percentage);
			}
			if (roleMap.get(highestTargetRoleId).Trimester_Incentive_Classification__c == System.Label.Trimester_Incentive_Classification_Team_Leaders) {
				percentage = Decimal.valueOf(System.Label.Team_Leaders_Percentage);
			}
			// System.debug('percentage '+percentage);
			Decimal totalpayout = Decimal.valueOf(employeeDetails.BETRG_TVP) ?? 0;
			// System.debug('totalPayout '+ totalPayout);
			Decimal perTrimester = (( totalpayout ?? 0) * (percentage ?? 0))/100;
			TrimesterWrapper respones = new TrimesterWrapper();
			respones.T1 = 'T1';
			respones.t1value = 	(Decimal.valueOf(employeeDetails.BETRG_TVP_PAID_A) != null && Decimal.valueOf(employeeDetails.BETRG_TVP_PAID_A) != 0) ? Decimal.valueOf(employeeDetails.BETRG_TVP_PAID_A) :(((trimesterResponce.t1value ?? 0) * perTrimester) ?? 0)/100;
			respones.T2 = 'T2';
			respones.t2value = 	(Decimal.valueOf(employeeDetails.BETRG_TVP_PAID_B) != null && Decimal.valueOf(employeeDetails.BETRG_TVP_PAID_B) != 0) ? Decimal.valueOf(employeeDetails.BETRG_TVP_PAID_B) :(((trimesterResponce.t2value ?? 0) * perTrimester) ?? 0)/100;
			respones.T3 = 'T3';
			respones.t3value = 	(Decimal.valueOf(employeeDetails.BETRG_TVP_PAID_C) != null && Decimal.valueOf(employeeDetails.BETRG_TVP_PAID_C) != 0) ? Decimal.valueOf(employeeDetails.BETRG_TVP_PAID_C) :(((trimesterResponce.t3value ?? 0) * perTrimester) ?? 0)/100;
			respones.t1fullPayout = (Decimal.valueOf(employeeDetails.BETRG_TVP_PAID_A) != null && Decimal.valueOf(employeeDetails.BETRG_TVP_PAID_A) != 0) ? 0: perTrimester;
			respones.t2fullPayout = (Decimal.valueOf(employeeDetails.BETRG_TVP_PAID_B) != null && Decimal.valueOf(employeeDetails.BETRG_TVP_PAID_B) != 0) ? 0: perTrimester;
			respones.t3fullPayout = (Decimal.valueOf(employeeDetails.BETRG_TVP_PAID_C) != null && Decimal.valueOf(employeeDetails.BETRG_TVP_PAID_C) != 0) ? 0: perTrimester;
			respones.t1extraPayout = (Decimal.valueOf(employeeDetails.BETRG_TVP_PAID_A) != null && Decimal.valueOf(employeeDetails.BETRG_TVP_PAID_A) != 0) ? 0:((perTrimester ?? 0) * 120 )/100;
			respones.t2extraPayout = (Decimal.valueOf(employeeDetails.BETRG_TVP_PAID_B) != null && Decimal.valueOf(employeeDetails.BETRG_TVP_PAID_B) != 0) ? 0:((perTrimester ?? 0) * 120 )/100;
			respones.t3extraPayout = (Decimal.valueOf(employeeDetails.BETRG_TVP_PAID_C) != null && Decimal.valueOf(employeeDetails.BETRG_TVP_PAID_C) != 0) ? 0:((perTrimester ?? 0) * 120 )/100;
        	// System.debug('Role with Highest Target: ' + roleMap.get(highestTargetRoleId).Name + ' with target: ' + highestTarget);
			// System.debug('respones '+respones);
			return respones;
			
			} catch (Exception e) {
				throw new AuraHandledException(e.getMessage());
			}
	}

	public static EmployeeDetailsWrapper getIncentive(String empId) {
		HttpRequest req = new HttpRequest();
		req.setMethod('GET');
		String endPoint = System.Label.TVP_End_Point + empId;
		req.setEndpoint(endPoint); 
		HttpResponse resp = new Http().send(req);
	
		if (resp.getStatusCode() == 200) {
			System.debug('Response Status Code: ' + resp.getStatusCode());
			System.debug('Response Body: ' + resp.getBody());
	
			try {
				// Deserialize the response body directly
				EmployeeDetailsWrapper employeeDetails = 
					(EmployeeDetailsWrapper) JSON.deserialize(resp.getBody(), EmployeeDetailsWrapper.class);
				System.debug('Parsed Details: ' + employeeDetails);
				return employeeDetails;
			} catch (Exception e) {
				System.debug('Error parsing response: ' + e.getMessage());
				return null;
			}
		} else {
			System.debug('Error: ' + resp.getStatusCode() + ' - ' + resp.getStatus());
			return null;
		}
	}
	
	public class EmployeeDetailsWrapper {
		public String PERNR { get; set; }
		public String SNAME { get; set; }
		public String EMAIL { get; set; }
		public String BETRG_TVP { get; set; }
		public String BETRG_TVP_PAID_A { get; set; }
		public String BETRG_TVP_PAID_B { get; set; }
		public String BETRG_TVP_PAID_C { get; set; }
		public String BETRG_TVP_PAID_D { get; set; }
		public String BETRG_TVP_BAL { get; set; }
	}
		
	
	public class TrimesterWrapper {
		@AuraEnabled public String T1;
		@AuraEnabled public Decimal t1value;
		@AuraEnabled public String T2;
		@AuraEnabled public Decimal t2value;
		@AuraEnabled public String T3;
		@AuraEnabled public Decimal t3value;
		@AuraEnabled public Decimal t1fullPayout;
		@AuraEnabled public Decimal t2fullPayout;
		@AuraEnabled public Decimal t3fullPayout;
		@AuraEnabled public Decimal t1extraPayout;
		@AuraEnabled public Decimal t2extraPayout;
		@AuraEnabled public Decimal t3extraPayout;
	}
	public class Trimester {
		public String name;
		public Date startDate; 
		public Date endDate;

		// Constructor
		public Trimester(String name, Date startDate, Date endDate) {
			this.name = name;
			this.startDate = startDate;
			this.endDate = endDate;
		}
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
		@AuraEnabled public Decimal PSI;
		@AuraEnabled public Decimal prePSI;
		@AuraEnabled public String trimesterName;
		@AuraEnabled public Decimal responseIncentive;
	}
}
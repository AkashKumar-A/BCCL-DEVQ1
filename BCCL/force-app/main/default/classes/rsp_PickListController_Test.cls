@isTest
public class rsp_PickListController_Test
{
    public static testmethod void rsp_PickListControllerMethod()
    {      
        List<String> pickListValuesList = rsp_PickListController.getPickListValuesIntoList('Account', 'AccountSource');
        System.assertEquals(true, pickListValuesList.size() >0);
    }
}
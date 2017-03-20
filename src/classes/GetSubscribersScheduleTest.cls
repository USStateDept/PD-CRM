@isTest
private class GetSubscribersScheduleTest {
  
  static testmethod void batchclass()
    {  
        
        test.startTest();
        SchedulableContext sc;
        GetSubscribersSchedule objg = new GetSubscribersSchedule();
        objg.execute(sc);
        test.stopTest();
    }
}
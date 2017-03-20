@isTest
private class TriggerHelperTest {
  
  static testmethod void triggHelper()
    {
        Test.startTest();
        TriggerHelper objhelper = new TriggerHelper();
        objhelper.processBeforeInsert();
        objhelper.processBeforeUpdate();
        objhelper.processBeforeDelete();
        objhelper.processBeforeUndelete();
        objhelper.processAfterInsert();
        objhelper.processAfterUpdate();
        objhelper.processAfterUpdate();
        objhelper.processAfterDelete();
        objhelper.processAfterUndelete();
        Test.stopTest();
    }
}
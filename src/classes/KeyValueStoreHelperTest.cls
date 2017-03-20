@isTest
private class KeyValueStoreHelperTest {
  
  static testmethod void triggHelper()
    {
        Test.startTest();
        KeyValueStore__c objk = new KeyValueStore__c();
        objk.name='test';
        objk.BooleanValue__c=true;
        objk.DateValue__c=System.today();
        objk.IntegerValue__c=2.0;
        objk.TextValue__c='test';
        insert objk;
        
        //KeyValueStoreHelper objkv = new KeyValueStoreHelper();
        KeyValueStoreHelper.getTextValue('test');
        KeyValueStoreHelper.getBooleanValue('test');
        KeyValueStoreHelper.getIntegerValue('test');
        KeyValueStoreHelper.getDecimalValue('test');
        KeyValueStoreHelper.getDateValue('test');
        KeyValueStoreHelper.getDateTimeValue('test');
        Test.stopTest();
    }
}
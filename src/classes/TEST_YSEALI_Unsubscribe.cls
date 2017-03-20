@isTest
public class TEST_YSEALI_Unsubscribe {
    static testMethod void testObjects()
    {
        Test.startTest();
        YSEALI_BatchUnSubscribe testObj5 = new YSEALI_BatchUnSubscribe();
        YSEALI_Email testObj2 = new YSEALI_Email();
        Test.stopTest();
    }
    
    static testMethod void testBatchUnsubscribe()
    {
        Global_Variable__c newSetting1 = new Global_Variable__c();
        newSetting1.Name = 'MailChimp API Key';
        newSetting1.Value__c = '76f4f0aafffc3f9af72b74d39f09461d-us8';
        insert newSetting1;
        
        Global_Variable__c newSetting2 = new Global_Variable__c();
        newSetting2.Name = 'MailChimp List Key';
        newSetting2.Value__c = 'd36a8b7fac ';
        insert newSetting2;

        Global_Variable__c newSetting4 = new Global_Variable__c();
        newSetting4.Name = 'MailChimp UnSubscribe URL';
        newSetting4.Value__c = 'https://us8.api.mailchimp.com/2.0/lists/batch-unsubscribe.json';
        insert newSetting4;
        
        YSEALI_BatchUnsubscribe batchUnsub = new YSEALI_BatchUnsubscribe();
        YSEALI_Email userEmail = new YSEALI_Email();
        userEmail.email = 'pathaninp@aol.com';
        userEmail.euid = '3870987249';
        userEmail.leid = 'c7802fdb56';
        batchUnsub.batch.add(userEmail);
        
		userEmail = new YSEALI_Email();
        userEmail.email = 'shameer83@gmail.com';
        userEmail.euid = '1290806098';
        userEmail.leid = 'c7802fdb56';
		batchUnsub.batch.add(userEmail);      
        YSEALI_Unsubscribe.batchUnsubscribe = batchUnsub;
        
        Test.startTest();
        Test.setMock( HttpCalloutMock.class, new TEST_YSEALICalloutMockUnsubscribe() );
        Boolean isSuccess = YSEALI_Unsubscribe.batchUnsubscribe();
        System.assertEquals(isSuccess, true);
        Test.stopTest();
    }
    
    static testMethod void testBatchUnsubscribe_NoContacts()
    {
        Global_Variable__c newSetting1 = new Global_Variable__c();
        newSetting1.Name = 'MailChimp API Key';
        newSetting1.Value__c = '76f4f0aafffc3f9af72b74d39f09461d-us8';
        insert newSetting1;
        
        Global_Variable__c newSetting2 = new Global_Variable__c();
        newSetting2.Name = 'MailChimp List Key';
        newSetting2.Value__c = 'd36a8b7fac ';
        insert newSetting2;

        Global_Variable__c newSetting4 = new Global_Variable__c();
        newSetting4.Name = 'MailChimp UnSubscribe URL';
        newSetting4.Value__c = 'https://us8.api.mailchimp.com/2.0/lists/batch-unsubscribe.json';
        insert newSetting4;
        
        YSEALI_BatchUnsubscribe batchUnsub = new YSEALI_BatchUnsubscribe();
        Test.startTest();
        Test.setMock( HttpCalloutMock.class, new TEST_YSEALICalloutMockUnsubscribe() );
        Boolean isSuccess = YSEALI_Unsubscribe.batchUnsubscribe();
        System.assertEquals(isSuccess, false);
        Test.stopTest();
    }
    
	static testMethod void testUpdateUnsubscriber()
    {
        Global_Variable__c newSetting1 = new Global_Variable__c();
        newSetting1.Name = 'MailChimp API Key';
        newSetting1.Value__c = 'df7f52a5cb49133c45630d3a6a7f74ec-us3';
        insert newSetting1;
        
        Global_Variable__c newSetting2 = new Global_Variable__c();
        newSetting2.Name = 'MailChimp List Key';
        newSetting2.Value__c = 'd2457bcfca';
        insert newSetting2;
        
        Global_Variable__c newSetting3 = new Global_Variable__c();
        newSetting3.Name = 'MailChimp SubUsers URL';
        newSetting3.Value__c = 'https://us8.api.mailchimp.com/2.0/lists/members.json';
        insert newSetting3;
        
        Global_Variable__c newSetting4 = new Global_Variable__c();
        newSetting4.Name = 'MailChimp UnSubscribe URL';
        newSetting4.Value__c = 'https://us8.api.mailchimp.com/2.0/lists/batch-unsubscribe.json';
        insert newSetting4;
        
        Test.startTest();
        Test.setMock( HttpCalloutMock.class, new TEST_YSEALICalloutMock() );
        YSEALI_Unsubscribe.updateUnsubscriber();
        Test.stopTest();
    }
 
}
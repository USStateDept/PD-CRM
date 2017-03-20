@isTest
private class GetSubscriberDetailsBatchTest {

    static testmethod void test() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

	//Select id, wbsendit__Email__c, wbsendit__List_Id__c, 
    //                                     wbsendit__State__c, wbsendit__Lead__c from wbsendit__Subscription__c where wbsendit__State__c = 'Active' and wbsendit__Lead__c != null
       Lead objLead = new Lead();
       objLead.Email = 'lead_email@mail.com';
       objLead.Lastname='leadtest';
        objLead.Company='testcomp';
        objLead.Status='Open';
        objLead.CountryCode='US';
        objLead.StateCode = 'NC';
       insert objlead;
        
        wbsendit__Subscriber_List__c subsList1 = new wbsendit__Subscriber_List__c();
        subsList1.wbsendit__List_Id__c = '594b130af56350657e1ca106fcccedab';
        subsList1.wbsendit__List_Name__c = 'YSEALI Welcome/Lead Confirmation List - English';
        insert subsList1;
        
       wbsendit__Subscription__c objw = new wbsendit__Subscription__c();
       objw.wbsendit__Email__c=objlead.Email;
       objw.wbsendit__List_Id__c=subsList1.wbsendit__List_Id__c;
       objw.wbsendit__Subscriber_List__c = subsList1.Id;
       objw.wbsendit__Lead__c=objlead.id;
	   objw.wbsendit__State__c = 'Active';
       insert objw;
        
       Test.startTest();
       GetSubscriberDetailsBatch c = new GetSubscriberDetailsBatch();
       Database.executeBatch(c);
       Test.stopTest();

    }
}
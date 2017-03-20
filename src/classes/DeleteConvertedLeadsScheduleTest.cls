@isTest
public class DeleteConvertedLeadsScheduleTest {
    @testsetup static void setup() {
        Lead openLead = new Lead();
        openLead.FirstName = 'Yseali_Indonesia';
        openLead.LastName = 'Test';
        openLead.Email = 'yseali_indo@mail.com';
        openLead.LeadSource = 'YSEALI';
        openLead.Country__c = 'Indonesia';
        openLead.Language__c = 'English';
        openLead.Interests__c = 'Community Development; Education/Libraries';
        openLead.Status = 'Open';
        insert openLead;        
        
        Lead qualifiedLead = new Lead();
        qualifiedLead.FirstName = 'Yseali_Cambodian';
        qualifiedLead.LastName = 'Test';
        qualifiedLead.Email = 'yseali_cambodiantest@mail.com';
        qualifiedLead.LeadSource = 'YSEALI';
        qualifiedLead.Country__c = 'Cambodia';
        qualifiedLead.Language__c = 'English';
        qualifiedLead.Interests__c = 'Local Government; Environment/Climate';
        qualifiedLead.Status = 'Qualified';
        insert qualifiedLead;
        
        Account a = new Account();
        a.Name = 'YSEALI';
        insert a;
        
        Contact activeContact = new Contact();
        activeContact.Email = qualifiedLead.Email;
        activeContact.FirstName = qualifiedLead.FirstName;
        activeContact.LastName = qualifiedLead.LastName;
        activeContact.LeadSource = qualifiedLead.LeadSource;
        activeContact.Country__c = qualifiedLead.Country__c;
        activeContact.Spoken_Languages__c = qualifiedLead.Language__c;
        activeContact.Interests__c = qualifiedLead.Interests__c;
        activeContact.AccountId = a.Id;
        insert activeContact;
        
        wbsendit__Subscriber_List__c subsList1 = new wbsendit__Subscriber_List__c();
        subsList1.wbsendit__List_Id__c = '594b130af56350657e1ca106fcccedab';
        subsList1.wbsendit__List_Name__c = 'YSEALI Welcome/Lead Confirmation List - English';
        insert subsList1;
        
        wbsendit__Subscriber_List__c subsList2 = new wbsendit__Subscriber_List__c();
        subsList2.wbsendit__List_Id__c = '357ee017de7d92e1941494178c7d9baf';
        subsList2.wbsendit__List_Name__c = 'YSEALI All Contacts - English';
        insert subsList2;
        
        wbsendit__Subscription__c subscription1 = new wbsendit__Subscription__c();
        subscription1.wbsendit__Subscriber_List__c = subsList1.Id;
        subscription1.wbsendit__List_Id__c = subsList1.wbsendit__List_Id__c;
        subscription1.wbsendit__Email__c = qualifiedLead.Email;
        subscription1.wbsendit__Lead__c = qualifiedLead.Id;
        subscription1.wbsendit__State__c = 'Active';
        insert subscription1;
        
        wbsendit__Subscription__c subscription2 = new wbsendit__Subscription__c();
        subscription2.wbsendit__Subscriber_List__c = subsList2.Id;
        subscription2.wbsendit__List_Id__c = subsList2.wbsendit__List_Id__c;
        subscription2.wbsendit__Email__c = activeContact.Email;
        subscription2.wbsendit__Lead__c = qualifiedLead.Id;
        subscription2.wbsendit__Contact__c = activeContact.Id;
        subscription2.wbsendit__State__c = 'Active';
        insert subscription2;
        
        wbsendit__Subscription__c subscription3 = new wbsendit__Subscription__c();
        subscription3.wbsendit__Subscriber_List__c = subsList1.Id;
        subscription3.wbsendit__List_Id__c = subsList1.wbsendit__List_Id__c;
        subscription3.wbsendit__Email__c = openLead.Email;
        subscription3.wbsendit__Lead__c = openLead.Id;
        subscription3.wbsendit__State__c = 'Active';
        insert subscription3;
    }
    
    static testmethod void testDeleteConvertedLeadsSchedule() {
        Test.setMock(HttpCalloutMock.class, new DelSub_MockHttpResponse());
        
        Test.startTest();        
        SchedulableContext sc;
        DeleteConvertedLeadsSchedule schedule = new DeleteConvertedLeadsSchedule();
        schedule.execute(sc);
        Test.stopTest();
		
        List<Lead> qualifiedLeads = [SELECT Id, Email FROM Lead WHERE Email = 'yseali_cambodiantest@mail.com'];
        System.assertEquals(0, qualifiedLeads.size());
        
        List<wbsendit__Subscription__c> subsContactList = (List<wbsendit__Subscription__c>)
                                                        [Select id, wbsendit__Email__c, wbsendit__List_Id__c, 
                                                         wbsendit__State__c, wbsendit__Lead__c 
                                                         from wbsendit__Subscription__c 
                                                         where wbsendit__List_Id__c = '357ee017de7d92e1941494178c7d9baf'
                                                         and wbsendit__Email__c = 'yseali_cambodiantest@mail.com'
                                                         and wbsendit__State__c = 'Active'];
        System.assertEquals(1, subsContactList.size());
        
    }
    
    static testmethod void testDeleteCMLeads() {
        Test.setMock(HttpCalloutMock.class, new DelSub_MockHttpResponse());
        List<wbsendit__Subscription__c> subsLeadList = (List<wbsendit__Subscription__c>)
                                                        [Select id, wbsendit__Email__c, wbsendit__List_Id__c, 
                                                         wbsendit__State__c, wbsendit__Lead__c 
                                                         from wbsendit__Subscription__c 
                                                         where wbsendit__List_Id__c = '594b130af56350657e1ca106fcccedab'
                                                         and wbsendit__Email__c = 'yseali_cambodiantest@mail.com'
                                                         and wbsendit__Subscriber_List__r.wbsendit__List_Name__c LIKE '%Lead%'];
                           
        String listId = subsLeadList.get(0).wbsendit__List_Id__c;
        String email = subsLeadList.get(0).wbsendit__Email__c;
        
        Test.startTest();
        HttpResponse response = DeleteConvertedLeadsSchedule.deleteCMLeads(listId, email);
        Test.stopTest();
        System.assertEquals(response.getStatusCode(), 200);
    }
}
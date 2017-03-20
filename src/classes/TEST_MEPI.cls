@isTest
public class TEST_MEPI
{
    static testMethod void testObjects()
    {
        Test.startTest();
        MEPI_BatchSubscribe testObj1 = new MEPI_BatchSubscribe();
        MEPI_Email testObj2 = new MEPI_Email();
        MEPI_Subscriber testObj3 = new MEPI_Subscriber();
        MEPI_UserData testObj4 = new MEPI_UserData();
    }
    
    
    static testMethod void testInsertContacts()
    {
        Account mepi = new Account();
        mepi.name = 'MEPI';
        insert mepi;
        
        List<Contact> myList = new List<Contact>();

        Contact a = new Contact();
        a.email = 'parki2@state.gov';
        a.firstName = 'ij';
        a.lastName = 'park';
        a.city__c = 'alexandria';
        a.Spoken_Languages__c = 'English';
        a.Initial_Creation_Type__c = 'Video';
        myList.add( a );
        
        Contact a1 = new Contact();
        a1.email = 'parki2@state.gov';
        a1.firstName = 'ij';
        a1.lastName = 'park';
        a1.city__c = 'alexandria';
        a1.Spoken_Languages__c = 'English';
        a1.AccountId = mepi.id;
        a1.Initial_Creation_Type__c = 'Video';
        insert a1;
        
        Contact b = new Contact();
        b.email = 'parki3@state.gov';
        b.firstName = 'ij';
        b.lastName = 'park';
        b.city__c = 'alexandria';
        b.Spoken_Languages__c = 'English';
        b.Initial_Creation_Type__c = 'Video';
        myList.add( b );
        
        Contact c = new Contact();
        c.email = 'parki4@state.gov';
        c.firstName = 'ij';
        c.lastName = 'park';
        c.city__c = 'alexandria';
        c.Spoken_Languages__c = 'English';
        c.Initial_Creation_Type__c = 'Image';
        myList.add( c );
        
        Contact d = new Contact();
        d.email = 'ipark@sevatec.com';
        d.firstName = 'ij';
        d.lastName = 'park';
        d.city__c = 'alexandria';
        d.Spoken_Languages__c = 'English';
        d.Initial_Creation_Type__c = 'Comments';
        myList.add( d );
        
        Test.startTest();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        req.requestURI = 'https://' + System.URL.getSalesforceBaseURL().getHost() + '/services/apexrest/MEPIContact/';
        
        String jsons = '';
        
        for (Contact cont : myList)
        {
            if (jsons.length() == 0)
            {
                jsons += '{"City__c": "' + cont.City__c + '",';
                jsons += '"Email": "' + cont.Email + '",';
                jsons += '"Initial_Creation_Type__c": "' + cont.Initial_Creation_Type__c + '",';
                jsons += '"FirstName": "' + cont.FirstName + '",';
                jsons += '"LastName": "' + cont.LastName + '",';
                jsons += '"Spoken_Languages__c": "' + cont.Spoken_Languages__c + '"}';
            }
            else
            {
                jsons += ',{"City__c": "' + cont.City__c + '",';
                jsons += '"Email": "' + cont.Email + '",';
                jsons += '"Initial_Creation_Type__c": "' + cont.Initial_Creation_Type__c + '",';
                jsons += '"FirstName": "' + cont.FirstName + '",';
                jsons += '"LastName": "' + cont.LastName + '",';
                jsons += '"Spoken_Languages__c": "' + cont.Spoken_Languages__c + '"}';
            }
            
        }
        
        jsons = '{"contacts": [' + jsons + ']}';
        
        System.debug( jsons );
        req.requestBody = Blob.valueof( JSON.serialize( myList ));
        
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;
        MEPI_WebguiToSF.insertContacts( myList );
    }
    
    
    static testMethod void testGetTotalSubscribers()
    {
        Global_Variable__c newSetting = new Global_Variable__c();
        newSetting.Name = 'MailChimp getList URL';
        newSetting.Value__c = 'https://us3.api.mailchimp.com/2.0/lists/list.json';
        insert newSetting;
        
        Global_Variable__c newSetting2 = new Global_Variable__c();
        newSetting2.Name = 'MailChimp API Key';
        newSetting2.Value__c = 'df7f52a5cb49133c45630d3a6a7f74ec-us3';
        insert newSetting2;
        
        Test.startTest();
        Test.setMock( HttpCalloutMock.class, new TEST_MEPICalloutMock() );
        Integer total = MEPI_Controller.getTotalSubscribers();
        System.assertEquals( 4, total );
        Test.stopTest();
    }
    
    
    static testMethod void testSubscribeMEPIUsers()
    {
        Account mepi = new Account();
        mepi.name = 'MEPI';
        insert mepi;
        
        Contact a = new Contact();
        a.email = 'parki1@state.gov';
        a.firstName = 'ij';
        a.lastName = 'park';
        a.city__c = 'alexandria';
        a.Spoken_Languages__c = 'English';
        a.Initial_Creation_Type__c = 'Video';
        insert a;
        
        Contact a1 = new Contact();
        a1.email = 'parki2@state.gov';
        a1.firstName = 'ij';
        a1.lastName = 'park';
        a1.city__c = 'alexandria';
        a1.Spoken_Languages__c = 'English';
        a1.AccountId = mepi.id;
        a1.Initial_Creation_Type__c = 'Video';
        insert a1;
        
        Global_Variable__c newSetting = new Global_Variable__c();
        newSetting.Name = 'MailChimp getList URL';
        newSetting.Value__c = 'https://us3.api.mailchimp.com/2.0/lists/list.json';
        insert newSetting;
        
        Global_Variable__c newSetting2 = new Global_Variable__c();
        newSetting2.Name = 'MailChimp API Key';
        newSetting2.Value__c = 'df7f52a5cb49133c45630d3a6a7f74ec-us3';
        insert newSetting2;
        
        Global_Variable__c newSetting3 = new Global_Variable__c();
        newSetting3.Name = 'MailChimp Subscribe URL';
        newSetting3.Value__c = 'https://us3.api.mailchimp.com/2.0/lists/batch-subscribe.json';
        insert newSetting3;
        
        Global_Variable__c newSetting5 = new Global_Variable__c();
        newSetting5.Name = 'Mailchimp limit';
        newSetting5.Value__c = '50000';
        insert newSetting5;
        
        Global_Variable__c newSetting4 = new Global_Variable__c();
        newSetting4.Name = 'Mailchimp Threshold';
        newSetting4.Value__c = '3000';
        insert newSetting4;
        
        Global_Variable__c newSetting6 = new Global_Variable__c();
        newSetting6.Name = 'MailChimp List Key';
        newSetting6.Value__c = 'd2457bcfca';
        insert newSetting6;
        
        
        Test.startTest();
        Test.setMock( HttpCalloutMock.class, new TEST_MEPICalloutMock() );
        MEPI_Controller.subscribeMEPIUsers();
        Test.stopTest();
    }
}
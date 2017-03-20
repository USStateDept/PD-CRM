@isTest
public class TEST_YSEALI
{
    
    static testMethod void testObjects()
    {
        Test.startTest();
        YSEALI_BatchSubscribe testObj1 = new YSEALI_BatchSubscribe();
        YSEALI_Email testObj2 = new YSEALI_Email();
        YSEALI_Subscriber testObj3 = new YSEALI_Subscriber();
        YSEALI_UserData testObj4 = new YSEALI_UserData();
        //YSEALI_BatchUnSubscribe testObj5 = new YSEALI_BatchUnSubscribe();
        Test.stopTest();
    }
        
    static testMethod void testInsertContacts()
    {
        Test.startTest();
        
        Account yseali = new Account();
        yseali.name = 'YSEALI';
        insert yseali;
        
        List<Contact> myList = new List<Contact>();

        Contact a = new Contact();
        a.email = 'ngamocha@gmail.com';
        a.firstName = 'apex';
        a.lastName = 'test';
        a.city__c = 'testsville';
        a.Spoken_Languages__c = 'English';
        a.Initial_Creation_Type__c = 'Video';
        myList.add( a );
        
        Contact a1 = new Contact();
        a1.email = 'c@gmail.com';
        a1.firstName = 'apex';
        a1.lastName = 'test';
        a1.city__c = 'testsville';
        a1.Spoken_Languages__c = 'English';
        a1.AccountId = yseali.id;
        a1.Initial_Creation_Type__c = 'Video';
        myList.add( a1 );
        /*
        Contact b = new Contact();
        b.email = 'c@gmail.com';
        b.firstName = 'apex';
        b.lastName = 'test';
        b.city__c = 'testsville';
        b.Spoken_Languages__c = 'English';
        b.Initial_Creation_Type__c = 'Video';
        myList.add( b );
        
        Contact c = new Contact();
        c.email = 'test3@yseali.com';
        c.firstName = 'apex';
        c.lastName = 'test';
        c.city__c = 'testsville';
        c.Spoken_Languages__c = 'English';
        c.Initial_Creation_Type__c = 'Image';
        myList.add( c );
        
        Contact d = new Contact();
        d.email = 'test4@yseali.com';
        d.firstName = 'apex';
        d.lastName = 'test';
        d.city__c = 'testsville';
        d.Spoken_Languages__c = 'English';
        d.Initial_Creation_Type__c = 'Comments';
        myList.add( d );
        */

        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        req.requestURI = 'https://' + System.URL.getSalesforceBaseURL().getHost() + '/services/apexrest/YSEALIContact/';
        
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
        YSEALI_WebguiToSF.insertContacts( myList );
        Test.stopTest();
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
        Test.setMock( HttpCalloutMock.class, new TEST_YSEALICalloutMock() );
        Integer total = YSEALI_Controller.getTotalSubscribers();
        System.assertEquals( 4, total );
        Test.stopTest();
    }
 
    static testMethod void testBatchSubscribe()
    {
                
        Global_Variable__c newSetting1 = new Global_Variable__c();
        newSetting1.Name = 'MailChimp API Key';
        newSetting1.Value__c = '76f4f0aafffc3f9af72b74d39f09461d-us8';
        insert newSetting1;
        
        Global_Variable__c newSetting2 = new Global_Variable__c();
        newSetting2.Name = 'MailChimp List Key';
        newSetting2.Value__c = 'd2457bcfca';
        insert newSetting2;
        
        Global_Variable__c newSetting3 = new Global_Variable__c();
        newSetting3.Name = 'MailChimp Subscribe URL';
        newSetting3.Value__c = 'https://us8.api.mailchimp.com/2.0/lists/batch-subscribe.json';
        insert newSetting3;
        
        Global_Variable__c newSetting4 = new Global_Variable__c();
        newSetting4.Name = 'Session Timedout';
        newSetting4.Value__c = '12000';
        insert newSetting4;
        
        Global_Variable__c newSetting5 = new Global_Variable__c();
        newSetting5.Name = 'Max Query Results';
        newSetting5.Value__c = '5000';
        insert newSetting5;
        
        Account yseali = new Account();
        yseali.name = 'YSEALI';
        insert yseali;
        
        List<Contact> myList = new List<Contact>();

        Contact a = new Contact();
        a.email = 'ngamocha@gmail.com';
        a.firstName = 'apex';
        a.lastName = 'test';
        a.city__c = 'testsville';
        a.Spoken_Languages__c = 'English';
        a.AccountId = yseali.id;
        a.Initial_Creation_Type__c = 'Video';
        insert a;
        myList.add( a );
        
        Contact a1 = new Contact();
        a1.email = 'c@gmail.com';
        a1.firstName = 'apex';
        a1.lastName = 'test';
        a1.city__c = 'testsville';
        a1.Spoken_Languages__c = 'English';
        a1.AccountId = yseali.id;
        a1.Initial_Creation_Type__c = 'Video';
        insert a1;
        myList.add( a1 );

        Blob file = Blob.valueOf( '' );
        Folder newFolder = [Select Id From Folder WHERE name = 'Shared Documents' limit 1];
        Document ysealiAttachment = new Document( name='YSEALI Attachment',  Keywords='YSEALI Attachment', Description='YSEALI Attachment', body=file, folderId=newFolder.id );
        insert ysealiAttachment;
        
        Test.startTest();
        Test.setMock( HttpCalloutMock.class, new TEST_YSEALICalloutMockSubscribe() );
        YSEALI_Controller.batchSubscribe(myList);
        Test.stopTest();
    }
    
    static testMethod void testSubscribeYSEALIUsers()
    {
        Account yseali = new Account();
        yseali.name = 'YSEALI';
        insert yseali;
        
        Contact a = new Contact();
        a.email = 'test_1@yseali.com';
        a.firstName = 'apex';
        a.lastName = 'test1';
        a.city__c = 'alexandria';
        a.Spoken_Languages__c = 'English';
        a.Initial_Creation_Type__c = 'Video';
        insert a;
        
        Contact a1 = new Contact();
        a1.email = 'test_2@yseali.com';
        a1.firstName = 'apex';
        a1.lastName = 'test2';
        a1.city__c = 'alexandria';
        a1.Spoken_Languages__c = 'English';
        a1.AccountId = yseali.id;
        a1.Initial_Creation_Type__c = 'Video';
        insert a1;
        
        Global_Variable__c newSetting = new Global_Variable__c();
        newSetting.Name = 'MailChimp getList URL';
        newSetting.Value__c = 'https://us8.api.mailchimp.com/2.0/lists/list.json';
        insert newSetting;
        
        Global_Variable__c newSetting2 = new Global_Variable__c();
        newSetting2.Name = 'MailChimp API Key';
        newSetting2.Value__c = '76f4f0aafffc3f9af72b74d39f09461d-us8';
        insert newSetting2;
        
        Global_Variable__c newSetting3 = new Global_Variable__c();
        newSetting3.Name = 'MailChimp Subscribe URL';
        newSetting3.Value__c = 'https://us8.api.mailchimp.com/2.0/lists/batch-subscribe.json';
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
        
        Global_Variable__c newSetting7 = new Global_Variable__c();
        newSetting7.Name = 'MailChimp SubUsers URL';
        newSetting7.Value__c = 'https://us8.api.mailchimp.com/2.0/lists/members.json';
        insert newSetting7;
        
        Global_Variable__c newSetting8 = new Global_Variable__c();
        newSetting8.Name = 'MailChimp UnSubscribe URL';
        newSetting8.Value__c = 'https://us8.api.mailchimp.com/2.0/lists/batch-unsubscribe.json';
        insert newSetting8;
        
        Global_Variable__c newSetting9 = new Global_Variable__c();
        newSetting9.Name = 'Session Timedout';
        newSetting9.Value__c = '120000';
        insert newSetting9;
        
        Global_Variable__c newSetting10 = new Global_Variable__c();
        newSetting10.Name = 'Max Query Results';
        newSetting10.Value__c = '5000';
        insert newSetting10;
        
        Test.startTest();
        Test.setMock( HttpCalloutMock.class, new TEST_YSEALICalloutMock() );
        YSEALI_Controller.subscribeYSEALIUsers();
        Test.stopTest();
    }
}
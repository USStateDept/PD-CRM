@isTest		
public class TEST_User_Controller
{
	public static testMethod void testUser_Controller()
    {
    	Id profileID = [SELECT id FROM profile where Name = 'Overage Authenticated Website User'].id;
    	
    	Account myAccount = new Account();
    	myAccount.name = 'test';
    	insert myAccount;

        Contact newContact;
        newContact = new Contact();
        newContact.AccountId = myAccount.id;
        newContact.LastName = 'Ztest';
        newContact.Email = 'Ztest@ztestz.com';
        insert newContact;
    	
    	User testUser = new User();
    	testUser.LastName = 'Ztest';
    	testUser.FirstName = 'ZTest';
    	testUser.Username = 'Ztest@ztestz.com';
    	testUser.Email = 'Ztest@ztestz.com';
    	testUser.Alias = 'Ztest';
    	testUser.TimeZoneSidKey = 'GMT';
        testUser.LocaleSidKey = 'en_US';
        testUser.EmailEncodingKey = 'ISO-8859-1';
        testUser.LanguageLocaleKey = 'en_US';
        testUser.ContactId = newContact.id;
        testUser.ProfileId = profileID;
    	insert testUser;
    	
    	User testUser2 = new User();
    	testUser2.LastName = 'Ztest2';
    	testUser2.FirstName = 'ZTest2';
    	testUser2.Username = 'Ztest2@ztestz.com';
    	testUser2.Email = 'Ztest2@ztestz.com';
    	testUser2.Alias = 'Ztest2';
    	testUser2.TimeZoneSidKey = 'GMT';
        testUser2.LocaleSidKey = 'en_US';
        testUser2.EmailEncodingKey = 'ISO-8859-1';
        testUser2.LanguageLocaleKey = 'en_US';

        ApexPages.StandardController sc1 = new ApexPages.StandardController( testUser );
        ApexPages.StandardController sc2 = new ApexPages.StandardController( testUser2 );
        User_Controller obj1 = new User_Controller( sc1 );
        User_Controller obj2 = new User_Controller( sc2 );
        obj1.application = 'test';
        System.assertEquals( new PageReference( '/apex/User_List' ).getUrl(), obj1.save().getUrl() );
        System.assertEquals( null, obj2.save() );
        obj2.application = 'test';
        System.assertEquals( new PageReference( '/apex/User_List' ).getUrl(), obj2.save().getUrl() );
        
        System.assertEquals( 'None;test;', obj1.getApplications() );
    }
}
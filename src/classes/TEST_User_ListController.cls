@isTest	
public class TEST_User_ListController
{
	public static testMethod void testUser_ListController()
    {
    	User_ListController obj = new User_ListController();
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
        
    	obj.firstName = 'Ztest';
    	obj.lastName = 'Ztest';
    	obj.username = 'Ztest@ztestz.com';
    	System.assertEquals( 1, obj.getListOfSitecomUsers().size() );
    	System.assertEquals( new PageReference( '/apex/User_Edit' ).getUrl(), obj.create().getUrl() );
    	System.assertEquals( null, obj.refresh() );
    	obj.userId = testUser.id;
    	
    	obj.resetPassword();
    	obj.activateUser();
    	obj.deactivateUser();
    }
}
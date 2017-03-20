@isTest
public class TEST_UserTrigger
{
    static testMethod void updateUser()
    {
        // Testing admin first... 
        Profile admin = [SELECT Id FROM Profile WHERE Name= 'System Administrator' AND description = '' LIMIT 1];
        Profile iip   = [SELECT Id FROM Profile WHERE Name= 'IIP User' LIMIT 1];
    
    	User_Modification__c newSetting = new User_Modification__c();
    	newSetting.Name = 'Allowed Profile';
    	newSetting.Value__c = 'System Administrator';
    	insert newSetting;
    	
    	User_Modification__c newSetting2 = new User_Modification__c();
    	newSetting2.Name = 'Allowed Fields';
    	newSetting2.Value__c = 'testing';
    	insert newSetting2;
    	
        User myUser = new User(Alias = 'standt', Email='standarduser8675309@testorg.com', 
                            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                            LocaleSidKey='en_US', TimeZoneSidKey='America/Los_Angeles');
        myUser.ProfileId = admin.Id;
        myUser.Username = 'ok_to_publish@test.test';
        insert myUser;
        
        User myTestUser = new User(Alias = 'standt', Email='standarduser8675309@testorg.com', 
                            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                            LocaleSidKey='en_US', TimeZoneSidKey='America/Los_Angeles');
        myTestUser.ProfileId = iip.Id;
        myTestUser.Username = 'ok_to_publish124@test.test';
        insert myTestUser;
        
        system.runAs( myUser )
        {
            myTestUser.Alias = 'test';
            update myTestUser;
        }
        
        System.runAs( myTestUser )
        {
            myTestUser.Alias = 'test123';
            try
            {
            	update myTestUser;
            }
            catch (Exception e)
            {
            	System.assertEquals( 'Update failed. First exception on row 0 with id ' + myTestUser.id + '; first error: FIELD_CUSTOM_VALIDATION_EXCEPTION, You do not have permission to update this information. To have your details modified, please send a ticket to embassy-help@getusinfo.com. Thank you.: []', e.getMessage() );
            }
        }
    }
}
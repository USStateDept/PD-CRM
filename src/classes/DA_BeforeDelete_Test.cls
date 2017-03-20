/**
	 * Test for DA_BeforeDelete trigger 
	 *
	 * <p>Trigger logic checks for asset status and ownership before permitting delete </p>
	 */
@isTest
private class DA_BeforeDelete_Test {


    static testMethod void testDeleteApproved() 
    {
		System.runAs ( new User(Id = UserInfo.getUserId()) ) //need this line to avoid mixed dml error
		{
			Profile p = DA_Test_Helper.getProfile('Publishing Copy Desk');
			QueueSobject q = DA_Test_Helper.getQueue('Copy Desk Queue');
			User u = DA_Test_Helper.createUserWithoutProfile();
			u.ProfileId = p.Id;
			u.Username = 'ok_to_delete@test.test';
			insert u;
			
			GroupMember gm = new GroupMember(UserOrGroupId = u.Id, GroupId = q.QueueId );
			insert gm;
		
	   		test.startTest();
		   		Digital_Asset__c testasset = (Digital_Asset__c)GLOBAL_Library.createObj('Digital_Asset__c', null);
		   		testasset.Name = 'some headline';
                testasset.Language__c = 'English';
                testasset.Asset_Type__c = 'Audio';
                testasset.Asset_Subtype__c = 'Internal Use Only';
                testasset.Headline_long__c = 'Some testing asset';
                testasset.Published_URL__c = 'www.shouldntgoanywhere.com.org.gov.edu';
                testasset.Social_Media_Blurb__c = 'some social media blurb';
                testasset.Microblog__c = 'some microblog text';
                testasset.Search_Keywords__c = 'some; super; keywords; required; field';
            
            	testasset.Status__c = 'Approved Not Published';
		   		testasset.OwnerId = q.QueueId;
		   		insert testasset;
		   		
		   		id assetId = testasset.Id;
		   		
		   		System.runAs(u) 
		   		{
		   			delete testasset;
		   			List<Digital_Asset__c> deletedAsset = new List<Digital_Asset__c>([select Id from Digital_Asset__c where Id =: assetId]);
		   			system.AssertEquals(0, deletedAsset.size());
		   		}
		   		test.stopTest();
		}		
    }
    
    static testMethod void testDeleteTranslatorNotOwner() 
    {
    	System.runAs ( new User(Id = UserInfo.getUserId()) ) //need this line to avoid mixed dml error
		{
	    	Profile p = DA_Test_Helper.getProfile('Publishing Translator');
			QueueSobject q = DA_Test_Helper.getQueue('Copy Desk Queue');
			User u = DA_Test_Helper.createUserWithoutProfile();
			u.ProfileId = p.Id;
			u.Username = 'not_ok_to_delete@test.test';
			insert u;
			
			GroupMember gm = new GroupMember(UserOrGroupId = u.Id, GroupId = q.QueueId );
			insert gm;
	        
	   		test.startTest();
		   		Digital_Asset__c testasset = (Digital_Asset__c)GLOBAL_Library.createObj('Digital_Asset__c', null);
                testasset.Language__c = 'English';
                testasset.Asset_Type__c = 'Publication';
                testasset.Parent_Slug_Id__c = 'test123';
            
            	testasset.Status__c = 'In Translation';
		   		testasset.OwnerId = q.QueueId;
		   		insert testasset;
		   		
		   		id assetId = testasset.Id;
		   		string msg = 'success';
		   		
		   		System.runAs(u) {
		   			try{
		   			delete testasset;
		   			}
		   			catch(DMLException e)
		   			{
		   				msg = e.getMessage();
		   			}
		   			List<Digital_Asset__c> deletedAsset = new List<Digital_Asset__c>([select Id from Digital_Asset__c where Id =: assetId]);
		   			system.AssertEquals(1, deletedAsset.size());
		   			system.AssertNotEquals('success',msg);
		   		}
	   		test.stopTest();
            
                      
		}
    }
    
    
    static testMethod void testDeleteNegativeTranslatorWrongStatus() 
    {

		System.runAs ( new User(Id = UserInfo.getUserId()) ) //need this line to avoid mixed dml error
		{
			Profile p = DA_Test_Helper.getProfile('Publishing Translator');
			QueueSobject q = DA_Test_Helper.getQueue('Copy Desk Queue');
			User u = DA_Test_Helper.createUserWithoutProfile();
			u.ProfileId = p.Id;
			u.Username = 'ok_to_delete@test.test';
			insert u;
			GroupMember gm = new GroupMember(UserOrGroupId = u.Id, GroupId = q.QueueId );
			insert gm;
        
	   		test.startTest();
		   		Digital_Asset__c testasset = (Digital_Asset__c)GLOBAL_Library.createObj('Digital_Asset__c', null);
		   		testasset.Language__c = 'English';
                testasset.Asset_Type__c = 'Publication';
                testasset.Parent_Slug_Id__c = 'test123';
            	testasset.Status__c = 'Approved Not Published';
		   		testasset.OwnerId = q.QueueId;
		   		insert testasset;
		   		
		   		id assetId = testasset.Id;
		   		string msg = 'success';
		   		
		   		System.runAs(u) {
		   			try{
		   			delete testasset;
		   			}
		   			catch(DMLException e)
		   			{
		   				msg = e.getMessage();
		   			}
		   			List<Digital_Asset__c> deletedAsset = new List<Digital_Asset__c>([select Id from Digital_Asset__c where Id =: assetId]);
		   			system.AssertEquals(1, deletedAsset.size());
		   			system.AssertNotEquals('success',msg);
		   		}
	   		test.stopTest();
   		
		}
    }
    
    
}
/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class DA_BeforeUpdate_Test {

	public static User setupTestUser(string profileName)
	{
		Profile p = DA_Test_Helper.getProfile(profileName);
		User u = DA_Test_Helper.createUserWithoutProfile();
		u.ProfileId = p.Id;
		u.Default_Translation_Language__c = 'French';
		u.Username = 'ok_to_translate@test.test';
		return u;
	}
	
	public static Digital_Asset__c setupTestData()
	{	
		Digital_Asset__c testasset = new Digital_Asset__c();
   		testasset.Status__c = 'In Work';
   		testasset.Language__c = 'French';
   		testasset.Asset_Type__c = 'Publication';
   		testasset.Asset_Subtype__c = 'some subtype';
   		testasset.Search_Keywords__c = 'some words';
   		testasset.Article_Body__c = 'Some article body text';
   		testasset.Top__c = 'Some top text';
   		testasset.Content_Teaser__c = 'Some content teaser text';
   		testasset.Parent_Slug_ID__c = null;
   		insert testasset;
   		
   		return testasset;
	}
	
	static testMethod void testInTranslation() 
    {
		User u = DA_BeforeUpdate_Test.setupTestUser('Publishing Translator');
		Digital_Asset__c testasset = DA_BeforeUpdate_Test.setupTestData();
			
   		test.startTest();
	   		System.runAs(u) 
	   		{
	   			Digital_Asset__c results = [select Id, Status__c, Language__c 
	   												from Digital_Asset__c 
	   												where Id =: testasset.Id];
	   			system.assertNotEquals(null,results);
	   			system.assertEquals('In Translation',results.Status__c);
	   		}
	   	test.stopTest();
    }
    
    static testMethod void testRichTextUpdates() 
    {
		User u = DA_BeforeUpdate_Test.setupTestUser('Publishing Copy Desk');
		Digital_Asset__c testasset = DA_BeforeUpdate_Test.setupTestData();
		testasset.Article_Body__c = 'some html';
		testasset.Top__c = 'some html';
		testasset.Content_Teaser__c = 'some html';
   		update testasset;
   		
   		test.startTest();
	   		System.runAs(u) 
	   		{
	   			Digital_Asset__c results = [select Id, Status__c, Language__c 
	   												from Digital_Asset__c 
	   												where Id =: testasset.Id];
	   			system.assertNotEquals(null,results);
	   			system.assertEquals('In Translation',results.Status__c);
	   		}
	   	test.stopTest();
    }
	
	static testMethod void testInWorkRequiredFields() 
    {
		Profile p = DA_Test_Helper.getProfile('Publishing Content Creator');
		User u = DA_Test_Helper.createUserWithoutProfile();
		u.ProfileId = p.Id;
		u.Username = 'ok_to_create@test.test';
			
   		test.startTest();
	   		System.runAs(u) 
	   		{
                Digital_Asset__c testasset = new Digital_Asset__c();
                testasset.Status__c = 'In Draft';
	   			testasset.Article_Body__c = 'Some article body text';
	   			testasset.Top__c = 'Some top text';
	   			testasset.Content_Teaser__c = 'Some content teaser text';
                testasset.Language__c = 'English';
	   			insert testasset;
	   			
	   			id assetId = testasset.Id;
	   			string msg = 'success';
	   			try
	   			{
	   				testasset.Status__c = 'In Work';
	   				testasset.Language__c = '';
	   				testasset.Asset_Type__c = 'Audio';
	   				testasset.Asset_Subtype__c = 'Something';
	   				testasset.Search_Keywords__c = 'some words';
	   				update testasset;
	   			}
	   			catch(DMLException e)
	   			{
	   				msg = e.getMessage();
	   			}
	   			
	   			system.AssertNotEquals('success', msg);
	   				   		
	   			try
	   			{
	   				testasset.Status__c = 'In Work';
	   				testasset.Language__c = 'English';
	   				testasset.Asset_Type__c = '';
	   				testasset.Asset_Subtype__c = 'Something';
	   				testasset.Search_Keywords__c = 'some words';
	   				update testasset;
	   			}
	   			catch(DMLException e)
	   			{
	   				msg = e.getMessage();
	   			}
	   			system.Assert(msg.contains('Type'));
	   			
	   			try
	   			{
	   				testasset.Status__c = 'In Work';
	   				testasset.Language__c = 'English';
	   				testasset.Asset_Type__c = 'Audio';
	   				testasset.Asset_Subtype__c = '';
	   				testasset.Search_Keywords__c = 'some words';
	   				update testasset;
	   			}
	   			catch(DMLException e)
	   			{
	   				msg = e.getMessage();
	   			}
	   			system.Assert(msg.contains('Sub'));
	   			
	   			try
	   			{
	   				testasset.Status__c = 'In Work';
	   				testasset.Language__c = 'English';
	   				testasset.Asset_Type__c = 'Audio';
	   				testasset.Asset_Subtype__c = 'Something';
	   				testasset.Search_Keywords__c = '';
	   				update testasset;
	   			}
	   			catch(DMLException e)
	   			{
	   				msg = e.getMessage();
	   			}
	   			system.Assert(msg.contains('Search'));
	   		}
	   	test.stopTest();	
    }
    



}
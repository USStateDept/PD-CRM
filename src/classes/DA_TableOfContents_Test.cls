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
private class DA_TableOfContents_Test {

	private static Digital_Asset__c createTestTOCAsset(boolean defaultTOCHidden)
	{
   	  Digital_Asset__c testasset = (Digital_Asset__c)GLOBAL_Library.createObj('Digital_Asset__c', null);

	  if(defaultTOCHidden)
      	testasset.ToC_Hidden__c = '123##456';
      
      testasset.Language__c = 'English';
      testAsset.Asset_Type__c = 'Table of Contents';
	 	
      return testasset;
	}

	private static Digital_Asset__c createTestTOCWithChapters()
	{
   	  	Digital_Asset__c testTOC = createTestTOCAsset(false);
   	  	insert testTOC;
   	  
   	  	Digital_Asset__c testchapter = (Digital_Asset__c)GLOBAL_Library.createObj('Digital_Asset__c', null);
		testchapter.Publication_Title__c = testTOC.Id;
      	testchapter.Language__c = 'English';
      	testchapter.Asset_Type__c = 'Publication';
      	testchapter.ToC_Blurb__c = 'Some TOC Blurb';
      	
      	insert testchapter;
      	
      	return testTOC;
	}
	
	private static testmethod void testRecompileTOCBody()
	{
		Digital_Asset__c testTOC = createTestTOCWithChapters();
		string retVal = DA_TableOfContents.RecompileTOCBody(testTOC);
      	system.assert(!retVal.contains('Please reorder the chapters to repair'));
	}

   
   private static testmethod void testNegativeRecompileTOCBody()
   {
		Digital_Asset__c testasset = createTestTOCAsset(true);
		insert testasset;
		string retVal = DA_TableOfContents.RecompileTOCBody(testasset);
		system.assert(retVal.contains('Please reorder the chapters to repair'));
   }
   
   private static testmethod void testAddTitleTOC()
   {
		string sSlugId = '000123456789000';
		string sTitle = sSlugId + ' q some title';
		
		DA_TableOfContents.AddTitleTOC(sSlugId, sTitle, 'search key words', 'English', 'Test', true);
		List<Digital_Asset__c> results = [select Id, Name, Slug_Id__c from Digital_Asset__c where Asset_Type__c = 'Table of Contents' and Headline_Long__c =: sTitle ];
		system.assertEquals(1, results.size());   	
   }
   
   private static testmethod void testPublishTOC()
   {
		Digital_Asset__c testTOC = createTestTOCWithChapters();
		Profile p = DA_Test_Helper.getProfile('Publishing Copy Desk');
		User u = DA_Test_Helper.createUserWithoutProfile();
		u.ProfileId = p.Id;
		u.Username = 'ok_to_publish@test.test';
		
		insert u;
		string retVal = DA_TableOfContents.PublishTOC(testTOC, u);
		system.debug('DEBUG:: retVal: ' + retVal);
   }
   
   private static testmethod void testReallyAddAssetTOC()
   {
      string results;
      results = DA_TableOfContents.ReallyAddAssetTOC('0123456789', '654231879');
      results = DA_TableOfContents.ReallyAddAssetTOC('0123456789', '');
   }
}
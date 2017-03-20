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
private class DA_AutoSave_Test {
    
    static testMethod void testupdateFieldValue()
    {
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
        
    	insert testasset;
    	test.startTest();
	    	Boolean retVal = DA_AutoSave.updateFieldValue(testasset.Id, 'Article_Body__c', 'This is the autosave');	
	    	system.AssertEquals(true, retVal);
	    	Digital_Asset__c result = [select Id, Article_Body__c from Digital_Asset__c where Id =: testasset.Id];
	    	system.AssertEquals('This is the autosave',result.Article_Body__c);
    	test.stopTest();
    }
    
}
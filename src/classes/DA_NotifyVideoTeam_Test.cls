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
private class DA_NotifyVideoTeam_Test {

    static testmethod void testNotifyVideoMessage()
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
		
		test.startTest();
		PageReference pageRef = Page.DA_Email;
        pageRef.getParameters().put('id', String.valueOf(testasset.Id));
        pageRef.getParameters().put('reqtype', 'video');
        Test.setCurrentPage(pageRef);
		
		ApexPages.StandardController sc = new ApexPages.StandardController(testasset);
        DA_NotifyVideoTeam controller = new DA_NotifyVideoTeam(sc);
        
        string result = DA_NotifyVideoTeam.GenerateNotifyVideoMessage(String.valueOf(testasset.Id));
        system.assertNotEquals('',result);
        
		test.stopTest();
	}
    
    
    
}
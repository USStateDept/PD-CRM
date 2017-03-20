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
private class DA_Tab_Test {

    static testMethod void testSearch() 
	{
		//create asset for standard controller
		Digital_Asset__c testasset = (Digital_Asset__c)GLOBAL_Library.createObj('Digital_Asset__c', null);  
	    testasset.Asset_Date_Time__c = datetime.now();
	    testasset.Asset_Type__c = 'Audio';
	    testasset.Asset_Subtype__c = 'Internal Use Only';
	    testasset.Name = 'some headline';
	    testasset.Headline_Long__c = 'Sample Asset Headline Long';
	    testasset.Search_Keywords__c = 'test hello world';
	    testasset.Article_Body__c = 'Sample Body Text 123';
	    testasset.Author__c = 'Some Author';
	    testasset.Search_Keywords__c = 'Keyword1';
	    testasset.Language__c = 'English';
	    testasset.Status__c = 'Published';     
	    insert testasset;
	
	    PageReference pageRef = Page.DA_Tab;
	   	Test.setCurrentPage(pageRef);
		   	
	   	// Add parameters 
		pageRef.getParameters().put('headline', 'some headline');
	    pageRef.getParameters().put('language', 'English');
	    pageRef.getParameters().put('author', 'Some Author');
	    pageRef.getParameters().put('status', 'Published');
	    pageRef.getParameters().put('assettype', 'Audio');
	    pageRef.getParameters().put('assettheme','Internal Use Only');
	    pageRef.getParameters().put('searchkeywords','Keyword1');
	    pageRef.getParameters().put('assetdatetime','01/01/2099 12:00 AM');
	   	 	
	   	DA_Tab controller = new DA_Tab(new ApexPages.StandardController(testasset));
	   	
	   	System.assertEquals(controller.assetdatetimeoperator,DA_Tab.ASSET_DT_OPERATOR_DEFAULT);
	   	
	   	controller.assetdatetimeoperator = '<';
	   	
	   	System.assertNotEquals(controller.languages, null);
	   	System.assertNotEquals(controller.status, null);
	   	System.assertNotEquals(controller.assettype, null);
	   	System.assertNotEquals(controller.assettheme, null);
	   	
	   	System.assertNotEquals(controller.debugSoql,null);
		controller.runSearch();
		System.assertNotEquals(controller.assets, null);
		
		controller.toggleSort();
		System.assertNotEquals(controller.sortDir, DA_Tab.ASSET_SORT_DIR_DEFAULT);
		System.assertEquals(controller.sortField, DA_Tab.ASSET_SORT_FIELD_DEFAULT);
		
		controller.showPopup();
		controller.closePopup();
	}
}
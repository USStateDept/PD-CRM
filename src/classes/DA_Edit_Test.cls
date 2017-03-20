@isTest
private class DA_Edit_Test 
{

static testMethod void testupdateFieldValue()
    {
    	Digital_Asset__c testasset = (Digital_Asset__c)GLOBAL_Library.createObj('Digital_Asset__c', null);
   		testasset.Status__c = 'In Work';
   		testasset.Language__c = 'French';
   		testasset.Asset_Type__c = 'Publication';
   		testasset.Asset_Subtype__c = 'some subtype';
   		testasset.Search_Keywords__c = 'some words';
   		testasset.Article_Body__c = 'This is the autosave';
   		testasset.Top__c = 'Some top text';
   		testasset.Content_Teaser__c = 'Some content teaser text';
   		testasset.Parent_Slug_ID__c = null;
   		insert testasset;
   		
   	
    	test.startTest();
	    	Boolean retVal = DA_Edit.updateFieldValue(testasset.Id, 'Article_Body__c', 'This is the autosave');	
	    	system.AssertEquals(true, retVal);
	    	Digital_Asset__c result = [select Id, Article_Body__c from Digital_Asset__c where Id =: testasset.Id];
	    	system.AssertEquals('This is the autosave',result.Article_Body__c);
    	test.stopTest();
    }

}
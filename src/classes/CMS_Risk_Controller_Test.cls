@isTest
public class CMS_Risk_Controller_Test {
    
    // Test Controller object 
    static testmethod void testCMS_Risk_Controller(){
        CMS_Risk__c record = new CMS_Risk__c();
		ApexPages.StandardController sc = new ApexPages.StandardController( record );
		CMS_Risk_Controller testObj = new CMS_Risk_Controller(sc);
    }
    
    // Test VF edit page for Risk owner comments
    static testmethod void testOpenRMEdit(){
        CMS_Risk__c risk = new CMS_Risk__c();
		ApexPages.StandardController sc = new ApexPages.standardController(risk);
        CMS_Risk_Controller testObj = new CMS_Risk_Controller(sc);
	    PageReference pageRef = testObj.openRMEdit();
    }
    
    // Test VF edit page for Risk Manager updates to Risk Analysis
    static testmethod void testOpenRAEdit(){
        CMS_Risk__c risk = new CMS_Risk__c();
		ApexPages.StandardController sc = new ApexPages.standardController(risk);
        CMS_Risk_Controller testObj = new CMS_Risk_Controller(sc);
	    PageReference pageRef = testObj.openRAEdit();
    }
    
    // Test VF edit page for Risk Manager updates to Issue Analysis
    static testmethod void testOpenIAEdit(){
        CMS_Risk__c risk = new CMS_Risk__c();
		ApexPages.StandardController sc = new ApexPages.standardController(risk);
        CMS_Risk_Controller testObj = new CMS_Risk_Controller(sc);
	    PageReference pageRef = testObj.openIAEdit();
    }
    
	// Test triggered checkbox and date
    static testmethod void testSetTriggered(){
        CMS_Risk__c risk = new CMS_Risk__c();
        insert risk;
		ApexPages.StandardController sc = new ApexPages.standardController(risk);
        CMS_Risk_Controller testObj = new CMS_Risk_Controller(sc);
	    PageReference pageRef = testObj.setTriggered();
    }
}
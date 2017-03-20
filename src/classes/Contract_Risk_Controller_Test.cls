@isTest
public class Contract_Risk_Controller_Test {
	// Test Controller object 
    static testmethod void testCMS_Risk_Controller(){
        Contract_Risk__c record = new Contract_Risk__c();
		ApexPages.StandardController sc = new ApexPages.StandardController( record );
		Contract_Risk_Controller testObj = new Contract_Risk_Controller(sc);
    }
    
    // Test VF edit page for Risk owner comments
    static testmethod void testOpenRMEdit(){
        Contract_Risk__c risk = new Contract_Risk__c();
		ApexPages.StandardController sc = new ApexPages.standardController(risk);
        Contract_Risk_Controller testObj = new Contract_Risk_Controller(sc);
	    PageReference pageRef = testObj.openRMEdit();
    }
    
    // Test VF edit page for Risk Manager updates to Risk Analysis
    static testmethod void testOpenRAEdit(){
        Contract_Risk__c risk = new Contract_Risk__c();
		ApexPages.StandardController sc = new ApexPages.standardController(risk);
        Contract_Risk_Controller testObj = new Contract_Risk_Controller(sc);
	    PageReference pageRef = testObj.openRAEdit();
    }
    
    // Test VF edit page for Risk Manager updates to Issue Analysis
    static testmethod void testOpenIAEdit(){
        Contract_Risk__c risk = new Contract_Risk__c();
		ApexPages.StandardController sc = new ApexPages.standardController(risk);
        Contract_Risk_Controller testObj = new Contract_Risk_Controller(sc);
	    PageReference pageRef = testObj.openIAEdit();
    }
    
	// Test triggered checkbox and date
    static testmethod void testSetTriggered(){
        Contract_Risk__c risk = new Contract_Risk__c();
        insert risk;
		ApexPages.StandardController sc = new ApexPages.standardController(risk);
        Contract_Risk_Controller testObj = new Contract_Risk_Controller(sc);
	    PageReference pageRef = testObj.setTriggered();
    }
}
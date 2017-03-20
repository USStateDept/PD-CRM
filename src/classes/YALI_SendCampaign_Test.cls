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
private class YALI_SendCampaign_Test {

    static testMethod void myUnitTest_sendCampaign() {
        // TO DO: implement unit test
        DOS_TestDataUtility testData = new DOS_TestDataUtility();
        
        Account objAccount = testData.newAccount();
        Contact objContact = testData.newContact();
        
        Campaign c = testData.newCampaign('Campaign');
        Campaign cPledge = testData.newCampaign('Pledge');
        cPledge.ParentId = c.Id;
        update cPledge;
        CampaignMember objCM = testData.newCM(cPledge.Id, objContact.Id);
        System.assert(c != null);
        
        Test.startTest(); 
          PageReference pageRef = Page.YALI_SendCampaign_ToCM;
	      Test.setCurrentPage(pageRef);	      
	      ApexPages.Standardcontroller sc = new ApexPages.StandardController(c);
	      ApexPages.currentPage().getParameters().put('id',c.id);	        
	      YALI_SendCampaign objYCM = new YALI_SendCampaign(sc);
	      objYCM.sendCampaign(); 
	      PageReference pageRef1 = objYCM.CreateContactsInList();      
        Test.stopTest();
        
    }
}
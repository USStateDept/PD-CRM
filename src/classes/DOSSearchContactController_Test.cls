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
@isTest(seeAllData=true)
private class DOSSearchContactController_Test {

    static testMethod void test1_DOSSearchContactController() {
        // TO DO: implement unit test
        DOS_TestDataUtility testData = new DOS_TestDataUtility();
        
        UserRole role1 = testData.newUserRole('Test Mission1', 'Test_Mission1');
        UserRole role2 = testData.newUserRole('Test Mission2', 'Test_Mission2');
        
        User testUser1 = testData.newUser();
        testUser1.UserRoleId = role1.Id;
        update testUser1;
        system.assert(testUser1.userRoleId == role1.Id);       
        
        User testUser2 = testData.newUser();
        testUser2.UserRoleId = role2.Id;
        update testUser2;
        system.assert(testUser2.userRoleId == role2.Id);
                
        Account objAccount, objAccount1;
        Contact objContact;
        
        
        System.runAs(testUser1)
        {
        	objAccount = testData.newAccount();
	        objAccount.Name = role1.Name;
	        objAccount.Type = 'Mission';
	        update objAccount; 
	        system.assert(objAccount.Name == role1.Name);	              
	        
	        objContact = testData.newContact();
	        objContact.AccountId = objAccount.Id;
	        update objContact;
	        system.assert([select Id from Contact where lastname =: objContact.lastname].Id == objContact.Id);
	        
        }
        
        system.runAs(testUser2)
        {
        	objAccount1 = testData.newAccount();
	        objAccount1.Name = role2.Name;
	        objAccount.Type = 'Mission';
	        update objAccount1;
	        system.assert(objAccount1.Name == role2.Name);
        }           
        
      //Test.startTest();   
        System.runAs(testUser2){
	          PageReference pageRef = Page.DOSSearchContactPage;
		      Test.setCurrentPage(pageRef);
		      DOSSearchContactController objSC = new DOSSearchContactController();
		      objSC.lastname = objContact.LastName;
		      objSC.firstname = objContact.FirstName;
		      objSC.runSearch();
		   //   objSC.selContactId = objContact.Id;
		   	  ApexPages.currentPage().getParameters().put('conid',objContact.Id);
		      objSC.getSelected();
		      system.assert(objSC.selContactId == objContact.Id);
		      //Contact con = [Select Id,firstname,lastname from Contact where Id =: objSC.selContactId];
		      //system.assert(con != null);
		      //system.assertEquals(con.lastname, objContact.lastname);
		      //system.assertEquals(con.firstname, objContact.firstname);
		      objSC.shareContact();		      
		      objSC.toggleSort();
		      objSC.selContactId = objContact.Id;
		      objSC.shareContact();	      	      
		      System.assert(objSC != null);        
 	       }    	
	   // Test.stopTest();
    }
}
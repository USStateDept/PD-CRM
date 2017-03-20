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
private class DOSEventRegistrationCheckIn_Test {

    static testMethod void myUnitTest() {
        // TO DO: implement unit test
        DOS_TestDataUtility testData = new DOS_TestDataUtility();
        
        Account objAccount = testData.newAccount();

        Event__c objEvent = testData.newEvent('Published'); 
        objEvent.Show_Map__c = true;
        objEvent.No_of_guests_allowed__c = '2';
        update objEvent;

        Contact objContact = new Contact();
        objContact.LastName = 'testLastname';
        objContact.FirstName = 'testFirstname';
        objContact.Email = 'test@Lastname.com';
        
        Event_Registration__c objER = new Event_Registration__c();
        objER.Event__c = objEvent.Id;
        objER.Contact__c = objContact.Id;
        objER.Preferred_Email__c = 'test@Lastname.com';
        objER.Status__c = 'Accepted';
        insert objER;
                       
        User testUser = testData.newUser();
        
        Test.startTest(); 
        //System.runAs(testUser)        
        {       
          PageReference pageRef = Page.EventRegistrationOnSiteCheckIn;
          Test.setCurrentPage(pageRef);       
          ApexPages.Standardcontroller sc = new ApexPages.StandardController(objEvent);
          ApexPages.currentPage().getParameters().put('id',objEvent.id);          
          DOSEventRegistrationCheckIn objLanding = new DOSEventRegistrationCheckIn(sc);
          objLanding.LastName = 'testLastname';
          objLanding.Email = 'test@Lastname.com';
          objLanding.FirstName = 'testFirstName';
//        objLanding.strEventId = objEvent.id;
          objLanding.onAccept();
          objLanding.getEmbassyDetails(objAccount.Id);
                 
        }           
        Test.stopTest();
        
    }

    static testMethod void myUnitTest1() {
        // TO DO: implement unit test
        DOS_TestDataUtility testData = new DOS_TestDataUtility();
        
        Account objAccount = testData.newAccount();

        Event__c objEvent = testData.newEvent('Published'); 
        objEvent.Show_Map__c = true;
        objEvent.No_of_guests_allowed__c = '2';
        update objEvent;

        Contact objContact = new Contact();
        objContact.LastName = 'testLastname';
        objContact.FirstName = 'testFirstname';
        objContact.Email = 'test@Lastname.com';
        
        Event_Registration__c objER = new Event_Registration__c();
        objER.Event__c = objEvent.Id;
        objER.Contact__c = objContact.Id;
        objER.Preferred_Email__c = 'test@Lastname.com';
        objER.Status__c = 'Attended';
        insert objER;
                       
        User testUser = testData.newUser();
        
        Test.startTest(); 
        //System.runAs(testUser)        
        {       
          PageReference pageRef = Page.EventRegistrationOnSiteCheckIn;
          Test.setCurrentPage(pageRef);       
          ApexPages.Standardcontroller sc = new ApexPages.StandardController(objEvent);
          ApexPages.currentPage().getParameters().put('id',objEvent.id);          
          DOSEventRegistrationCheckIn objLanding = new DOSEventRegistrationCheckIn(sc);
          objLanding.LastName = 'testLastname';
          objLanding.Email = 'test@Lastname.com';
          objLanding.FirstName = 'testFirstName';
//        objLanding.strEventId = objEvent.id;
          objLanding.onAccept();
          objLanding.getEmbassyDetails(objAccount.Id);
                 
        }           
        Test.stopTest();
        
    }

    static testMethod void myUnitTest2() {
        // TO DO: implement unit test
        DOS_TestDataUtility testData = new DOS_TestDataUtility();
        
        Account objAccount = testData.newAccount();

        Event__c objEvent = testData.newEvent('Published'); 
        objEvent.Show_Map__c = true;
        objEvent.No_of_guests_allowed__c = '2';
        update objEvent;

        Contact objContact = new Contact();
        objContact.LastName = 'testLastname';
        objContact.FirstName = 'testFirstname';
        objContact.Email = 'test@Lastname.com';
        
        Event_Registration__c objER = new Event_Registration__c();
        objER.Event__c = objEvent.Id;
        objER.Contact__c = objContact.Id;
        objER.Preferred_Email__c = 'test@Lastname.com';
        objER.Status__c = 'Attended';
        insert objER;
                       
        User testUser = testData.newUser();
        
        Test.startTest(); 
        //System.runAs(testUser)        
        {       
          PageReference pageRef = Page.EventRegistrationOnSiteCheckIn;
          Test.setCurrentPage(pageRef);       
          ApexPages.Standardcontroller sc = new ApexPages.StandardController(objEvent);
          ApexPages.currentPage().getParameters().put('id',objEvent.id);          
          DOSEventRegistrationCheckIn objLanding = new DOSEventRegistrationCheckIn(sc);
          objLanding.LastName = 'testLastname';
          objLanding.Email = 'test1@Lastname.com';
          objLanding.FirstName = 'testFirstName';
//        objLanding.strEventId = objEvent.id;
          objLanding.onAccept();
          objLanding.getEmbassyDetails(objAccount.Id);
                 
        }           
        Test.stopTest();
        
    }

}
/**
 * This is the test class for ContactExt
 * Created By: Kalyan Lanka
 **/
@isTest
public class ContactExtTest {

    /** Initial Test Setup.  Test for PD CRM profile and System admin (Non PD CRM Profile) **/
    @testSetup
    public static void setupData() {
        
        Profile prof = [select id from profile where name = 'System Administrator' order by createdDate LIMIT 1];
        
        Profile pdCRM;
        try {
             pdCRM = [select id from profile where name = 'PD CRM' order by createdDate LIMIT 1];
             User pdCRMUser = new User(alias = 'standt', email = 'testDummyPDCRM@testorg.com',  emailencodingkey = 'UTF-8', lastname = 'Testing', languagelocalekey = 'en_US', 
                           localesidkey = 'en_US', profileid = pdCRM.Id, 
                           timezonesidkey = 'America/Los_Angeles', username = 'testDummyPDCRM@testorg.com');
                Database.SaveResult sr1 = Database.Insert(pdCRMUser);
            
            System.runAs(pdCRMUser){
                Account acc = new Account(Name='U.S. Mission Indonesia');
                insert acc;
                Contact c = new Contact();
                c.firstName = 'PDCRM';
                c.LastName = 'Indonesia';
                c.AccountId = acc.id;
                c.Region__c = 'EAP';
                c.Country__c = 'Indonesia';
                //c.Country_of_Residence__c = 'Indonesia';
                c.Citizenship__c = 'Indonesia';
                insert c;
            }
        System.assert(sr1.isSuccess());
        } catch (QueryException qe){
           //That is okay
        }
                
         User sysAdmin = new User(alias = 'standt', email = 'testDummy@testorg.com', 
                           emailencodingkey = 'UTF-8', lastname = 'Testing', languagelocalekey = 'en_US', 
                           localesidkey = 'en_US', profileid = prof.Id, 
                           timezonesidkey = 'America/Los_Angeles', username = 'testDummy@testorg.com');
        Database.SaveResult sr = Database.Insert(sysAdmin);
        System.assert(sr.isSuccess());
        
        Account acc = new Account(Name='US Embassy');
        insert acc;
        Contact c = new Contact();
        c.firstName = 'Test';
        c.LastName = 'Name';
        c.AccountId = acc.id;
        c.Region__c = 'EAP';
        c.Country__c = 'Indonesia';
        //c.Country_of_Residence__c = 'Indonesia';
        c.Citizenship__c = 'Indonesia';
        insert c;

    }
    
  
    /** Test View Redirection.  PD CRM Profile should go to the custom pages and non PD CRM to their Default pages **/
    public static testMethod void testViewRedirect() {
        User systeAdmin = [SELECT id from User where username = 'testDummy@testorg.com' limit 1];
        System.runAs(systeAdmin){
            CONTACT C = [SELECT ID FROM Contact where firstName = 'Test' and lastName = 'Name' LIMIT 1];
            ApexPages.currentPage().getParameters().put('id',c.id);
            ApexPages.StandardController stdContact = new ApexPages.StandardController(c);
            ContactExt ce = new ContactExt(stdContact);
            PageReference pg = ce.redirectView();
            System.debug(pg);
            
        }

    }
    
      /** Test Save.  PD CRM Profile should go to the update the Account and Region and non PD CRM to their Defaults **/
     public static testMethod void testSaveAsAdmin() {
        User pdCRM = [SELECT id from User where username = 'testDummyPDCRM@testorg.com' limit 1];
             try {
                 System.runAs(pdCRM){
                CONTACT C = [SELECT ID, FirstName, LastName FROM Contact where firstName = 'Test' and lastName = 'Name' LIMIT 1];
                c.FirstName = 'Test1';
                ApexPages.currentPage().getParameters().put('id',c.id);
                ApexPages.StandardController stdContact = new ApexPages.StandardController(c);
                ContactExt ce = new ContactExt(stdContact);
                ce.save();
                
            }
             } catch (QueryException eq){
                 //okay
             }
        

    }
    
    /** Test Save.  PD CRM Profile should go to the update the Account and Region and non PD CRM to their Defaults **/
    public static testMethod void testSaveAsPDCRM() {
        User pdCRMUser = [SELECT id from User where username = 'testDummyPDCRM@testorg.com' limit 1];
        System.runAs(pdCRMUser){
            CONTACT C = [SELECT ID, FirstName, LastName FROM Contact where firstName = 'PDCRM' and lastName = 'Indonesia' LIMIT 1];
            c.FirstName = 'Test1';
            ApexPages.currentPage().getParameters().put('id',c.id);
            ApexPages.StandardController stdContact = new ApexPages.StandardController(c);
            ContactExt ce = new ContactExt(stdContact);
            ce.save();
            
        }

    }
    
    /** Test Create/Edit Redirection.  PD CRM Profile should go to the custom pages and non PD CRM to their Default pages **/
     public static testMethod void testCreateRedirectAsSystAdmin() {
        User systeAdmin = [SELECT id from User where username = 'testDummy@testorg.com' limit 1];
        System.runAs(systeAdmin){
            CONTACT C = new Contact();
            ApexPages.currentPage().getParameters().put('id',null);
            ApexPages.StandardController stdContact = new ApexPages.StandardController(c);
            ContactExt ce = new ContactExt(stdContact);
            PageReference pg = ce.redirectEdit();
            
             C = [SELECT ID, FirstName, LastName FROM Contact where firstName = 'Test' and lastName = 'Name' LIMIT 1];
              c.FirstName = 'Test1';
              ApexPages.currentPage().getParameters().put('id',c.id);
               stdContact = new ApexPages.StandardController(c);
               ce = new ContactExt(stdContact);
              pg = ce.redirectEdit();
            
        }

    }
    
        /** Test Create/Edit Redirection.  PD CRM Profile should go to the custom pages and non PD CRM to their Default pages **/
    public static testMethod void testCreateRedirectAsPDCRM() {
        User pdCRM = [SELECT id from User where username = 'testDummyPDCRM@testorg.com' limit 1];
        System.runAs(pdCRM){
            CONTACT C = new Contact();
            ApexPages.currentPage().getParameters().put('id',null);
            ApexPages.StandardController stdContact = new ApexPages.StandardController(c);
            ContactExt ce = new ContactExt(stdContact);
            PageReference pg = ce.redirectEdit();
            
             C = [SELECT ID, FirstName, LastName FROM Contact where firstName = 'PDCRM' and lastName = 'Indonesia' LIMIT 1];
              
              ApexPages.currentPage().getParameters().put('id',c.id);
               stdContact = new ApexPages.StandardController(c);
               ce = new ContactExt(stdContact);
              pg = ce.redirectEdit();
            
        }

    }

}
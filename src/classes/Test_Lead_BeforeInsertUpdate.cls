@isTest
public class Test_Lead_BeforeInsertUpdate {
    @testsetup
    static void setup() {
        Account a1 = new Account();
        a1.Name = 'Mission Indonesia';
        insert a1;
        
        Account a2 = new Account();
        a2.Name = 'Mission Thailand';
        insert a2;
        
    }
    
    static testmethod void testInsertLeadNoCompany() {
        Lead newLead = new Lead();
        newLead.LastName = 'test_lastn';
        newLead.Email = 'test_lastn@mail.com';
        newLead.Region__c = 'WHA';
        newLead.Country__c = 'Brazil';
        newLead.LeadSource = 'Manual';
        newLead.Language__c = 'English';
        Test.startTest();
        insert newLead;  
        Test.stopTest();
        
        newLead = [SELECT id, company, Country, Country__c FROM Lead WHERE email = 'test_lastn@mail.com'];
        System.assert(newLead.Company != null);
    }
    
    static testmethod void testInsertLeadNoLeadSource() {
        Lead newLead = new Lead();
        newLead.LastName = 'test_lastn';
        newLead.Email = 'test_lastn@mail.com';
        newLead.Region__c = 'WHA';
        newLead.Country__c = 'Brazil';
        newLead.Company = 'Household';
        newLead.Language__c = 'English';
        Test.startTest();
        insert newLead;  
        Test.stopTest();
        
        newLead = [SELECT id, leadsource, country, Country__c FROM Lead WHERE email = 'test_lastn@mail.com'];
        System.assert(newLead.LeadSource != null);
        
    }   
    
    static testmethod void testLeadTriggerhandler() {
        Account ac = new Account();
        ac.name='Mission ' + 'United Kingdom';
        insert ac;
        
        Account ac1 = new Account();
        ac1.name='Mission ' + 'Austria';
        insert ac1;
        
        Contact ct = new Contact();
        ct.LastName='test';
        ct.AccountId = ac.id;
        ct.Email='test_lastn@mail.com';
        insert ct;
        
        Contact ct1 = new Contact();
        ct1.LastName='test1';
        ct1.AccountId = ac1.id;
        ct1.Email='test_lastn1@mail.com';
        insert ct1;
        
        /*Group grp = new Group();
        grp.Name = 'testGroup';
        grp.DeveloperName='Brazil';
        grp.type = 'Role';
        insert grp;*/

        Preference_Country__c objPrefCon = new Preference_Country__c();
        objPrefCon.Name = 'Austria';
        objPrefCon.Role__c = 'Mission_Austria';
        insert objPrefCon;
        String countryName = objPrefCon.Name;
        
        Preference__c objPref = new Preference__c();
        objPref.ContactName__c = ct.id;
        objPref.Country__c=countryName;
        insert objPref;
        
        List<Lead> lstlead = new List<Lead>();
        Lead newLead = new Lead();
        newLead.LastName = 'N.A';
        newLead.Email = 'test_email999@mail.com';
        newLead.Country__c = 'Austria';
        newLead.Mailing_Country__c = 'AT';
        newLead.Language__c = 'English';
        newLead.LeadSource = '';
        Test.startTest();
        lstlead.add(newLead);
        
        Lead newLead1 = new Lead();
        newLead1.Email = 'test_email998@mail.com';
        newLead1.Country__c = 'Austria';
        newLead.Mailing_Country__c = 'AT';
        newLead.Language__c = 'English';
        lstlead.add(newLead1);
        
        insert lstlead;  
        
        newLead = [SELECT Id, Status, HasOptedOutOfEmail, Country__c, Mailing_Country__c
                  FROM Lead
                  WHERE Email = 'test_email999@mail.com' LIMIT 1];
        
        newLead.Status=null;
        newLead.HasOptedOutOfEmail=false;
        newLead.Country__c = 'Germany';
        newLead.Mailing_Country__c = 'DE';
        update newLead;
        
        newLead1 = [SELECT Id, Status, HasOptedOutOfEmail, Country__c, Mailing_Country__c
                  FROM Lead
                  WHERE Email = 'test_email998@mail.com' LIMIT 1];
        
        newLead1.Status='Qualified';
        newLead1.Country__c = 'Germany';
        newLead.Mailing_Country__c = 'DE';
        update newLead1;
        
        Test.stopTest();
        
    } 
    
    static testmethod void testYSEALI_leadTriggerHandler() {
        Test.startTest();
        Lead l1 = new Lead();
        l1.FirstName = 'lead_f1';
        l1.LastName = 'lead_l1';
        l1.Email = 'f1.l1@mail.com';
        l1.Country__c = 'Indonesia';
        l1.Mailing_Country__c = 'ID';
        l1.Birthdate__c = Date.newInstance(1980, 01, 01);
        l1.Interests__c = 'Community Development;Education/Libraries';
        l1.Language__c = 'English';
        l1.LeadSource = 'YSEALI';
        
        Lead l2 = new Lead();
        l2.FirstName = 'lead_f2';
        l2.LastName = 'lead_l2';
        l2.Email = 'f2.l2@mail.com';
        l2.Country__c = 'Thailand';
        l2.Mailing_Country__c = 'TH';
        l2.Birthdate__c = Date.newInstance(1980, 02, 01);
        l2.Interests__c = 'Local Government;Environment/Climate;Education';
        l2.Language__c = 'English';
        l2.LeadSource = 'YSEALI';
        
        List<Lead> ysealiList = new List<Lead>();
        ysealiList.add(l1);
        ysealiList.add(l2);
        
        insert ysealiList;
        
        List<Lead> openLeads = [SELECT id, email, interests__c, status FROM Lead WHERE status = 'Open'];
        System.assert(openLeads.size() == 2);
        
        for(Lead oLead : openLeads) {
			String email = oLead.Email;
            List<String> interestParts = (oLead.Interests__c).split(';');
			if(email.equals('f1.l1@mail.com'))    
                System.assertEquals(2, interestParts.size());
            if(email.equals('f2.l2@mail.com'))
                System.assertEquals(3, interestParts.size());
            
        }
        
        for(Lead openLead : openLeads) {
            openLead.Status = 'Qualified';
        }
        
        upsert openLeads;
        test.stopTest();
        
        List<Lead> qualifiedLeads = [SELECT id, status FROM Lead WHERE status = 'Qualified'];
        System.assert(qualifiedLeads.size() == 2);

    }
}
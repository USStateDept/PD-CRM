@isTest
private class testMissionNameUpdate {

    @testsetup
    static void setup() {
        User u = [SELECT Id, ProfileId, UserRoleId FROM User WHERE Id = :UserInfo.getUserId()];
        
        User functionalUser = [SELECT id FROM User WHERE name like 'Integrator Functional%' Limit 1];
        List<UserRole> uRoles = [SELECT Id FROM UserRole WHERE Name like 'Mission%'];
        
        if(uRoles != null) {
            UserRole uRole = uRoles.get(0);
            List<Profile> uProfiles = [SELECT Id, Name FROM Profile WHERE Name = 'PD CRM'];
            if(uProfiles != null) {
				Profile p = uProfiles.get(0);	
                System.runAs(functionalUser) {
                    if(!u.ProfileId.equals(p.Id))
                    	u.ProfileId = p.Id;
                    if(!u.UserRoleId.equals(uRole.Id))
                    	u.UserRoleId = uRole.Id;
                    update u;
				}
            }
        }
        
        Account a = new Account();
        a.Name = 'Mission Cuba';
        insert a;
        
        Contact c = new Contact();
        c.FirstName = 'testFirst';
        c.LastName = 'testLast';
        c.MiddleName = 'testM';
        c.Title = 'test title;';
        c.Department = 'test department';
        c.Company_Name__c = 'test organization';
        c.Gender__c = 'Female';
        c.Spoken_Languages__c = 'Arabic;Spanish';
        c.Interests__c = 'Environment/Climate;Community Development';
        c.Email = 'testFL@mail.com';
        c.Phone = '1237997666';
        c.MobilePhone = '9872340987';
        c.MailingCountry = 'Aruba';
        c.MailingCountryCode = 'AW';
        c.MailingStreet = '123 street name';
        c.MailingCity = 'city name';
        c.MailingPostalCode = '12345';
        c.Citizenship__c = 'Cuba';
        c.AccountId = a.Id;
        insert c;

    }
    
    static testMethod void testMissionName(){
        
        //Account ac = new Account(Name = '00Et0000000LloH');
        //User usr = new User (id = '005t0000000SKzk');
        
        //1. set up an Account with Mission + <Country name>
        //2. set up an User with the role name matching with the account name in step 1
              
        Test.startTest();
        User currentUser = [SELECT Id FROM User WHERE userName = :UserInfo.getUserName()];
        List<Contact> newContacts = new List<Contact>();
        
        Contact c1 = new Contact(FirstName = 'froqete',LastName = 'roquette', Email = 'gro@soo.com', 
        Country__c = 'Togo', OwnerId = currentUser.Id);
		newContacts.add(c1);
        
        Contact c2 = new Contact(FirstName = 'froqete2',LastName = 'roquette2', Email = 'gro2@soo.com', 
        Country__c = 'Togo', OwnerId = currentUser.Id);
        newContacts.add(c2);
        
		ContactTriggerHandler handler = new ContactTriggerHandler();
        handler.onBeforeInsert(newContacts);
		insert newContacts;

        Test.stopTest();

        c1 = [SELECT Id, AccountId, LeadSource FROM Contact WHERE Email = 'gro@soo.com'];
        
        System.assert(c1 != null);
        System.assertEquals('Manual', c1.LeadSource);
	}
    
    static testmethod void testCreateContactWithEContact() {
        Test.startTest();
        List<Contact> newContacts = new List<Contact>();
        Contact c1 = new Contact(FirstName = 'froqete',LastName = 'roquette', Email = 'gro@soo.com', 
        Country__c = 'Togo', eContacts__Created_By_eContacts__c = true);
        newContacts.add(c1);
        
        ContactTriggerHandler handler = new ContactTriggerHandler();
        handler.onBeforeInsert(newContacts);
        
		insert newContacts;
        Test.stopTest();
        
        c1 = [SELECT Id, AccountId, LeadSource FROM Contact WHERE Email = 'gro@soo.com'];

        System.assertEquals('Card Scanner', c1.LeadSource);
    }
    
    static testmethod void testOnBeforeUpdate() {
        Test.startTest();
        User currentUser = [SELECT Id FROM User WHERE userName = :UserInfo.getUserName()];
        List<Contact> newContacts = new List<Contact>();
        Map<Id,Contact> newContactMap = new Map<Id,Contact>();
        Map<Id,Contact> oldContactMap = new Map<Id,Contact>();
        
        Contact c1 = new Contact(FirstName = 'froqete',LastName = 'roquette', Email = 'gro@soo.com', 
        Country__c = 'Togo', OwnerId = currentUser.Id);
		newContacts.add(c1);
        
        Contact c2 = new Contact(FirstName = 'froqete2',LastName = 'roquette2', Email = 'gro2@soo.com', 
        Country__c = 'Togo', OwnerId = currentUser.Id);
        newContacts.add(c2);
        
		insert newContacts;
       
		List<Contact> updatedContacts = new List<Contact>(); 
        c1 = [SELECT Id, AccountId, LeadSource FROM Contact WHERE Email = 'gro@soo.com'];
        newContactMap.put(c1.Id,c1);
        c1.Company_Name__c = 'ABC';
        updatedContacts.add(c1);
        oldContactMap.put(c1.Id,c1);
        
        c2 = [SELECT Id, AccountId, LeadSource FROM Contact WHERE Email = 'gro2@soo.com'];
        newContactMap.put(c2.Id,c2);
        c2.Citizenship__c = 'Philippines';
        updatedContacts.add(c2);
        oldContactMap.put(c2.Id,c2);
        
        ContactTriggerHandler handler = new ContactTriggerHandler();
        handler.onBeforeUpdate(newContacts, updatedContacts, newContactMap, oldContactMap);

        upsert updatedContacts;
        
        Test.stopTest();
        
        c1 = [SELECT Id, Company_Name__c FROM Contact WHERE Email = 'gro@soo.com'];
        c2 = [SELECT Id, Citizenship__c FROM Contact WHERE Email = 'gro2@soo.com'];
        
        System.assertEquals('ABC', c1.Company_Name__c);
        System.assertEquals('Philippines', c2.Citizenship__c);
    }
 }
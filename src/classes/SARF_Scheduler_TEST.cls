@isTest
public class SARF_Scheduler_TEST {
    
    static testmethod void testDeactivateUsers() {
        Test.startTest();
        PermissionSet ps = [SELECT ID From PermissionSet WHERE Label = 'SARF Manager'];
        User u3 = [SELECT Id FROM User WHERE name like 'Integrator Functional%' LIMIT 1];
        PermissionSetAssignment PSAssignment;
        
        List<PermissionSetAssignment> psaList = [SELECT Id,PermissionSetId FROM PermissionSetAssignment WHERE PermissionSetId = :ps.ID AND AssigneeId = :u3.id];
        if(psaList != null && psaList.size() > 0)
        {
        	PSAssignment = psaList.get(0);    
        }
        else
        {   
            PSAssignment = new PermissionSetAssignment(AssigneeId = u3.id, PermissionSetId = ps.ID );
            insert( PSAssignment );
        }
        
        //Create a new initial sarf
        CMS_SARF__c sarf = new CMS_SARF__c();
        sarf.last_name__c = 'LastName';
        sarf.first_Name__c = 'FirstName';
        sarf.email_address__c = 'test==test@test.com';
        sarf.Employee_Type__c = 'Contractor';
        sarf.role__c = 'CMS Support Services';
        sarf.profileTemp__c = 'System Administrator (mock)';
        sarf.permission_sets_default__c = 'CMS BasicCMS Incident Report CreatorEmbassy ViewerEnable SMS-based identity confirmationSYS Support';
        sarf.isPendingApproval__c = false;
        sarf.Expiration_Date__c = Date.today();
        sarf.current_time_tracker__c = Datetime.now();
        sarf.isApproved__c = true;
        sarf.Is_Current__c = true;
        sarf.User_Type__c = 'New User';
        System.runAs(u3) {
        	insert sarf;
        }
        
        //Set up a test account
		Account a = new Account();
        a.Name = 'TestAccount';
        System.runAs(u3) {
        	insert a;
        }
        
        //Create a contact and assign this contact to test account
        Contact c =  new Contact();
        c.AccountId = a.Id;
        c.FirstName = sarf.First_Name__c;
        c.LastName = sarf.Last_Name__c;
        c.Email = sarf.Email_Address__c;
        System.runAs(u3) {
            insert c;
        }
        
        List<Profile> pList = [SELECT Id FROM Profile WHERE Name = 'Overage Authenticated Website User'];
        String profileId = '';
        if(pList != null && pList.size() > 0) {
            Profile p = pList.get(0);
            profileId = p.Id;
        }
        
        //Create a portal user
        User u = createUser(c.Id, c.Email, c.FirstName, c.LastName, profileId, true);	
        
        //Update sarf
        if(u != null) {     
               if(u != null) {
                   sarf.User_Type__c = 'Existing User';
                   sarf.User_ID__c = u.Id;
                   sarf.User_Created__c = true;
                   sarf.User_Updated__c = true;
                   System.runAs(u3) {
                       update sarf;
                   }
               }
        }

        System.runAs(u3) {
       		SARF_Scheduler.deactivateUsers();   
        }
        Test.stopTest();
        List<User> inActiveUsers = [SELECT name, id, isActive FROM User WHERE id = :u.Id
                               AND isActive = false];
        System.assert(inActiveUsers != null);
    }
    /*
    static testmethod void testDeactivateSarfs()
    {
        Test.startTest();
        PermissionSet ps = [SELECT ID From PermissionSet WHERE Label = 'SARF Manager'];
        User u3 = [SELECT Id FROM User WHERE name like 'Integrator Functional%' LIMIT 1];
        PermissionSetAssignment PSAssignment;
        
        List<PermissionSetAssignment> psaList = [SELECT Id,PermissionSetId FROM PermissionSetAssignment WHERE PermissionSetId = :ps.ID AND AssigneeId = :u3.id];
        if(psaList != null && psaList.size() > 0)
        {
        	PSAssignment = psaList.get(0);    
        }
        else
        {   
            PSAssignment = new PermissionSetAssignment(AssigneeId = u3.id, PermissionSetId = ps.ID );
            insert( PSAssignment );
        }
        
        //Create a new initial sarf
        CMS_SARF__c sarf = new CMS_SARF__c();
        sarf.last_name__c = 'LastName';
        sarf.first_Name__c = 'FirstName';
        sarf.email_address__c = 'test==test@test.com';
        sarf.Employee_Type__c = 'Contractor';
        sarf.role__c = 'CMS Support Services';
        sarf.profileTemp__c = 'System Administrator (mock)';
        sarf.permission_sets_default__c = 'CMS BasicCMS Incident Report CreatorEmbassy ViewerEnable SMS-based identity confirmationSYS Support';
        sarf.isPendingApproval__c = false;
        sarf.Expiration_Date__c = Date.today();
        sarf.current_time_tracker__c = Datetime.now();
        sarf.isApproved__c = true;
        sarf.Is_Current__c = true;
        sarf.User_Type__c = 'New User';
        System.runAs(u3) {
        	insert sarf;
        }
                
        //Set up a test account
		Account a = new Account();
        a.Name = 'TestAccount';
        System.runAs(u3) {
        	insert a;
        }
        
        //Create a contact and assign this contact to test account
        Contact c =  new Contact();
        c.AccountId = a.Id;
        c.FirstName = sarf.First_Name__c;
        c.LastName = sarf.Last_Name__c;
        c.Email = sarf.Email_Address__c;
        System.runAs(u3) {
            insert c;
        }
        
        List<Profile> pList = [SELECT Id FROM Profile WHERE Name = 'Overage Authenticated Website User'];
        String profileId = '';
        if(pList != null && pList.size() > 0) {
            Profile p = pList.get(0);
            profileId = p.Id;
        }
        
        //Create a portal user
        User u = createUser(c.Id, c.Email, c.FirstName, c.LastName, profileId, false);	
        
        //Update sarf
        if(u != null) {     
            if(u != null) {
                sarf.User_Type__c = 'Existing User';
                sarf.User_ID__c = u.Id;
                sarf.User_Created__c = true;
                sarf.User_Updated__c = true;
                System.runAs(u3) {
                    update sarf;
                }
            }
        }
        
        System.runAs(u3) {
        	SARF_Scheduler.deactivateSarfs();
        }
        
        List<CMS_SARF__c> inActiveSarfs = [SELECT id, is_deactivated__c FROM CMS_SARF__c
                                          WHERE is_deactivated__c = true];
        System.assert(inActiveSarfs != null);

        Test.stopTest();
    }   
    */
    static testmethod void testExecute() {
        String CRON_EXP = '0 0 0 10 2 ? 2022';
        
        Test.startTest();
        String jobId = System.schedule('ScheduleApexClassTest',
                        CRON_EXP, 
                        new SARF_Scheduler());
        // Get the information from the CronTrigger API object
      	CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, 
                          NextFireTime
                          FROM CronTrigger WHERE id = :jobId];

        // Verify the expressions are the same
        System.assertEquals(CRON_EXP, 
                            ct.CronExpression);

        // Verify the job has not run
        System.assertEquals(0, ct.TimesTriggered);
        
      	// Verify the next time the job will run
      	System.assertEquals('2022-02-10 00:00:00', String.valueOf(ct.NextFireTime));
        // Verify the scheduled job hasn't run yet.
        List<CMS_SARF__c> expiredSarfsList = [SELECT User_ID__c, expiration_date__c, is_deactivated__c, is_current__c 
                                              	FROM CMS_SARF__C
												WHERE expiration_date__c = TODAY
                                            	AND is_deactivated__c = true
                                             	AND is_current__c = true];
        System.assertEquals(expiredSarfsList.size(), 0);
        Test.stopTest();
    }
    
    static User createUser(String contactId, String email, String firstName, String lastName, String profileId, Boolean isActive) {
        User u = new User();
        u.ContactId = contactId;
        u.email = email;
        u.firstName = firstName;
        u.lastName = lastName;
        u.profileId = profileId;
        u.emailencodingkey='UTF-8';
        u.languagelocalekey='en_US';
        u.localesidkey='en_US';
        u.timezonesidkey='America/Los_Angeles';
        u.title = 'TEST_USER';
        
         //Set unique values with random appended numbers
        SARF_unique_ID_Generator rc = new SARF_unique_ID_Generator();
        String[] splitList = email.split('@',0);
        String tempUN = splitList[0];  // first half
        String tempUN2 = splitList[1]; // second half
        if(tempUN != NULL){
            System.debug(tempUN);
            tempUN = rc.queryUsername(tempUN, tempUn2);
        }
        u.username = tempUn + '@' + tempUN2;
        //Need to create a method that checks for unique alias and modifies if necessary
        String temp = ''; // temp will get a standard value and then pass it to the alias generator for final unique alias creation
        if(u.lastname.length() > 4){
            temp = u.lastname.substring(0,4) + u.firstname.substring(0,1);
        }else{
            temp = u.lastname + u.firstname.substring(0,1);
        }
        
        temp = rc.queryAlias(temp);
        u.Alias = temp;
        u.IsActive = IsActive;
        insert u;
        
        return u;
    }
}
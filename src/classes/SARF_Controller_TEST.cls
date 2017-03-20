@isTest
public class SARF_Controller_TEST {
    // Test Controller object 
    static testmethod void testSARF_Controller(){
        CMS_SARF__c record = new CMS_SARF__c();
        ApexPages.StandardController sc = new ApexPages.StandardController( record );
        SARF_Controller testObj = new SARF_Controller(sc);
        
        System.assert(testObj.sarf.Version_Number__c == null);
    }
    
    // Test VF detail page for initial SARF save
    static testmethod void testSaveInitialSARF(){
        Test.startTest();
        User u3 = getSarfManager();
        CMS_SARF__c sarf = getNewSarf();

        ApexPages.StandardController sc = new ApexPages.standardController(sarf);
        SARF_Controller testObj = new SARF_Controller(sc);
        System.runAs(u3) {
            PageReference pageRef = testObj.saveInitialSARF();
        }
        Test.stopTest();

        System.assert(testObj.sarf.Id != null);
    }
    
    static testmethod void testSave(){
    //TEST CODE
        Test.startTest();

        User u3 = getSarfManager();        
        CMS_SARF__c sarf = getNewSarf();
        System.runAs(u3) {
            insert sarf;   
        }

        sarf.Role__c = 'CMS Manager';
        sarf.ProfileTemp__c = 'System Administrator';
        sarf.Permission_Sets_Default__c = 'CMS Project Manager CMS Incident Report Project Manager Reports Manager Embassy Manager Enable SMS-based identity confirmation';
        
        ApexPages.StandardController sc = new ApexPages.standardController(sarf);
        SARF_Controller testObj = new SARF_Controller(sc);
        System.runAs(u3) {
            PageReference pageRef = testObj.save();
        }
        
        Test.stopTest();
        
        System.assertEquals(testObj.sarf.Role__c, 'CMS Manager');
        
    }
    
    static testmethod void testEditSARF(){
    //TEST CODE
        Test.startTest();
        User u3 = getSarfManager();
        CMS_SARF__c sarf = getNewSarf();
        
        System.runAs(u3) {
            insert sarf;   
        }
        
        ApexPages.StandardController sc = new ApexPages.standardController(sarf);
        SARF_Controller testObj = new SARF_Controller(sc);
        PageReference pageRef = testObj.editSARF();
        Test.stopTest();

        System.assertEquals(testObj.isEdit, true); 
    }
    
    static testmethod void testCloneSARF(){
        Test.startTest();

        User u3 = getSarfManager();
        
        CMS_SARF__c sarf = getNewSarf();
        System.runAs(u3) {
            insert sarf;
        }
        
        Account amsAccount = new Account();
        amsAccount.Name = 'American Spaces';
        System.runAs(u3) {
            insert amsAccount;
        }

        Contact c =  new Contact();
        c.AccountId = amsAccount.Id;
        c.FirstName = sarf.First_Name__c;
        c.LastName = sarf.Last_Name__c;
        c.Email = sarf.Email_Address__c;
        System.runAs(u3) {
            insert c;
        }
        
        //Create a portal user
        User u = createUser(c.Id, c.Email, c.FirstName, c.LastName, getProfile(), true);    
        
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
        
        CMS_SARF__c cloneSarf = [SELECT id, version_number__c, Permission_Sets__c, Email_Address__c, SARF_User_ID__c, SARF_Name__c, Role__c 
                                 FROM CMS_SARF__c WHERE id = :sarf.id];
        
        ApexPages.StandardController sc = new ApexPages.standardController(cloneSarf);
        SARF_Controller testObj = new SARF_Controller(sc);

        PageReference pageRef = testObj.cloneSARF();
        Test.stopTest();

        System.assert(testObj.sarf != null);
    }
    
     static testmethod void testSaveNew(){
        Test.startTest();

        User u3 = getSarfManager();
        
        CMS_SARF__c sarf = getNewSarf();
        System.runAs(u3) {
            insert sarf;
        }
        
        Account amsAccount = new Account();
        amsAccount.Name = 'American Spaces';
        System.runAs(u3) {
            insert amsAccount;
        }

        Contact c =  getContact(amsAccount.id, sarf);
        System.runAs(u3) {
            insert c;
        }
         
        //Create a portal user
        User u = createUser(c.Id, c.Email, c.FirstName, c.LastName, getProfile(), true);    
        
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
        
        CMS_SARF__c cloneSarf = [SELECT id, version_number__c, Permission_Sets__c, permission_sets_default__c, Email_Address__c, 
                                 SARF_User_ID__c, User_ID__c, SARF_Name__c, Role__c, First_Name__c, user_type__c
                                 FROM CMS_SARF__c WHERE id = :sarf.id];
        cloneSarf.Role__c = 'CONX General Queue';
        cloneSarf.Permission_Sets_Default__c = 'CONX General Queue Reports Editor Enable SMS-based identity confirmation';
         
        System.runAs(u3) {
            ApexPages.StandardController sc = new ApexPages.standardController(cloneSarf);
            SARF_Controller testObj = new SARF_Controller(sc);
            PageReference pageRef = testObj.saveNew();
            System.assert(testObj.sarf2 != null);
         }
        Test.stopTest();
    }
    
    static testmethod void testRequestApproval(){
        Test.startTest();
        
        User u = getSarfManager();
        CMS_SARF__c sarf = getNewSarf();
        System.runAs(u) {
            insert sarf;   
        }
        
        ApexPages.StandardController sc = new ApexPages.standardController(sarf);
        SARF_Controller testObj = new SARF_Controller(sc);
        testObj.quickapprove = false;
        System.runAs(u) {
            PageReference pageRef = testObj.requestApproval();   
        }       
        
        Test.stopTest();

        System.assertEquals(testObj.sarf.isPendingApproval__c, true);
    }

    static testmethod void testApprove() {
        Test.startTest();
        
        User managerUser = getSarfManager();
        
        CMS_SARF__c sarf = getNewSarf();
        sarf.isPendingApproval__c = true;
        sarf.Date_Submitted__c = DateTime.now();
        sarf.ownerId = UserInfo.getUserId();
        
        System.runAs(managerUser) {
            insert sarf;
        }
       
        setApprovingManager(managerUser, sarf.Role__c);
        
        ApexPages.StandardController sc = new ApexPages.standardController(sarf);
        SARF_Controller testObj = new SARF_Controller(sc);
        System.runAs(managerUser) {
            PageReference pageRef = testObj.approve();
        }
        
        Test.stopTest();
        
        System.assertEquals(testObj.sarf.isApproved__c, true);
    }
    
    static testmethod void testSubmitAndApprove() {
        Test.startTest();
        User managerUser = getSarfManager();
        CMS_SARF__c sarf = getNewSarf();
        System.runAs(managerUser) {
            insert sarf;
        }
        
        setApprovingManager(managerUser, sarf.Role__c);
        
        ApexPages.StandardController sc = new ApexPages.standardController(sarf);
        SARF_Controller testObj = new SARF_Controller(sc);
        System.runAs(managerUser) {
            PageReference pageRef = testObj.submitAndApprove();
        }
        
        Test.stopTest();
        
        System.assertEquals(testObj.sarf.isApproved__c, true);
        System.assertEquals(testObj.sarf.isPendingApproval__c, false);
    }
    
    static testmethod void testValidate() {
        Test.startTest();
        User managerUser = getSarfManager();
        
        CMS_SARF__c sarf = getNewSarf();
        System.runAs(managerUser) {
            insert sarf;
        }
        
        Account amsAccount = new Account();
        amsAccount.Name = 'American Spaces';
        System.runAs(managerUser) {
            insert amsAccount;
        }

        Contact c = getContact(amsAccount.Id, sarf);
        System.runAs(managerUser) {
            insert c;
        }
       
        //Create a portal user
        User u = createUser(c.Id, c.Email, c.FirstName, c.LastName, getProfile(), true);    
        
        //Update sarf
        if(u != null) {     
            if(u != null) {
                sarf.User_Type__c = 'Existing User';
                sarf.User_ID__c = u.Id;
                sarf.User_Created__c = true;
                sarf.User_Updated__c = true;
                System.runAs(managerUser) {
                    update sarf;
                }
            }
        }
        
        ApexPages.StandardController sc = new ApexPages.standardController(sarf);
        SARF_Controller testObj = new SARF_Controller(sc);
        System.runAs(managerUser) {
            PageReference pageRef = testObj.validate();
        }
        
        Test.stopTest();
        
        System.assert(testObj.sarf.Current_Time_Tracker__c != null);
    }
    
    static testmethod void testDeactivateUser() {
        Test.startTest();
        User managerUser = getSarfManager();
        
        CMS_SARF__c sarf = getNewSarf();
        System.runAs(managerUser) {
            insert sarf;
        }
        
        Account amsAccount = new Account();
        amsAccount.Name = 'American Spaces';
        System.runAs(managerUser) {
            insert amsAccount;
        }

        Contact c = getContact(amsAccount.Id, sarf);
        System.runAs(managerUser) {
            insert c;
        }
       
        //Create a portal user
        User u = createUser(c.Id, c.Email, c.FirstName, c.LastName, getProfile(), true);    
        
        //Update sarf
        if(u != null) {     
            if(u != null) {
                sarf.User_Type__c = 'Existing User';
                sarf.User_ID__c = u.Id;
                sarf.User_Created__c = true;
                sarf.User_Updated__c = true;
                System.runAs(managerUser) {
                    update sarf;
                }
            }
        }
        
        ApexPages.StandardController sc = new ApexPages.standardController(sarf);
        SARF_Controller testObj = new SARF_Controller(sc);
        System.runAs(managerUser) {
            PageReference pageRef = testObj.deactivateUser();            
        }
        
        Test.stopTest();
        
        System.assertEquals(testObj.sarf.Is_Deactivated__c, false);
    }
    
    static testmethod void testConfirmDeactivation() {
        Test.startTest();
        User managerUser = getSarfManager();
        
        CMS_SARF__c sarf = getNewSarf();
        System.runAs(managerUser) {
            insert sarf;   
        }
        
        Account amsAccount = new Account();
        amsAccount.Name = 'American Spaces';
        System.runAs(managerUser) {
            insert amsAccount;
        }

        Contact c = getContact(amsAccount.Id, sarf);
        System.runAs(managerUser) {
            insert c;
        }
       
        //Create a portal user
        User u = createUser(c.Id, c.Email, c.FirstName, c.LastName, getProfile(), true);    
        
        //Update sarf
        if(u != null) {     
            if(u != null) {
                sarf.User_Type__c = 'Existing User';
                sarf.User_ID__c = u.Id;
                sarf.User_Created__c = true;
                sarf.User_Updated__c = true;
                System.runAs(managerUser) {
                    update sarf;
                }
            }
        } 
        
        ApexPages.StandardController sc = new ApexPages.standardController(sarf);
        SARF_Controller testObj = new SARF_Controller(sc);
        System.runAs(managerUser) {
            PageReference pageRef = testObj.confirmDeactivation();
        }
        
        Test.stopTest();
        
        System.assertEquals(testObj.sarf.Is_Deactivated__c, true);
    }
    
    static testmethod void testCancelDeactivation() {
        Test.startTest();
        User managerUser = getSarfManager();
        
        CMS_SARF__c sarf = getNewSarf();
        System.runAs(managerUser) {
            insert sarf;
        }
        
        Account amsAccount = new Account();
        amsAccount.Name = 'American Spaces';
        System.runAs(managerUser) {
            insert amsAccount;
        }

        Contact c = getContact(amsAccount.Id, sarf);
        System.runAs(managerUser) {
            insert c;
        }
       
        //Create a portal user
        User u = createUser(c.Id, c.Email, c.FirstName, c.LastName, getProfile(), true);    
        
        //Update sarf
        if(u != null) {     
            if(u != null) {
                sarf.User_Type__c = 'Existing User';
                sarf.User_ID__c = u.Id;
                sarf.User_Created__c = true;
                sarf.User_Updated__c = true;
                System.runAs(managerUser) {
                    update sarf;
                }
            }
        } 
        
        ApexPages.StandardController sc = new ApexPages.standardController(sarf);
        SARF_Controller testObj = new SARF_Controller(sc);
        System.runAs(managerUser) {
            PageReference pageRef = testObj.cancelDeactivation();
        }
        
        Test.stopTest();
        
        System.assertEquals(testObj.sarf.Is_Deactivated__c, false);
    }
    
    static testmethod void testReject() {
        Test.startTest();
        
        User u = getSarfManager();
        CMS_SARF__c sarf = getNewSarf();
        sarf.is_rejected__c = false;
        System.runAs(u) {
            insert sarf;
        }
        
        ApexPages.StandardController sc = new ApexPages.standardController(sarf);
        SARF_Controller testObj = new SARF_Controller(sc);
        System.runAs(u) {
            PageReference pageRef = testObj.reject();
        }
        
        Test.stopTest();
        
        System.assertEquals(testObj.sarf.is_rejected__c, true);
    }
    
    static testmethod void testAddRejectionComments() {
        Test.startTest();
        
        User u3 = getSarfManager();
        
        CMS_SARF__c sarf = getNewSarf();
        sarf.is_rejected__c = false;
        
        System.runAs(u3) {
            insert sarf;
        }
        
        sarf.SARF_Rejection_Comments__c = 'test';
        
        ApexPages.StandardController sc = new ApexPages.standardController(sarf);
        SARF_Controller testObj = new SARF_Controller(sc);
        System.runAs(u3) {
            PageReference pageRef = testObj.addRejectionComments();
        }
        
        Test.stopTest();
        
        System.assertEquals(testObj.sarf.SARF_Rejection_Comments__c, 'test');
    }
    
    static testmethod void testCancelRejection() {
        Test.startTest();
        
        User u = getSarfManager();
        CMS_SARF__c sarf = getNewSarf();
        sarf.is_rejected__c = false;
        System.runAs(u) {
            insert sarf;
        }
        
        ApexPages.StandardController sc = new ApexPages.standardController(sarf);
        SARF_Controller testObj = new SARF_Controller(sc);
        System.runAs(u) {
            PageReference pageRef = testObj.cancelRejection();
        }
        
        Test.stopTest();
        
        System.assertEquals(testObj.sarf.is_rejected__c, false);
    } 
    
    static testmethod void testApplyUpdatedAccess() {
        Test.startTest();

        User managerUser = getSarfManager();
        
        CMS_SARF__c sarf = getNewSarf();
        System.runAs(managerUser) {
            insert sarf;
        }

        sarf = [SELECT id, Role__c, profileTemp__c, permission_sets_default__c, email_address__c, last_name__c,
                first_name__c, title__c, Version_Number__c, Permission_Sets__c, SARF_User_ID__c, user_type__c,
                User_ID__c, is_deactivated__c, phone_number__c
                FROM CMS_SARF__c WHERE id = :sarf.id];
        
        ApexPages.StandardController sc = new ApexPages.standardController(sarf);
        SARF_Controller testObj = new SARF_Controller(sc);
        System.runAs(managerUser) {
            PageReference pageRef = testObj.createUser();  
            pageRef = testObj.confirmUser();
            sarf = testObj.sarf;
        }
        
        sarf.Role__c = 'CMS Manager';
        sarf.profileTemp__c = 'System Administrator';
        sarf.permission_sets_default__c = 'CMS Project Manager\nCMS Incident Report Project Manager\nReports Manager\nEmbassy Manager\nEnable SMS-based identity confirmation';

        System.runAs(managerUser) {
            update sarf;
        }
        
        sarf = [SELECT id, Role__c, profileTemp__c, permission_sets_default__c, email_address__c, last_name__c,
                first_name__c, title__c, Version_Number__c, Permission_Sets__c, SARF_User_ID__c, user_type__c,
                User_ID__c, is_deactivated__c, phone_number__c
                FROM CMS_SARF__c WHERE id = :sarf.id];
        
        sc = new ApexPages.standardController(sarf);
        testObj = new SARF_Controller(sc);
        
        System.runAs(managerUser) {
            PageReference pageRef = testObj.applyUpdatedAccess();         
        }
        
        Test.stopTest();
    }
    
    static testmethod void testCreateUser() {
        Test.startTest();
        
        User managerUser = getSarfManager();        
        CMS_SARF__c sarf = getNewSarf();
        System.runAs(managerUser) {
            insert sarf;
        }
        
        sarf = [SELECT id, Role__c, profileTemp__c, permission_sets_default__c, email_address__c, last_name__c,
                first_name__c, title__c, Version_Number__c, Permission_Sets__c, SARF_User_ID__c, user_type__c
                FROM CMS_SARF__c WHERE id = :sarf.id];
        
        SARF_Controller testObj;
        System.runAs(managerUser) {
            ApexPages.StandardController sc = new ApexPages.standardController(sarf);
            testObj = new SARF_Controller(sc);
            PageReference pageRef = testObj.createUser();
        }
        
        Test.stopTest();
        
        System.assertEquals(testObj.userCreatedPushed, true);
    }
    
    static testmethod void testCreatePortalUser() {
        Test.startTest();
        
        User managerUser = getSarfManager();
        CMS_SARF__c sarf = getNewAmsSarf();
        System.runAs(managerUser) {
            insert sarf;
        }
        
        Account amsAccount = new Account();
        amsAccount.Name = 'American Spaces';
        System.runAs(managerUser) {
            insert amsAccount;
        }
        
        Id profileId = getProfile();
        
        System.runAs(managerUser) {
            ApexPages.StandardController sc = new ApexPages.standardController(sarf);
            SARF_Controller testObj = new SARF_Controller(sc);
            testObj.accountId = amsAccount.Id;
            testObj.profileID = profileId;
            PageReference pageRef = testObj.createPortalUser();
        }
        
        Test.stopTest();
    }
    
    static testmethod void testConfirmUser() {
        Test.startTest();

        User u2 = getSarfManager();
        
        CMS_SARF__c sarf = getNewSarf();
        System.runAs(u2) {
            insert sarf;
        }        
        
        sarf = [SELECT id, Role__c, profileTemp__c, permission_sets_default__c, email_address__c, last_name__c,
                first_name__c, title__c, Version_Number__c, Permission_Sets__c, SARF_User_ID__c, user_type__c
                FROM CMS_SARF__c WHERE id = :sarf.id];
                
        System.runAs(u2) {
            ApexPages.StandardController sc = new ApexPages.standardController(sarf);
            SARF_Controller testObj = new SARF_Controller(sc);
            PageReference pageRef = testObj.createUser();
            pageRef = testObj.confirmUser();
            System.assertEquals(testObj.sarf.User_Created__c, true);
        }
        
        Test.stopTest();
    }
    
    static testmethod void testConfirmAmsUser() {
        Test.startTest();

        User managerUser = getSarfManager();
        
        CMS_SARF__c sarf = getNewAmsSarf();
        System.runAs(managerUser) {
            insert sarf;
        }        
       
        Account amsAccount = new Account();
        amsAccount.Name = 'American Spaces';
        System.runAs(managerUser) {
            insert amsAccount;
        }  
  
        Contact c = getContact(amsAccount.Id, sarf);
        System.runAs(managerUser) {
            insert c;
        }
       
        //Create a user
        User u = createUser(c.Id, c.Email, c.FirstName, c.LastName, getProfile(), true); 
        u = setPermissionSet(u, sarf.Permission_Sets_Default__c);
        System.runAs(managerUser) {
            update u;
        }

        /*
        sarf = [SELECT id, Role__c, profileTemp__c, permission_sets_default__c, email_address__c, last_name__c,
                first_name__c, title__c, Version_Number__c, Permission_Sets__c, SARF_User_ID__c, user_type__c,
                contact_created__c
                FROM CMS_SARF__c WHERE id = :sarf.id];
		*/
        System.runAs(managerUser) {
            /*
            ApexPages.StandardController sc = new ApexPages.standardController(sarf);
            SARF_Controller testObj = new SARF_Controller(sc);
            testObj.accountId = amsAccount.Id;
            testObj.profileID = getProfile();
            PageReference pageRef = testObj.createPortalUser();
            */
			SARF_Controller.confirmPortalUser(sarf.Id);
        }
        
        Test.stopTest();
        
    }
    
     static testmethod void testConfirmExistingUser() {
        Test.startTest();

        User managerUser = getSarfManager();
        
        CMS_SARF__c sarf = getNewSarf();
         System.runAs(managerUser) {
             insert sarf;
         }
         
        sarf = [SELECT id, Role__c, profileTemp__c, permission_sets_default__c, email_address__c, last_name__c,
                first_name__c, title__c, Version_Number__c, Permission_Sets__c, SARF_User_ID__c, user_type__c
                FROM CMS_SARF__c WHERE id = :sarf.id];
         
        System.runAs(managerUser) {
            ApexPages.StandardController sc = new ApexPages.standardController(sarf);
            SARF_Controller testObj = new SARF_Controller(sc);
            testObj.createUser();  
            PageReference pageRef = testObj.confirmUser();
            
            sarf = testObj.sarf;
            sarf.Email_Address__c = 'test2@test.mail';
            sarf.Role__c = 'CONX Producer';
            sarf.ProfileTemp__c = 'IIP User';
            sarf.Permission_Sets_Default__c = 'CONX Producer\nReports Editor\nEnable SMS-based identity confirmation';
            sc = new ApexPages.standardController(sarf);
            testObj = new SARF_Controller(sc);
            pageRef = testObj.confirmUser();
            
            System.assertEquals(testObj.sarf.User_Updated__c, true);
        }   
        
        Test.stopTest();
    }  
    
     static testmethod void testConfirmExistingAmsUser() {
        Test.startTest();

        User managerUser = getSarfManager();
        
        CMS_SARF__c sarf = getNewAmsSarf();
         System.runAs(managerUser) {
            insert sarf;
         }
        
        Account amsAccount = new Account();
        amsAccount.Name = 'American Spaces';
        System.runAs(managerUser) {
            insert amsAccount;
        }

        Contact c = getContact(amsAccount.Id, sarf);
        System.runAs(managerUser) {
            insert c;
        }
       
        //Create a user
        User u = createUser(c.Id, c.Email, c.FirstName, c.LastName, getProfile(), true);    

        //Update sarf
        if(u != null) {     
            if(u != null) {
                sarf.User_Type__c = 'Existing User';
                sarf.User_ID__c = u.Id;
                sarf.User_Created__c = true;
                sarf.User_Updated__c = false;
                System.runAs(managerUser) {
                    update sarf;
                }
            }
        } 
         
        sarf = [SELECT id, Role__c, profileTemp__c, permission_sets_default__c, email_address__c, last_name__c,
                first_name__c, title__c, Version_Number__c, Permission_Sets__c, SARF_User_ID__c, user_type__c,
                User_Updated__c
                FROM CMS_SARF__c WHERE id = :sarf.id];
         
        ApexPages.StandardController sc = new ApexPages.standardController(sarf);
        SARF_Controller testObj = new SARF_Controller(sc);

        System.runAs(managerUser) {
             SARF_Controller.confirmPortalUser(testObj.sarf.Id);
        }
        
        Test.stopTest();
    }  
    
    static testmethod void testFilterUsers() {
        Test.startTest();

        User managerUser = getSarfManager();
        
        CMS_SARF__c sarf = getNewSarf();
        System.runAs(managerUser) {
            insert sarf;
        }
        
        Account amsAccount = new Account();
        amsAccount.Name = 'American Spaces';
        System.runAs(managerUser) {
            insert amsAccount;
        }

        Contact c = getContact(amsAccount.Id, sarf);
        System.runAs(managerUser) {
            insert c;
        }
       
        //Create a user
        User u = createUser(c.Id, c.Email, c.FirstName, c.LastName, getProfile(), true); 
        
        ApexPages.StandardController sc = new ApexPages.standardController(sarf);
        SARF_Controller testObj = new SARF_Controller(sc);
        testObj.searchUFN = 'SarfTest';
        testObj.searchULN = 'LastName';
        
        testObj.filterUsers();
        
        Test.stopTest();
        
        System.assertEquals(testObj.existingUsers.size(), 1);
    }
    
    static testmethod void testClearUserFilter() {
        Test.startTest();
        
        ApexPages.StandardController sc = new ApexPages.standardController(new CMS_SARF__c());
        SARF_Controller testObj = new SARF_Controller(sc);     
        
        testObj.clearUserFilter();
        
        System.assert(String.isEmpty(testObj.searchUFN));
        System.assert(String.isEmpty(testObj.searchULN));
        System.assertEquals(testObj.userFilter, false);
        
        Test.stopTest();
    }
    
    static testmethod void testPopulate() {
        Test.startTest();

        User managerUser = getSarfManager();
        
        CMS_SARF__c sarf = getNewSarf();
        System.runAs(managerUser) {
            insert sarf;
        }
        
        Account amsAccount = new Account();
        amsAccount.Name = 'American Spaces';
        System.runAs(managerUser) {
            insert amsAccount;
        }

        Contact c = getContact(amsAccount.Id, sarf);
        System.runAs(managerUser) {
            insert c;
        }
       
        //Create a user
        User u = createUser(c.Id, c.Email, c.FirstName, c.LastName, getProfile(), true);     
        
        ApexPages.StandardController sc = new ApexPages.standardController(new CMS_SARF__c());
        SARF_Controller testObj = new SARF_Controller(sc);
        testObj.userid = u.Id;
        PageReference pageRef = testObj.populate();
        
        Test.stopTest();
        
        System.assertEquals(testObj.existingUsers.size(), 1);
        System.assertEquals(testObj.sarf.First_Name__c, 'SarfTest');
    }
    
    static testmethod void testHasNewVersion() {
        Test.startTest();

        User managerUser = getSarfManager();
        
        CMS_SARF__c sarf = getNewSarf();
        System.runAs(managerUser) {
            insert sarf;
        }
        
        Account amsAccount = new Account();
        amsAccount.Name = 'American Spaces';
        System.runAs(managerUser) {
            insert amsAccount;
        }
        
        Contact c = getContact(amsAccount.Id, sarf);
        System.runAs(managerUser) {
            insert c;
        }
        
        //Create a user
        User u = createUser(c.Id, c.Email, c.FirstName, c.LastName, getProfile(), true);     
        
        //Update sarf
        if(u != null) {     
            if(u != null) {
                sarf.User_Type__c = 'Existing User';
                sarf.User_ID__c = u.Id;
                sarf.User_Created__c = true;
                sarf.User_Updated__c = true;
                sarf.Is_Current__c = true;
                sarf.Version_Number__c = 1;
                System.runAs(managerUser) {
                    update sarf;
                }
            }
        } 
        
        sarf = [SELECT id, Role__c, profileTemp__c, permission_sets_default__c, email_address__c, last_name__c,
                first_name__c, title__c, Version_Number__c, Permission_Sets__c, SARF_User_ID__c, user_type__c,
                isApproved__c
                FROM CMS_SARF__c WHERE id = :sarf.id];
        
        ApexPages.StandardController sc = new ApexPages.standardController(sarf);
        SARF_Controller testObj = new SARF_Controller(sc);
        
        System.assertEquals(testObj.hasNewVersion(), false);
        
        Test.stopTest();
    }

    static testmethod void testSelectClick() {
        Test.startTest();
        
        CMS_SARF__c sarf = new CMS_SARF__c();
        ApexPages.StandardController sc = new ApexPages.standardController(sarf);
        SARF_Controller testObj = new SARF_Controller(sc);
        
        List<String> leftSelectedValues = new List<String>();
        leftSelectedValues.add('CONX Project Coordinator');
        leftSelectedValues.add('CONX General Queue');
        testObj.leftselected = leftSelectedValues;
        testObj.rightvalues = new Set<String>();
        testObj.rightselected = new List<String>();
        
        PageReference pageRef = testObj.selectclick();
        
        Test.stopTest();
        
        System.assertEquals(testObj.rightvalues.size(), 2);
    }  
    
    static testmethod void testUnselectClick() {
        Test.startTest();
        
        CMS_SARF__c sarf = new CMS_SARF__c();
        ApexPages.StandardController sc = new ApexPages.standardController(sarf);
        SARF_Controller testObj = new SARF_Controller(sc);
        
        List<String> rightSelectedValues = new List<String>();
        rightSelectedValues.add('CONX Project Coordinator');
        rightSelectedValues.add('CONX General Queue');
        testObj.rightselected = rightSelectedValues;
        testObj.leftvalues = new Set<String>();
        testObj.leftselected = new List<String>();
        
        PageReference pageRef = testObj.unselectclick();
        
        Test.stopTest();
        
        System.assertEquals(testObj.rightvalues.size(), 0);        
    }
    
    static testmethod void testGetunSelectedValues() {
        Test.startTest();
        
        ApexPages.StandardController sc = new ApexPages.standardController(new CMS_SARF__c());
        SARF_Controller testObj = new SARF_Controller(sc);
        List<SelectOption> unselectedValues = testObj.getunSelectedValues();
        
        System.assert(testObj.rightvalues.size() == 0);
        
        Test.stopTest();
    }
    
    static testmethod void testGetSelectedValues() {
        Test.startTest();
        
        ApexPages.StandardController sc = new ApexPages.standardController(new CMS_SARF__c());
        SARF_Controller testObj = new SARF_Controller(sc);
        
        Set<String> rightValues = new Set<String>();
        rightValues.add('CONX Project Coordinator Approver');
        testObj.rightvalues = rightvalues;
        
        List<SelectOption> selectedValues = testObj.getSelectedValues();
        
        System.assertEquals(selectedValues.size(), 1);
        
        Test.stopTest();
    }
    
    static testmethod void testGetRoles() {
        Test.startTest();
        
        CMS_SARF__c sarf = getNewSarf();
        User sarfManager = getSarfManager();
        
        setApprovingManager(sarfManager, sarf.Role__c);
        
        ApexPages.StandardController sc = new ApexPages.standardController(sarf);
        SARF_Controller testObj = new SARF_Controller(sc);
        
        List<SelectOption> rolesOptions = testObj.getRolesList();
            
        System.assert(rolesOptions.size() > 0);
    
        Test.stopTest();
    }

    static testmethod void testShowAccess() {
        Test.startTest();
        
        CMS_SARF__c sarf = getNewAmsSarf();
        sarf.Role__c = 'CONX Producer';
        sarf.ProfileTemp__c = 'IIP User';
        sarf.Permission_Sets_Default__c = 'CONX Producer\nReports Editor\nEnable SMS-based identity confirmation';
        
        ApexPages.StandardController sc = new ApexPages.standardController(sarf);
        SARF_Controller testObj = new SARF_Controller(sc);
        testObj.leftvalues = new Set<String>();
        testObj.showAccess();
        
        Set<String> leftValues = testObj.leftvalues;
        System.assert(!leftValues.contains('CONX Producer'));

        Test.stopTest();
    }   
    
    static testmethod void testHideAccess() {
        Test.startTest();
        
        ApexPages.StandardController sc = new ApexPages.standardController(new CMS_SARF__c());
        SARF_Controller testObj = new SARF_Controller(sc);
        testObj.hideAccess();
        
        System.assertEquals(testObj.rightvalues.size(), 0);
        
        Test.stopTest();
    }
    
    /**********************************************************************
     * HELPERS METHODS
     **********************************************************************/    
    
    static CMS_SARF__c getNewSarf() {
        CMS_SARF__c sarf = new CMS_SARF__c();
        sarf.last_name__c = 'LastName';
        sarf.first_Name__c = 'SarfTest';
        sarf.email_address__c = 'sarftest@test.com';
        sarf.Employee_Type__c = 'Contractor';
        sarf.role__c = 'CMS Team';
        sarf.profileTemp__c = 'CMS User';
        sarf.permission_sets_default__c = 'CMS Basic\nCMS Report View\nEnable_SMS_based_identity_confirmation';
        sarf.isPendingApproval__c = false;
        sarf.isApproved__c = false;
        sarf.Is_Current__c = false;
        sarf.User_Type__c = 'New User';   
        return sarf;
    }
    
    static CMS_SARF__c getNewAmsSarf() {
        CMS_SARF__c sarf = new CMS_SARF__c();
        sarf.last_name__c = 'LastName';
        sarf.first_Name__c = 'AMSTest';
        sarf.email_address__c = 'amstest@test.com';
        sarf.Employee_Type__c = 'Contractor';
        sarf.role__c = 'American Spaces Site.com';
        sarf.profileTemp__c = 'Overage Authenticated Website user';
        sarf.permission_sets_default__c = 'American Spaces Washington_SITECOM';
        sarf.isPendingApproval__c = false;
        sarf.isApproved__c = false;
        sarf.Is_Current__c = false;
        sarf.User_Type__c = 'New User';   
        return sarf;        
    }
    
    static User getSarfManager() {
        PermissionSet ps = [SELECT ID From PermissionSet WHERE Label = 'SARF Manager'];
        User u3 = [SELECT Id FROM User WHERE name like :UserInfo.getName() LIMIT 1];
        PermissionSetAssignment PSAssignment;
        
        List<PermissionSetAssignment> psaList = [SELECT Id,PermissionSetId FROM PermissionSetAssignment WHERE PermissionSetId = :ps.ID AND AssigneeId = :u3.id];
        if(psaList != null && psaList.size() > 0)
        {
            PSAssignment = psaList.get(0);    
        }
        else
        {   
            PSAssignment = new PermissionSetAssignment(AssigneeId = u3.id, PermissionSetId = ps.ID );
            System.runAs(u3) {
                insert( PSAssignment );
            }
        }
        
        return u3;
    }
    
    static void setApprovingManager(User u, String approvingRole) {
        PermissionSetAssignment PSAssignment = null;
        
        if(String.isNotEmpty(approvingRole)) {
            approvingRole = approvingRole.replaceAll('_', ' ');
            approvingRole += ' Approver';
        }

        PermissionSet ps = [SELECT ID From PermissionSet WHERE Label = :approvingRole];
        try {
            PSAssignment = [SELECT Id,PermissionSetId FROM PermissionSetAssignment WHERE PermissionSetId = :ps.ID AND AssigneeId = :u.id];
        } catch(Exception e) {
            PSAssignment = new PermissionSetAssignment(AssigneeId = u.id, PermissionSetId = ps.ID );
            System.runAs(u) {
                insert( PSAssignment );
            }
        }
    }
    
    static User setPermissionSet(User currentUser, String permissionLabel) {
        PermissionSet ps = [SELECT ID From PermissionSet WHERE Label = :permissionLabel];
        User u3 = [SELECT id FROM User WHERE name like 'Integrator Functional%' Limit 1];
        PermissionSetAssignment PSAssignment;
        
        List<PermissionSetAssignment> psaList = [SELECT Id,PermissionSetId FROM PermissionSetAssignment WHERE PermissionSetId = :ps.ID AND AssigneeId = :currentUser.id];
        if(psaList != null && psaList.size() > 0)
        {
            PSAssignment = psaList.get(0);    
        }
        else
        {   
            PSAssignment = new PermissionSetAssignment(AssigneeId = currentUser.id, PermissionSetId = ps.ID );
            System.runAs(u3) {
                insert( PSAssignment );
            }
        }
        return u3;
    }
    
    static Contact getContact(Id accountId, CMS_SARF__c sarf) {
        Contact c =  new Contact();
        c.AccountId = accountId;
        c.FirstName = sarf.First_Name__c;
        c.LastName = sarf.Last_Name__c;
        c.Email = sarf.Email_Address__c;
        return c;
    }
    
    static Id getProfile() {
        try {
            return [SELECT Id FROM Profile WHERE Name = 'Overage Authenticated Website User' LIMIT 1].id;
        } catch(Exception e) {
            System.debug('Exception is caught '+e.getMessage());
        }

        return null;
    }
    
    static User createUser(Id contactId, String email, String firstName, String lastName, String profileId, Boolean isActive) {
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
@isTest
public class SARF_EmailHandler_TEST {

    static testmethod void testSendEmail() {
        Test.startTest();
        User managerUser = getSarfManager();
        CMS_SARF__c sarf = getNewSarf();
        sarf.Manager__c = managerUser.Id;
        System.runAs(managerUser) {
        	insert sarf;
        }
        
        setApprovingManager(managerUser, sarf.Role__c);
        
        SARF_EmailHandler emailHandler = new SARF_EmailHandler(sarf, 'https:\\iipstate.my.salesforce.com');
        emailHandler.sendEmail();
        
        Test.stopTest();
    }
    
    /**********************************************************************
     * HELPERS METHODS
     **********************************************************************/    
    
    static CMS_SARF__c getNewSarf() {
        CMS_SARF__c sarf = new CMS_SARF__c();
        sarf.last_name__c = 'LastName';
        sarf.first_Name__c = 'FirstName';
        sarf.email_address__c = 'test==test@test.com';
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
}
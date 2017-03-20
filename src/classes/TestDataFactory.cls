@isTest
public class TestDataFactory {
    /*
     * Set permission set to current user
     */ 
    public static void setPermissionSet(User currentUser, String permissionLabel) {
        PermissionSet ps = [SELECT ID From PermissionSet WHERE Label = :permissionLabel];
        User u3 = [SELECT id FROM User WHERE name like 'Integrator Functional%' Limit 1];
        PermissionSetAssignment PSAssignment;
        
        List<PermissionSetAssignment> psaList = [SELECT Id,PermissionSetId FROM PermissionSetAssignment WHERE PermissionSetId = :ps.ID AND AssigneeId = :currentUser.id];
        if(psaList != null && psaList.size() == 0)
        {   
            PSAssignment = new PermissionSetAssignment(AssigneeId = currentUser.id, PermissionSetId = ps.ID );
            System.runAs(u3) {
                insert( PSAssignment );
            }
        }
    }
}
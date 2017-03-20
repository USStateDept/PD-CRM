public with sharing class CONX_Access
{
	public static String getPermissionset( String userName )
	{
		String permissionName;
        try
        {
	        permissionName = [SELECT PermissionSet.Label
	    	                    FROM PermissionSetAssignment
	                           WHERE PermissionSet.IsOwnedByProfile = FALSE
	                             AND PermissionSetId
	                	          IN (SELECT ParentId FROM ObjectPermissions WHERE SObjectType = 'CONX_Program_Request__c')
	                             AND Assignee.Name = :userName LIMIT 1].PermissionSet.Label;
        }
        catch (Exception e)
        {
        	permissionName = '';
        }
        
        return permissionName;
	}
	
	
	public static testMethod void testCONX_Access()
    {             
        Test.startTest();
        
        User u3 = [SELECT Id, userName FROM User WHERE name like 'Integrator Functional%' LIMIT 1];
    	CONX_Access.getPermissionset( u3.userName );
    }
}
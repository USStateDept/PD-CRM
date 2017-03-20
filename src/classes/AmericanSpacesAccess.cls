public with sharing class AmericanSpacesAccess
{
	public static boolean hasAccess( Id post, String country )
	{
		String permissionName;
        try
        {
	        permissionName = [SELECT PermissionSet.Label
	    	                    FROM PermissionSetAssignment
	                           WHERE PermissionSet.IsOwnedByProfile = FALSE
	                             AND PermissionSetId
	                	          IN (SELECT ParentId FROM ObjectPermissions WHERE SObjectType = 'American_Spaces_Mission_Contact__c')
	                             AND Assignee.Name = :Userinfo.getName() LIMIT 1].PermissionSet.Label;
        }
        catch (Exception e)
        {
        	permissionName = '';
        }
		
        if (permissionName.containsIgnoreCase( 'American Spaces Washington' ))
        {System.debug('@@@1. permissionName...'+permissionName);
        	return true;
        }
        else if (permissionName.containsIgnoreCase( 'American Spaces Manager' ))
        {
        	return hasManagerAccess( post, country );
        }
        else
        {
        	return hasWriterAccess( post );
        }
	}
	
	
	private static boolean hasManagerAccess( Id post, String country )
	{System.debug('@@@2. hasManagerAccess...post: '+post+', country: '+country);
		boolean bFlag = false;
		
		IRO_Contacts__c iroContact;

    	try
    	{
    		iroContact = [SELECT Home_Post__c, Portfolio__c 
    		               FROM IRO_Contacts__c 
    		              WHERE First_Name__c = :Userinfo.getFirstName()
    		                AND Last_Name__c = :UserInfo.getLastName()
    		              LIMIT 1];
    		System.debug('@@@2. hasManagerAccess...iroContact.Home_Post__c: '+iroContact.Home_Post__c+', iroContact.Portfolio__c: '+iroContact.Portfolio__c);
    		if (iroContact.Home_Post__c == post || iroContact.Portfolio__c.contains( country ))
    		{
    			bFlag = true;
    		}
    	}
    	catch(Exception e)
    	{
    		bFlag = false;
    	}
    	
    	return bFlag;
	}
	
	
	private static boolean hasWriterAccess( Id post )
	{System.debug('@@@2. hasWriterAccess...post: '+post);
		boolean bFlag = false;
		
		American_Spaces_Mission_Contact__c missonContactObj;

    	try
    	{
    		missonContactObj = [SELECT id
    		                      FROM American_Spaces_Mission_Contact__c 
    		                     WHERE First_Name__c = :Userinfo.getFirstName()
    		                       AND Last_Name__c = :Userinfo.getLastName()
    		                       AND Managing_Post_City__c = :post
    		                     LIMIT 1];
    		System.debug('@@@2. hasWriterAccess...missonContactObj: '+missonContactObj);
    		if (missonContactObj != null)
    		{
    			bFlag = true;
    		}
    	}
    	catch(Exception e)
    	{
    		bFlag = false;
    	}
		
		return bFlag;
	}
	
	
	public static boolean hasDeleteAccess()
	{
		String permissionName;
        try
        {
	        permissionName = [SELECT PermissionSet.Label
	    	                    FROM PermissionSetAssignment
	                           WHERE PermissionSet.IsOwnedByProfile = FALSE
	                             AND PermissionSetId
	                	          IN (SELECT ParentId FROM ObjectPermissions WHERE SObjectType = 'American_Spaces_Mission_Contact__c')
	                             AND Assignee.Name = :Userinfo.getName() LIMIT 1].PermissionSet.Label;
        }
        catch (Exception e)
        {
        	permissionName = '';
        }
        
        if (permissionName.equalsIgnoreCase( 'American Spaces Washington' ))
        {
        	return true;
        }

        return false;
	}
}
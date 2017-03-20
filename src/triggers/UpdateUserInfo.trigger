trigger UpdateUserInfo on User (before update)
{
    Profile userProfileObj = [SELECT name, Description FROM Profile WHERE id = :UserInfo.getProfileId()];
    String userProfile = userProfileObj.name;
    
    String permissionSet = '';
    
    try
    {
    	permissionSet = [SELECT PermissionSet.Label
                           FROM PermissionSetAssignment
                          WHERE PermissionSet.IsOwnedByProfile = FALSE
                            AND PermissionSet.Label = 'User Manager'
                            AND Assignee.id = :UserInfo.getUserId() LIMIT 1].PermissionSet.Label;
        System.debug( permissionSet );
    }
    catch (Exception e)
    {
    	permissionSet = '';
    	System.debug( 'errored out' );
    	System.debug( e );
    }
    
    Set<String> allowedUsers = new Set<String>();
    Set<String> notAllowFields = new Set<String>();
    
    if (userProfileObj != null &&  userProfileObj.name.equals( 'System Administrator' ))
    {
    	// this is a special case...
    	if (userProfileObj.Description != null)
    	{
    		userProfile = 'System_Administrator';
    	}
    }
    
    List<String> editedFields = new List<String>();
    
    if (User_Modification__c.getValues( 'Allowed Profile' ) != null && User_Modification__c.getValues( 'Allowed Profile' ).value__c.length() > 0)
    {
        allowedUsers.addAll( User_Modification__c.getValues( 'Allowed Profile' ).value__c.split( ',' ));
    }
    if (User_Modification__c.getValues( 'Allowed Fields' ) != null && User_Modification__c.getValues( 'Allowed Fields' ).value__c.length() > 0)
    {
        Set<String> allowFields = new Set<String>();
        allowFields.addAll( User_Modification__c.getValues( 'Allowed Fields' ).value__c.split( ',' ));

        Map<String, Schema.SObjectField> fldObjMap = User.sObjectType.getDescribe().Fields.getMap();
        List<Schema.SObjectField> fldObjMapValues = fldObjMap.values();
        
        for(Schema.SObjectField s : fldObjMapValues)
        {
            String name = s.getDescribe().getName();

            if (s.getDescribe().isUpdateable())
            {
                if (!allowFields.contains( name ))
                {
                    notAllowFields.add( name );
                }
            }
        }
    }
    
    for(User user : Trigger.new)
    {
        if (allowedUsers.contains( userProfile ) || permissionSet.equals( 'User Manager' ))
        {
        	
        }
        else
        {
            sObject newObj = user;
            sObject oldObj = Trigger.oldMap.get( user.Id );
            
            for (String field : notAllowFields)
            {
                if (newObj.get( field ) != oldObj.get( field ))
                {
                    editedFields.add( field );
                }
            }
            
            if (editedFields.size() > 0)
            {
                user.addError( 'You do not have permission to update this information. To have your details modified, please send a ticket to embassy-help@getusinfo.com. Thank you.' );
            }
        }
    }
}
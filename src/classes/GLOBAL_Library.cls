global class GLOBAL_Library
{
 	global static Map<String,Group> queuesMap = new Map<String,Group>();
	global static Map<String,AssignmentRule> casesMap = new Map<String,AssignmentRule>();
	global static List<Case> casesToDelete = new List<Case>();
    
    // This function will remove any span HTML tag in the String
  global static string jitScrub( string inputString )
  {
    String retVal = '';
      
    if (inputString != null && inputString.length() > 0)
    {
      retVal = inputString.replaceAll( '[<](/)?span[^>]*[>]', '' );
    }

    return retVal;
  }
    
    
    // Uses the custom setting to fetch the correct file extension
    // Pre-req - File_Extension__c custome setting needs to be created in that environment
    global static String getContentType( String fileExtension )
    {
      String contentType = fileExtension;
      
      try
      {
          File_Extension__c fe = [SELECT value__c FROM File_Extension__c WHERE name = :fileExtension LIMIT 1];
          
          if (fe != null && fe.value__c != null && fe.value__c.length() > 0)
          {
              contentType = fe.value__c;
          }
      }
      catch (Exception e) { }
      
        return contentType;
    }
    
    
    // Due to the State department email delay using the SF email function, the workaround has to be created. 
    // Using the function below, the email gets gnereated by creating a dummy case and utilizing the assignment rule email generation
    // NOTE: This will consume 5 DML statements.
    global static void sendEmail( String emailAddress, String emailType, String emailSubject, String emailBody )
    {
        Case c = new Case();
        Group emailQueue;
        
        if (emailAddress != null && emailAddress.length() > 0)
        {
            //Stephanie P. (09/04/14) - fixed ticket #141109
            if(!queuesMap.containsKey('Email Queue')) {
            	emailQueue = [SELECT id, email FROM Group WHERE type = 'Queue' and name = 'Email Queue'];
                queuesMap.put('Email Queue', emailQueue);
            }
            else {
                emailQueue = queuesMap.get('Email Queue');
            }
            
            emailQueue.email = emailAddress;
            update emailQueue;
        }
        
        c.SuppliedName = emailSubject;
        c.Subject = emailType;
        c.Description = emailBody;
        
        AssignmentRule ar = new AssignmentRule(); 
        
        //Stephanie P. (09/04/14) - fixed ticket #141109
        if(!casesMap.containsKey('Salesforce Email Handler')) {
            //Assignment Rule Query
        	ar = [select id from AssignmentRule where SobjectType = 'Case' and Name = 'Salesforce Email Handler' and Active = true limit 1];
            casesMap.put('Salesforce Email Handler', ar);
        }
        else {
            ar = casesMap.get('Salesforce Email Handler');
        }
        
        //Creating DML Options
        Database.DMLOptions dmlOpts = new Database.DMLOptions();
        if (ar != null)
        {
           dmlOpts.assignmentRuleHeader.assignmentRuleID = AR.ID;
           dmlOpts.EmailHeader.TriggerUserEmail = true;
           c.setOptions(dmlOpts);
           insert c;
        }
        //Add to the list and delete if the list grows more than 10 cases.
        casesToDelete.add(c);
        
        //delete c;
        //Database.emptyRecycleBin( c );
        
        if (emailAddress != null && emailAddress.length() > 0)
        {
            emailQueue.email = '';
            update emailQueue;
        }

        if(casesToDelete.size() > 10) {
            delete casesToDelete;
            Database.emptyRecycleBin( casesToDelete );
            casesToDelete = new List<Case>();
        }
    }
    
    
    // This will fetch all of the selectOptions from the object field
    global static list<SelectOption> getPicklistValues( SObject obj, String fld )
    {
        list<SelectOption> options = new list<SelectOption>();

        Schema.sObjectType objType = obj.getSObjectType(); 
        Schema.DescribeSObjectResult objDescribe = objType.getDescribe(); 
        map<String, Schema.SObjectField> fieldMap = objDescribe.fields.getMap(); 
        list<Schema.PicklistEntry> values = fieldMap.get( fld ).getDescribe().getPickListValues();

        for (Schema.PicklistEntry a : values)
        { 
            options.add( new SelectOption(a.getLabel(), a.getValue() )); 
        }
        
        return options;
    }
    
    
    // This method will fetch the user permission set
    global static String getPermissionset( String userName, String objectName )
    {
        String permissionName;
        try
        {
            permissionName = [SELECT PermissionSet.Label
                                FROM PermissionSetAssignment
                               WHERE PermissionSet.IsOwnedByProfile = FALSE
                                 AND PermissionSetId
                                  IN (SELECT ParentId FROM ObjectPermissions WHERE SObjectType = :objectName)
                                 AND Assignee.Name = :userName LIMIT 1].PermissionSet.Label;
        }
        catch (Exception e)
        {
            permissionName = '';
        }
        
        return permissionName;
    }
    
    
    // This method will fetch the list of users that contains a certain permision set
    global static String getPermissionsetUsers( String permissionset, String objectName )
    {
        String producersInHTML = '';
        
        for (PermissionSetAssignment psa : [SELECT Assignee.Name
                                              FROM PermissionSetAssignment
                                             WHERE PermissionSet.IsOwnedByProfile = FALSE
                                               AND PermissionSetId
                                                IN (SELECT ParentId FROM ObjectPermissions WHERE SObjectType = :objectName)
                                               AND PermissionSet.Label = :permissionset])
        {
            producersInHTML += psa.Assignee.Name + ';';
        }
        
        return producersInHTML;
    }
    
    
    // This method will fetch the list of user IDs that contains a certain permision set
    global static List<Id> getPermissionsetUserIds( String permissionset, String objectName )
    {
        List<Id> userIds = new List<Id>();
        
        for (PermissionSetAssignment psa : [SELECT AssigneeId
                                              FROM PermissionSetAssignment
                                             WHERE PermissionSet.IsOwnedByProfile = FALSE
                                               AND PermissionSetId
                                                IN (SELECT ParentId FROM ObjectPermissions WHERE SObjectType = :objectName)
                                               AND PermissionSet.Label = :permissionset])
        {
            userIds.add( psa.AssigneeId );
        }
        
        return userIds;
    }
    
    
      /**
   * Creates a generic object
   *
   * <p>Creates an object for a test case that can be used throughout the State dept. Salesforce APEX development. 
   * The developer can pass a key-value mapping of the object to populate.</p>
   *
   * <p>This implementation will return a generic object. The developer needs to make sure to type cast after the process</p>
   * 
   * @param String Name of the object
   * @Param Map<String, String> Key-value mapping information of the object
   */
  global static sObject createObj( String objectName, Map<String, String> values )
  {
    Schema.SObjectType targetType = Schema.getGlobalDescribe().get( objectName );
    
    sObject obj = targetType.newSObject();
    Map<String, Schema.SObjectField> fldObjMap = targetType.getDescribe().Fields.getMap();
    List<Schema.SObjectField> fldObjMapValues = fldObjMap.values();
    
    for(Schema.SObjectField s : fldObjMapValues)
    {
      String label = s.getDescribe().getLabel(); 
      String name = s.getDescribe().getName();
      String objType = s.getDescribe().getType().name();
      Boolean isEditable = s.getDescribe().isUpdateable();
            
            // If the developer passes the mapping information, this will populate the field information
            if (values != null && values.containsKey( name ))
            {
                obj.put( name, values.get( name ));
            }
            // This will create a dummy values by utilizing the field type
            else if (objType != null && isEditable)
            {
                //Stephanie P. (5/28/14) - this is a fix to by pass error 'Field isClosedOCreate is not editable';
                //however this field on cloud is an updatable field (Per Salesforce helpdesk).
                if(!name.equalsIgnoreCase('IsClosedOnCreate')) {
                    if (objType.equalsIgnoreCase( 'string' ))
                    {
                        obj.put( name, 'Test value' );
                    }
                    else if (objType.equalsIgnoreCase( 'Boolean' ) || objType.equalsIgnoreCase( 'Checkbox' ))
                    {
                        obj.put( name, false );
                    }
                    else if (objType.equalsIgnoreCase( 'Date' ))
                    {
                        obj.put( name, date.today() );
                    }
                    else if (objType.equalsIgnoreCase( 'DateTime' ))
                    {
                        obj.put( name, dateTime.now() );
                    }
                    else if (objType.equalsIgnoreCase( 'Currency' ))
                    {
                        obj.put( name, 1234 );
                    }
                    else if (objType.equalsIgnoreCase( 'Email' ))
                    {
                        obj.put( name, 'test@testZZZ.com' );
                    }
                }                
            }
        }

    return obj;
  }
  
  
  /**
   * Creates a generic SOQL query 
   *
   * <p>Creates a SOQL query string for a test case that can be used throughout the State dept. Salesforce APEX development.</p>
   * 
   * <p>This implementation will return a generic SOQL string. The developer needs to make sure to remove the excessive fields</p>
   * 
   * @param String Name of the object
   */
  global static String getFieldsSOQL( String objectName )
  {
    String selects = '';

    //Getamapoffieldnameandfieldtoken
    Map<String, Schema.SObjectField> fMap = Schema.getGlobalDescribe().get( objectName.toLowerCase() ).getDescribe().Fields.getMap();
    list<string> selectFields = new list<string>();
    
    if (fMap != null)
    {
      //loopthroughallfieldtokens(ft)
      for (Schema.SObjectField ft : fMap.values())
      {
        //describeeachfield(fd)
        Schema.DescribeFieldResult fd = ft.getDescribe();

        if (fd.isAccessible())
        {
          selectFields.add( fd.getName() );
        }
      }
    }
    
    if (!selectFields.isEmpty())
    {
      for (String s :selectFields)
      {
        if (selects.length() == 0)
        {
          selects = s;
        }
        
        selects+= ',' + s;
      }      
    }
    
    return selects;
  }
}
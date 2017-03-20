global class YSEALI_Controller implements Schedulable
{ 
  global void execute( SchedulableContext sc )
  {
      subscribeYSEALIUsers();
  }
  
  global static Integer getTotalSubscribers()
  {    
    Http h = new Http();
    
    HttpRequest req = new HttpRequest();
    req.setEndpoint( Global_Variable__c.getValues( 'MailChimp getList URL' ).value__c );
    req.setBody( '{"apikey": "' + Global_Variable__c.getValues( 'MailChimp API Key' ).value__c + '"}' );
    req.setMethod( 'POST' );
    
    HttpResponse res = h.send( req );
    
    Map<String, Object> jsonObj = (Map<String, Object>) JSON.deserializeUntyped( res.getBody() );
    List<Object> myData = (List<Object>) jsonObj.get( 'data' );

    Integer totalSub = 0;
    
    for (Object obj : myData)
    {
      Map<String, Object> info = (Map<String, Object>) obj;
      Map<String, Object> stats = (Map<String, Object>) info.get( 'stats' );
      totalSub += Integer.valueOf( stats.get( 'member_count' ));
    }
    
    return totalSub;
  }

  global static void batchSubscribe( List<Contact> myContact )
  {
    Http h = new Http();
    List<String> emails = new List<String>();
      //Updated list with mailchimp_subscription__c = true
    List<Contact> updateList = new List<Contact>();
      //Contacts list with reasons: disabled signup and invalid domain will be removed from Salesforce
    List<Contact> invalidContactsList = new List<Contact>();
    Integer sessionTimedout = Integer.valueOf(Global_Variable__c.getValues('Session Timedout').value__c);
      
    HttpRequest req = new HttpRequest();
    req.setEndpoint( Global_Variable__c.getValues( 'MailChimp Subscribe URL' ).value__c );
    
    YSEALI_BatchSubscribe batchSub = new YSEALI_BatchSubscribe(); 
    Map<String, String> errorMessages = new Map<String, String>();
      
    batchSub.apikey = Global_Variable__c.getValues( 'MailChimp API Key' ).value__c;
    batchSub.id = Global_Variable__c.getValues( 'MailChimp List Key' ).value__c;
      
    for (Contact contactObj : myContact)
    {
      YSEALI_Email userEmail = new YSEALI_Email();
      userEmail.email = contactObj.Email;
      
      YSEALI_UserData userData = new YSEALI_UserData();
      userData.fname = contactObj.FirstName;
      userData.lname = contactObj.LastName;
      //userData.birthyear = contactObj.Birth_Year__c;
      userData.citizen = contactObj.Citizenship__c;
      //09/26/14 - This field has been removed from MailChimp
      //userData.residence = contactObj.Country_of_Residence__c;
      userData.cities = contactObj.City__c;
      /*if(contactObj.Solving_regional_issues__c == true)
        userData.regional = 'Yes';
      else
        userData.regional = 'No';
      
      if(contactObj.Protect_the_environment__c == true)
        userData.environ = 'Yes';
      else
        userData.environ = 'No';  
      
      if(contactObj.Increase_community_prosperity__c == true)
        userData.prosper = 'Yes';
      else
        userData.prosper = 'No';
      
      if(contactObj.Educate_my_generation__c == true)
        userData.educate = 'Yes';
      else
        userData.educate = 'No';   
      
      if(contactObj.Have_participated_in_US_Gov_programs__c == true)
        userData.priorpar = 'Yes';
      else
        userData.priorpar = 'No';
      */
      YSEALI_Subscriber userObj = new YSEALI_Subscriber();
      userObj.email = userEmail;
      userObj.merge_vars = userData;
      
      batchSub.batch.add( userObj );
    }

      req.setBody( JSON.serialize( batchSub ));
      req.setMethod( 'POST' );
      //Stephanie P. (5/25/2015) - Increase session timeout to max is 120000
      //If this doesn't fix error 'Read time out', need to limit the query results
      req.setTimeout(sessionTimedout);  
      HttpResponse res = h.send( req );
      //System.debug('STATUS: '+res.getStatus()+' - STATUS CODE: '+res.getStatusCode());
      Map<String, Object> jsonObj = (Map<String, Object>) JSON.deserializeUntyped( res.getBody() );
      //System.debug('RES BODY: '+jsonObj);
      Integer addedCount = Integer.valueOf( jsonObj.get( 'add_count' ));
      Integer errorCount = Integer.valueOf( jsonObj.get( 'error_count' ));
      
      List<Object> errData = (List<Object>) jsonObj.get( 'errors' );

    for (Object obj : errData)
    {
        Map<String, Object> info = (Map<String, Object>) obj;
        Map<String, Object> stats = (Map<String, Object>) info.get( 'email' );
        Integer errorCode = Integer.valueOf(info.get('code'));
        errorMessages.put( String.valueOf( stats.get( 'email' )), String.valueOf( info.get( 'error' )));
    }
    
      try 
      {
        for (Contact cont : myContact)
        {
          if (!errorMessages.containsKey( cont.email ))
          {
            //cont.MailChimp_Subscription__c = true;
            updateList.add( cont );
          }
         else {
             String errorMessage = (String)errorMessages.get(cont.email);
             if(errorMessage != null && errorMessage.contains('is already subscribed to the list')) {
                //cont.MailChimp_Subscription__c = true;
                updateList.add( cont );
             }
             //Any email with reason: disabled signup and invalid domain should be
             //removed from Salesforce to avoid retaining too many invalid emails.  These emails are not
             //subscribed to Mailchimp, there is no reason to keep in SF
             else if (String.isNotBlank(errorMessage) && !errorMessage.contains('has bounced')) {
                 invalidContactsList.add(cont);
             }
         }
        }          
      } catch(Exception e) {
          System.debug('Exception caught: '+e.getMessage());
      }

    if(updateList.size() > 0)
        update updateList;

      if (errorMessages.size() > 0)
    {
      String errorMessage = 'Please see below for the error messages -\n';

      for (String key : errorMessages.keySet())
      {
        errorMessage += 'Email Address: ' + key + '<br/>';
        errorMessage += 'Error Message: ' + errorMessages.get( key ) + '\r\n';      
        //errorMessage.replaceAll( '\n', '\r\n');
      }
        
        //Email with the YSEALI contacts list that has an error
        //This fixes the issue 'Insertion fail due to STRING_TOO_BIG' with many errors from MailChimp
        Document ysealiAttachment = [SELECT name, Body FROM Document WHERE Keywords = 'YSEALI Attachment' AND Description = 'YSEALI Attachment'];

        DateTime currentDate = DateTime.now();
        String currentDateFormat = currentDate.format( 'MMM dd' );
        Case c = new Case();
                
        c.SuppliedName = 'Salesforce - MailChimp Subscription Issue';
        c.Subject = 'SYS:YSEALI Administrator';
        c.Email_Body__c = 'YSEALI_' + currentDateFormat + ' is attached.';
        
        if(ysealiAttachment != null) {
            //ysealiAttachment.Body = Blob.valueOf( errorMessage.replaceAll( '\n', '\r\n') );
            ysealiAttachment.Body = Blob.valueOf(errorMessage);
            ysealiAttachment.Name = 'YSEALI_' + currentDateFormat;
            update ysealiAttachment;
        }
        
        AssignmentRule ar = new AssignmentRule(); 
        
        //Assignment Rule Query
        ar = [select id from AssignmentRule where SobjectType = 'Case' and Name = 'Salesforce Email Handler' and Active = true limit 1];
        
        //Creating DML Options
        Database.DMLOptions dmlOpts = new Database.DMLOptions();
        if (ar != null)
        {
           dmlOpts.assignmentRuleHeader.assignmentRuleID = AR.ID;
           dmlOpts.EmailHeader.TriggerUserEmail = true;
           c.setOptions(dmlOpts);
           insert c;
        }
        
        //clean up after sending out an email
        
        ysealiAttachment.Body = Blob.valueOf( '' );
        ysealiAttachment.Name = 'YSEALI Attachment';
        update ysealiAttachment;

        if(invalidContactsList.size() > 0)
            delete invalidContactsList;
    }
  }
  
  @Future(callout=true)
  global static void subscribeYSEALIUsers()
  {
      Integer maxQueryResults = Integer.valueOf(Global_Variable__c.getValues('Max Query Results').value__c); 
    /*List<Contact> myContacts = [SELECT email, firstName, lastName, city__c, Language__c, Citizenship__c, Have_participated_in_US_Gov_programs__c, Educate_my_generation__c, Increase_community_prosperity__c, Protect_the_environment__c, Solving_regional_issues__c,
                                MailChimp_Subscription__c
                                  FROM Contact
                                 WHERE Account.name = 'YSEALI'
                                   AND MailChimp_Subscription__c != true
                                   AND MailChimp_Opt_Out__c = null
                                   AND Email != NULL LIMIT :maxQueryResults];
        
        subscribeUsersToMailChimp( myContacts );*/
  }
  
  global static void subscribeUsersToMailChimp( List<Contact> myContacts )
  {
        Integer limitSize = Integer.valueOf( Global_Variable__c.getValues( 'Mailchimp limit' ).value__c );
        Integer threshold = Integer.valueOf( Global_Variable__c.getValues( 'Mailchimp Threshold' ).value__c );
        Integer totalSubscribers = getTotalSubscribers();
        Integer difference = limitSize - totalSubscribers + myContacts.size();

        if (difference < threshold)
        {
          // Using the Case Assignment to send out the email
          GLOBAL_Library.sendEmail( '', 
                                    'YSEALI Administrator', 
                                    'Salesforce - MailChimp Threshold has met!', 'Salesforce will stop subscribing the user automatically.' );          
        }
        else
        {
            batchSubscribe( myContacts );
        }
  }
}
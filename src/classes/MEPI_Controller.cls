global class MEPI_Controller
{
    global void execute( SchedulableContext sc )
    {
        subscribeMEPIUsers();
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
    
    
    global static void updateUnsubscriber()
    {
        Http h = new Http();
        
        String listID = Global_Variable__c.getValues( 'MailChimp List Key' ).value__c;
        
        HttpRequest req = new HttpRequest();
        req.setEndpoint( Global_Variable__c.getValues( 'MailChimp SubUsers URL' ).value__c );
        System.debug( '{"apikey": "' + Global_Variable__c.getValues( 'MailChimp API Key' ).value__c + '", "id": "' + listID + '", "status" : "unsubscribed"}' );
        req.setBody( '{"apikey": "' + Global_Variable__c.getValues( 'MailChimp API Key' ).value__c + '", "id": "' + listID + '", "status" : "unsubscribed"}' );
        req.setMethod( 'POST' );
        
        HttpResponse res = h.send( req );
        
        Map<String, Object> jsonObj = (Map<String, Object>) JSON.deserializeUntyped( res.getBody() );
        List<Object> myData = (List<Object>) jsonObj.get( 'data' );
        
        List<String> emails = new List<String>();
        
        for (Object obj : myData)
        {
            Map<String, Object> info = (Map<String, Object>) obj;
            emails.add(  String.valueOf( info.get( 'email' )));
        }
        
        List<Contact> updateContacts = new List<Contact>();
        
        for(Contact c : [SELECT id FROM Contact WHERE Email in :emails])
        {
            //c.MailChimp_Opt_Out__c = 'Mailchimp';
            //c.MailChimp_Subscription__c = false;
            updateContacts.add( c );
        }
        
        update updateContacts;
    }
    
    
    global static void batchSubscribe( List<Contact> myContact )
    {
        Http h = new Http();
        
        HttpRequest req = new HttpRequest();
        req.setEndpoint( Global_Variable__c.getValues( 'MailChimp Subscribe URL' ).value__c );
        
        MEPI_BatchSubscribe batchSub = new MEPI_BatchSubscribe(); 
        batchSub.apikey = Global_Variable__c.getValues( 'MailChimp API Key' ).value__c;
        batchSub.id = Global_Variable__c.getValues( 'MailChimp List Key' ).value__c;
        
        for (Contact contactObj : myContact)
        {
            MEPI_Email userEmail = new MEPI_Email();
            userEmail.email = contactObj.Email;
            
            MEPI_UserData userData = new MEPI_UserData();
            userData.fname = contactObj.FirstName;
            userData.lname = contactObj.LastName;
            userData.city = contactObj.City__c;
            userData.mc_language = contactObj.Spoken_Languages__c;
            
            MEPI_Subscriber userObj = new MEPI_Subscriber();
            userObj.email = userEmail;
            userObj.merge_vars = userData;
            
            batchSub.batch.add( userObj );
        }

        req.setBody( JSON.serialize( batchSub ));
        req.setMethod( 'POST' );

        HttpResponse res = h.send( req );

        Map<String, Object> jsonObj = (Map<String, Object>) JSON.deserializeUntyped( res.getBody() );
        Integer addedCount = Integer.valueOf( jsonObj.get( 'add_count' ));
        Integer errorCount = Integer.valueOf( jsonObj.get( 'error_count' ));
        
        List<Object> errData = (List<Object>) jsonObj.get( 'errors' );
        
        Map<String, String> errorMessages = new Map<String, String>();
        
        for (Object obj : errData)
        {
            Map<String, Object> info = (Map<String, Object>) obj;
            Map<String, Object> stats = (Map<String, Object>) info.get( 'email' );
            errorMessages.put( String.valueOf( stats.get( 'email' )), String.valueOf( info.get( 'error' )));
        }
        
        List<Contact> updateList = new List<Contact>();
        
        for (Contact cont : myContact)
        {
            if (!errorMessages.containsKey( cont.email ))
            {
                //cont.MailChimp_Subscription__c = true;
                updateList.add( cont );
            }
        }
        
        update updateList;
        
        if (errorMessages.size() > 0)
        {
            String errorMessage = 'Please see below for the error messages -<br/><br/>';
            
            for (String key : errorMessages.keySet())
            {
                errorMessage += 'Email Address: ' + key + '<br/>';
                errorMessage += 'Error Message: ' + errorMessages.get( key ) + '<br/><br/>';
            }
            
            errorMessage += 'Thank you.';
            
            GLOBAL_Library.sendEmail( '', 
                                      'MEPI Administrator', 
                                      'Salesforce - MailChimp Subscription Issue', errorMessage );
        }
    }
    
    global static void subscribeMEPIUsers()
    {
        List<Contact> myContacts = [SELECT email, firstName, lastName, city__c, Spoken_Languages__c 
                                      FROM Contact
                                     WHERE Account.name = 'MEPI'
                                       AND Email != null];
        subscribeUsersToMailChimp( myContacts );
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
                                      'MEPI Administrator', 
                                      'Salesforce - MailChimp Threshold has met!', 'Salesforce will stop subscribing the user automatically.' );            
        }
        else
        {
            batchSubscribe( myContacts );
        }
    }
}
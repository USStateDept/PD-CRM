global class YSEALI_Unsubscribe implements Schedulable {
    global static YSEALI_BatchUnsubscribe batchUnsubscribe{ get; set; }
    
    global void execute( SchedulableContext sc )
    {
        updateUnsubscriber();
    }
    
  @Future(callout=true)  
  global static void updateUnsubscriber()
  {
        Http h = new Http();
      	List<String> emails = new List<String>();
        
        String listID = Global_Variable__c.getValues( 'MailChimp List Key' ).value__c;
        String apiKey = Global_Variable__c.getValues( 'MailChimp API Key' ).value__c;
        
        //send a request to get unsubscribed users list from MailChimp
        HttpRequest req = new HttpRequest();
        req.setEndpoint( Global_Variable__c.getValues( 'MailChimp SubUsers URL' ).value__c );
        System.debug( '{"apikey": "' + apiKey + '", "id": "' + listID + '", "status" : "unsubscribed"}' );
        req.setBody( '{"apikey": "' + apiKey + '", "id": "' + listID + '", "status" : "unsubscribed"}' );
        req.setMethod( 'POST' );
        
        HttpResponse res = h.send( req );
        
        Map<String, Object> jsonObj = (Map<String, Object>) JSON.deserializeUntyped( res.getBody() );
        List<Object> myData = (List<Object>) jsonObj.get( 'data' );
    
        emails = new List<String>();
        batchUnsubscribe = new YSEALI_BatchUnsubscribe();
        batchUnsubscribe.apikey = apiKey;
        batchUnsubscribe.id = listID;
        batchUnsubscribe.delete_member = true;
          
        for (Object obj : myData)
        {
            YSEALI_Email userEmail = new YSEALI_Email();
            Map<String, Object> info = (Map<String, Object>) obj;
            
            String leid = String.valueOf(info.get('leid'));
            String ueid = String.valueOf(info.get('euid'));
            String email = String.valueOf( info.get('email'));
            System.debug('@@@email...'+email+', leid...'+leid+', euid...'+ueid);
            userEmail.email = email;
            userEmail.euid = ueid;
            userEmail.leid = leid;
            
            //Build batch_unsubscribe object prior to send to MailChimp
            batchUnsubscribe.batch.add(userEmail);
            emails.add(email);
        }
         
        //Unsubscribe and delete contacts in MailChimp that have been unsubscribed
        Boolean isUnsubscribeSuccess = batchUnsubscribe();
        
        //Update contacts in SF
        if(isUnsubscribeSuccess)
        {
        	/*
            List<Contact> updateContacts = new List<Contact>();
        
            for(Contact c : [SELECT id, MailChimp_Opt_Out__c FROM Contact WHERE Email in :emails])
            {
               c.MailChimp_Opt_Out__c = 'Mailchimp';
               c.MailChimp_Subscription__c = false;
               updateContacts.add( c );
            }
			
			update updateContacts;
          
            List<Contact> contactsToDelete = [SELECT id, MailChimp_Opt_Out__c FROM Contact WHERE Email in :emails];
            if(contactsToDelete != null && contactsToDelete.size() > 0)
            {
            	System.debug('@@@About to delele '+contactsToDelete.size()+' contacts.');
            	delete contactsToDelete;              
            }*/
        }
  }
    
    /**
     * Send the contacts list to MailChimp to unsubscribe and delete from system
     **/
    global static Boolean batchUnsubscribe() 
    {
        Integer successCount = 0;
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        
        if(batchUnsubscribe != null && batchUnsubscribe.batch.size() > 0)
        {
        	String resStatus;
            req.setEndpoint(Global_Variable__c.getValues('MailChimp UnSubscribe URL').value__c);
              
            req.setBody( JSON.serialize( batchUnsubscribe ));
            req.setMethod( 'POST' );
    
            HttpResponse res = h.send(req);
              
            System.debug('STATUS: '+res.getStatus()+' - STATUS CODE: '+res.getStatusCode());
            resStatus = res.getStatus();
            if(resStatus != null && resStatus.containsIgnoreCase('ok'))
            {
                return true;
            }
        }
                       
        return false;
    }
}
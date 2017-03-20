@RestResource(urlMapping='/YSEALIContact/import/*')
global class YSEALI_WebguiToSF
{
    @HttpPost
    global static String insertContacts( List<Contact> contacts )
    {
        Map<String, Contact> extractedData = new Map<String, Contact>();
        
        ID accoutID = [select id from Account where name = 'YSEALI'].id;
        
        List<Contact> contactsWithID = new List<Contact>();
        List<Activity__c> newActivities = new List<Activity__c>();

        // Filter them by emails to verify to see if the contact exists in the database...
        for (Contact myContact : contacts)
        {
            String email = myContact.email;
            
            //Stephanie Pham (5/17/14)
            //Due to the issue lowercase and uppercase with the same emails
            //during comparision emails between DB and from the list.
            //Lowercase both emails from list and DB for more sufficiency.
            if(String.isNotBlank(email))
                email = email.toLowerCase();
            
            if (!extractedData.containsKey( email ))
            {
                myContact.AccountId = accoutID;
                try {
                	myContact.id = null;
                } catch(Exception e) {
                    System.debug('contact id exception: '+e.getMessage());
                }
                extractedData.put( email, myContact );
            }
        }
        
        Set<String> emails = extractedData.keySet();

        List<Contact> existingContacts = [SELECT id, email FROM Contact WHERE email in :emails AND account.name = 'YSEALI'];

        // Removing any existing contacts
        if (existingContacts != null && existingContacts.size() > 0)
        {
            for (Contact existingContact : existingContacts)
            {
                String existingEmail = existingContact.email;
                
                //Stephanie Pham (5/17/14)
                //Lowercase emails are retrieved from DB to match with emails
                //from the list
                if(String.isNotBlank(existingEmail))
                    existingEmail = existingEmail.toLowerCase();

                if(String.isNotBlank(existingEmail) && extractedData.containsKey(existingEmail)) {
                    Contact extractedContact = extractedData.get( existingEmail);

                    if(extractedContact != null && existingContact.id != null)
                    {
                        extractedContact.id = existingContact.id;
                        contactsWithID.add( extractedContact);
                        extractedData.remove( existingEmail );
                    }                         
                 
                }
            }
        }
        
        insert( extractedData.values() );
        
        contactsWithID.addAll( extractedData.values() );
        
        // Second loop to create the activities for each of the contact
        for (Contact myContact : contactsWithID)
        {
            Activity__c newActivity = new Activity__c();
            newActivity.Contact__c = myContact.id;
            newActivity.Upload_Method__c = myContact.Initial_Creation_Type__c;
            //newActivity.Uploaded_Time__c = myContact.Submitted_Time__c;
            newActivities.add( newActivity );
        }
        
        insert( newActivities );
        
        return 'success';
    }
}
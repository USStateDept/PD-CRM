@RestResource(urlMapping='/MEPIContact/import/*')
global class MEPI_WebguiToSF
{
    @HttpPost
    global static String insertContacts( List<Contact> contacts )
    {
    	Map<String, Contact> extractedData = new Map<String, Contact>();
    	
    	ID accoutID = [select id from Account where name = 'MEPI'].id;
    	
    	List<Contact> contactsWithID = new List<Contact>();
    	List<Activity__c> newActivities = new List<Activity__c>();

    	// Filter them by emails to verify to see if the contact exists in the database...
    	for (Contact myContact : contacts)
    	{
    		String email = myContact.email;
    		
    		if (!extractedData.containsKey( email ))
    		{
    			myContact.AccountId = accoutID;
    			extractedData.put( email, myContact );
    		}
    	}
    	
    	Set<String> emails = extractedData.keySet();
    	
    	List<Contact> existingContacts = [SELECT id, email FROM Contact WHERE email in :emails AND account.name = 'MEPI'];
    	
    	// Removing any existing contacts
    	if (existingContacts != null && existingContacts.size() > 0)
    	{
    		for (Contact existingContact : existingContacts)
    		{
    			extractedData.get( existingContact.email ).id = existingContact.id;
    			contactsWithID.add( extractedData.get( existingContact.email ));
    			extractedData.remove( existingContact.email );
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
@isTest
private class Test_ContactInterest {
	
	@isTest static void test_method_insert() {
		// Insert Contact
		Contact objContact = new Contact();
		objContact.LastName = 'Test';
		Insert objContact;
		String contactId = objContact.Id;

		// Insert Interest
		Interest__c objInterest = new Interest__c();
		objInterest.Name = 'Test';
		Insert objInterest;
		String interestId = objInterest.Id;

		// Insert Interest
		Interest__c objInterest1 = new Interest__c();
		objInterest1.Name = 'Test1';
		Insert objInterest1;
		String interestId1 = objInterest1.Id;			

		// Insert Contact Interest
		Contact_Interests__c objConInt = new Contact_Interests__c();
		objConInt.Contact__c = contactId;
		objConInt.Interest__c = interestId;
		Insert objConInt;
		String conIntId = objConInt.Id;

		// Update Contact Interest
		Contact_Interests__c objConInt1 = [Select Id from Contact_Interests__c where Id = :conIntId];
		objConInt.Interest__c = interestId1;
		Update objConInt1;

		// Delete Contact Interest
		Contact_Interests__c objConInt2 = [Select Id from Contact_Interests__c where Id = :conIntId];
		Delete objConInt2;		

	}

}
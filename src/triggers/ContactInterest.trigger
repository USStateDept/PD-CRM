trigger ContactInterest on Contact_Interests__c (
	after insert, 
	after update, 
	after delete) {

	new ContactInterestTriggerHelper().process();
}
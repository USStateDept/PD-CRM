public with sharing class ContactInterestTriggerHelper extends TriggerHelper{
    
    public override void processAfterInsert() {
        UpdateContact(trigger.new);
    }

	public override void processAfterDelete() {
		UpdateContact(trigger.old);
    }

	public override void processAfterUpdate() {
        UpdateContact(trigger.new);
    }

    public void UpdateContact(List<Contact_Interests__c> newList){

    	Set<Id> contactIds = new Set<Id>();
    	for(Contact_Interests__c ci : newList){
			contactIds.add(ci.Contact__c);
		}
    
		// Gets related contacts
		List<Contact> relatedContacts = [Select c.InterestsSelected__c,(Select Interest__r.Name from Contact_Interests__r)  From Contact c where id in: contactIds];

		Boolean isFirst = true;
    
    	// set each related Contacts
    	for(Contact con : relatedContacts){
			con.InterestsSelected__c = '';
			for(Contact_Interests__c cis : con.Contact_Interests__r){
				if(isFirst){
					con.InterestsSelected__c += cis.Interest__r.Name;
					isFirst = false;
				}
				else{
					con.InterestsSelected__c += ',' + cis.Interest__r.Name;
				}
			}
		}
    
		update relatedContacts;

    }

}
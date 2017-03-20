public with sharing class EventRegistrationTriggerHelper extends TriggerHelper{
	
	public override void processAfterInsert() {
        if(!DOSAddEventController.isBypassER())
        	AddSubscribers(trigger.newMap,trigger.oldMap);
    }

    public override void processBeforeUpdate() {
		for(Sobject eventSObject : trigger.newMap.Values()){
			Event_Registration__c erNewInstance = (Event_Registration__c) eventSObject;
			Event_Registration__c erOldInstance = (Event_Registration__c) trigger.oldMap.get(erNewInstance.Id);
			if(erNewInstance.Contact__c != erOldInstance.Contact__c && erOldInstance.Contact__c != null){
				eventSObject.addError('Changing the registered guest is not allowed, Please delete the registration and add a new one');
			}
        }
    }

    public override void processAfterUpdate() {
    	if(!DOSAddEventController.isBypassER())
       		 UpdateSubscribers(trigger.newMap,trigger.oldMap);
    }

    public override void processBeforeDelete() {
        DeleteSubscribers(trigger.newMap,trigger.oldMap);
    }
  
    public void AddSubscribers(Map<Id, SObject> newMap,Map<Id, SObject> oldMap){
    	
		for(Sobject eventSObject : trigger.newMap.Values()){
			Event_Registration__c erNewInstance = (Event_Registration__c) eventSObject;
			CreateContactsInSegments.CreateContactsInList(erNewInstance.Event__c);
        }
     	
    }
    
    public void UpdateSubscribers(Map<Id, SObject> newMap,Map<Id, SObject> oldMap){
		for(Sobject eventSObject : trigger.newMap.Values()){
			Event_Registration__c erNewInstance = (Event_Registration__c) eventSObject;
			if(erNewInstance.Status__c != 'Invited'){
				CreateContactsInSegments.UpdateContactsInSegments(erNewInstance.Id);
			}
        }    	

    }

    public void DeleteSubscribers(Map<Id, SObject> newMap,Map<Id, SObject> oldMap){
    	
		for(Sobject eventSObject : trigger.oldMap.Values()){
			Event_Registration__c erNewInstance = (Event_Registration__c) eventSObject;
			Event_Registration__c erOldInstance = (Event_Registration__c) trigger.oldMap.get(erNewInstance.Id);
			CreateContactsInSegments.DeleteSubscriber(erOldInstance.Campaign_Monitor_List_Id__c,erOldInstance.Contact_Email__c);
        }
     	
    }

    
}
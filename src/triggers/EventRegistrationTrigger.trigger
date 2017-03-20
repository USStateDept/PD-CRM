trigger EventRegistrationTrigger on Event_Registration__c (after delete, after insert, after undelete, after update, before delete, before insert, before update) {
    new EventRegistrationTriggerHelper().process();
}
trigger EventsTrigger on Event__c (
    before insert, 
    before update, 
    before delete, 
    after insert, 
    after update, 
    after delete, 
    after undelete) {

    new EventsTriggerHelper().process();
    
}
trigger Preference on Preference__c (after insert,after delete, after update) {

    new PreferenceTriggerHelper().process();
}
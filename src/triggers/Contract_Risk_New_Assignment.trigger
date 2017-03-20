trigger Contract_Risk_New_Assignment on Contract_Risk__c (before update) {

    Contract_Risk__c[] n = Trigger.new;
    Contract_Risk__c[] o = Trigger.old;
    
    //Check for change in owner name, set is_new_assignment__c to Y or N
    //A workflow is established to send email to new owner if value is Y
    Contract_Risk_Notifications.checkNewOwner(n, o);
}
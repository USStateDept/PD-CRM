trigger Triggered on CMS_Risk__c (before update) {
    
    CMS_Risk__c[] n = Trigger.new;
    CMS_Risk__c[] o = Trigger.old;
    
    //Check if item has been set to Triggered in RARisk_Status__c, set is_Trigggered__c to Y
    //A workflow can be established to send email to correct people if value is Y
    CMS_Risk_Notifications.checkTriggered(n, o);
}
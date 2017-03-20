trigger Contract_Risk_Triggered on Contract_Risk__c (before update) {
	
    Contract_Risk__c[] n = Trigger.new;
    Contract_Risk__c[] o = Trigger.old;
    
    //Check if item has been set to Triggered in RARisk_Status__c, set is_Trigggered__c to Y
    //A workflow can be established to send email to correct people if value is Y
    Contract_Risk_Notifications.checkTriggered(n, o);
}
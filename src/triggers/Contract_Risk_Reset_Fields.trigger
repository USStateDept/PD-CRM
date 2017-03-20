trigger Contract_Risk_Reset_Fields on Contract_Risk__c (before update) {
	
    Contract_Risk__c[] n = Trigger.new;
    Contract_Risk__c[] o = Trigger.old;
    
    //Check for changes in Risk Type and Risk Status, reset conditional fields as needed
    Contract_Risk_Field_Reset.resetRiskType(n, o);
}
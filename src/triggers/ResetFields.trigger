trigger ResetFields on CMS_Risk__c (before update) {

    CMS_Risk__c[] n = Trigger.new;
    CMS_Risk__c[] o = Trigger.old;
    
    //Check for changes in Risk Type and Risk Status, reset conditional fields as needed
    CMS_Risk_Field_Reset.resetRiskType(n, o);
}
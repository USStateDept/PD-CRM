/* 
 * Before a SARF is inserted or updated, identify if the email address is a state.gov address
 * Set boolean value non_state_gov_email__c
 */

trigger SARF_Email_Identifier on CMS_SARF__c (before insert, before update) {    
    for(CMS_SARF__c sarf: Trigger.new){
       	sarf.non_state_gov_email__c = false;
        if(!sarf.Email_Address__c.contains('state.gov'))
            sarf.non_state_gov_email__c = true;
    }
}
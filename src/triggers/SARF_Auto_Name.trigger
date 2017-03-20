/* 
 * Before a SARF is inserted, determine SARF Name
 * Set String value sarf_name__c to last name initial + first name + version #
 */

trigger SARF_Auto_Name on CMS_SARF__c (before insert) {
    
    for (CMS_SARF__c s : Trigger.new) {        
        Decimal version = s.Version_Number__c; // store the version_number__c value of the SARF        
        if(version == null){// if there is no version number set, set version to 1
            version = 1;        
        }else{ // else set to version + 1 to increment to the next version
             version += 1;
        }       
        String firstInitial = s.first_name__c.substring(0,1); // get first initial of first name        
        s.SARF_Name__c = 'SARF-' + s.last_name__c + firstInitial + '-v' + version; // set sarf_name__c to correct format        
        s.version_number__c = version; // set version_number__c on SARF
    }
}
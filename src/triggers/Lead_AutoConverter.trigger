trigger Lead_AutoConverter on Lead (after insert, after update) {
    LeadStatus convertStatus = [
        select MasterLabel
        from LeadStatus
        where IsConverted = true
        limit 1
    ];
    
    ID existContactId;
    ID accountId;
    //String householdRecType = [SELECT id FROM RecordType WHERE name = 'Household' and SObjectType = 'Account'].id;
    List<Lead> newLeads = new List<Lead>();
    List<Database.LeadConvert> leadConverts = new List<Database.LeadConvert>();
    final String PREFIX_ACCOUNT_NAME = 'U.S. Mission ';

    for (Lead lead: Trigger.new) {
        if(lead.HasOptedOutOfEmail == false){
//         if(lead.Status == 'Open'){
            if(!lead.IsConverted) {
                Database.LeadConvert lConvert = new Database.LeadConvert();
    
                Account a = new Account();
                a.Name = PREFIX_ACCOUNT_NAME + lead.Country_of_Residence__c;
                
                 /*
                 if(String.isNotEmpty(lead.FirstName) && String.isNotEmpty(lead.LastName)) {
                    a.Name = lead.FirstName + ' ' + lead.LastName;
                } else {
                    if(String.isEmpty(lead.FirstName) && String.isNotEmpty(lead.LastName))
                        a.Name = lead.LastName;
                }
                */
                a.Email__c = lead.Email;
                a.Contact_Source__c = lead.LeadSource;
                
                if(!String.isEmpty(a.Contact_Source__c) 
                   && (a.Contact_Source__c.equals('Web') || a.Contact_Source__c.equals('YSEALI'))) {
                       a.Segment__c = 'Household';
                       //a.RecordTypeId = houseHoldRecType;
                   }
                
                a.Region__c = lead.Region__c;
                a.Country__c = lead.Country_of_Residence__c;
                
                insert a;
                
                lConvert.setAccountId(a.Id);
                lConvert.setLeadId(lead.Id);
                lConvert.setDoNotCreateOpportunity(true);   
                lConvert.setConvertedStatus(convertStatus.MasterLabel);
                leadConverts.add(lConvert);
    
            }//end of lead isConverted is false
        }//end of lead HasOptedOutOfEmail is false
//      }        
    }//end of for loop
    
   
    if(!leadConverts.isEmpty()){
        List<Database.LeadConvertResult> lConvertResult = Database.convertLead(leadConverts);
    }
}
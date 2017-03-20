trigger Lead_BeforeInsertUpdate on Lead (before insert, before update) {
    
    //Added by Venkatesh
   // Final String PREFIX_ACCOUNT_NAME = 'U.S. Mission ';
   // Map<String,Contact> mapContact = new Map<String,Contact>();
   // List<Preference__c> lstPrefUpd = new List<Preference__c>();
   // List<String> lstEmail = new List<String>();
   // for(Lead objl:Trigger.new){ //Get all email Id's and put it in map
    //    lstEmail.add(objl.Email);
   // }
    //Get contacts of email 
   // for(Contact ct : [select id, name, Accountid, account.name,email from Contact where email IN:lstEmail]){
    //    mapContact.put(ct.email,ct);
   // }
   
    for(Lead lead : Trigger.new) {
        if(String.isEmpty(lead.Company))
            lead.Company = 'Household';
        if(String.isEmpty(lead.Status))
            lead.Status = 'Open';
        if(String.isEmpty(lead.LeadSource ))
            lead.LeadSource = 'Web';
        lead.Country = lead.Country_of_Residence__c;    
        
        if(Trigger.isinsert){
            lead.HasOptedOutOfEmail = true;
            }
            
            //Added by Venkatesh
//           if(lead.HasOptedOutOfEmail == false){
//            if(mapContact.get(lead.email)!=null){
//                if(mapContact.get(lead.email).Account.Name==PREFIX_ACCOUNT_NAME + lead.Country_of_Residence__c){
//                    lead.Status = 'Qualified';
//                }else{
                    //Add a new record
//                    Preference__c objP = new Preference__c();
//                    objP.ContactName__c = mapContact.get(lead.email).id;
//                    objP.Country__c = lead.Country_of_Residence__c;
//                    lstPrefUpd.add(objP);
//                    lead.Status = 'Qualified';
//                }
//            }
//          }
    }//end of for Trigger.new loop
    
//    if(!lstPrefUpd.isempty()) insert lstPrefUpd;
}
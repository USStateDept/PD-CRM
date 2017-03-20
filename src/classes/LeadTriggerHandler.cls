public class LeadTriggerHandler {
    Final static String PREFIX_ACCOUNT_NAME = 'Mission ';
    Final static String YSEALI_LEAD_SOURCE = 'YSEALI';
    Final static String SHAREAMERICA_LEAD_SOURCE = 'IIP ShareAmerica';
    Final static String YALI_LEAD_SOURCE = 'YALI';

    
    public static void beforeActivity(List<Lead> lstLead){

        Map<String,Contact> mapContact = new Map<String,Contact>();
        Map<String,Account> mapAccount= new Map<String,Account>();
        
        List<String> lstEmail = new List<String>();
        List<String> lstAccountName = new List<String>();
        List<Contact> lstContact = new List<Contact>();
        List<Contact> lstUpdateContact = new List<Contact>();


        for(Lead objl:lstLead){ //Get all email Id's and put it in map
        
        	lstEmail.add(objl.Email);
            
            String countryName = objl.Country__c;
            if(objl.LeadSource == 'YALI'){
	        	if(objl.Country == null){
	            	countryName = objl.Country__c;
	            }
	            else{
	               	countryName = objl.Country;
	            }
        	}              
        	
            if(String.isNotEmpty(countryName) && countryName.containsIgnoreCase('Lao')) {
                countryName = 'Laos';
            }
            lstAccountName.add(PREFIX_ACCOUNT_NAME + countryName);
            lstAccountName.add(SHAREAMERICA_LEAD_SOURCE);
        }
        //Get contacts of email 
        for(Contact ct : [select id, name, Accountid, account.name,email from Contact where email IN:lstEmail]){
            mapContact.put(ct.email,ct);
        }

        //Get all the Accounts with that name
        for(Account ac : [select id, name from Account where Name IN:lstAccountName]){
            mapAccount.put(ac.name,ac);
        }
        
        for(Lead lead : lstLead) {System.debug('incoming lead...'+lead);
            if(String.isEmpty(lead.Company))
                lead.Company = 'Household';
            if(String.isEmpty(lead.Status))
                lead.Status = 'Open';
            if(String.isEmpty(lead.LeadSource ))
                lead.LeadSource = 'Web';
            if(String.isEmpty(lead.LastName))
                lead.LastName = 'N.A';
            if(String.isNotEmpty(lead.Interests__c)) {
                if(lead.Interests__c.contains('Education')) {
                    List<String> interestParts = (lead.Interests__c).split(';');
                    if(interestParts != null) {
                        String updatedInterests = '';
                        for(String interest : interestParts) {
                            if(interest != null && interest.equalsIgnoreCase('Education')) {
                                interest = interest.replace('Education','Education/Libraries');
                                updatedInterests += interest + ';';
                            }
                            else {
                                updatedInterests += interest + ';';
                            }
                        }
                        
                        Integer lastIndex = updatedInterests.lastIndexOf(';');
                        if(lastIndex != -1)
                            updatedInterests = updatedInterests.removeEnd(';');

                        lead.Interests__c = updatedInterests;
                    }//end of interestParts
                }//end of interests contains 'Education'
            }//end of interest
          
system.debug('Satya---' +lead.YALI_CertificateCode__c + ',' + lead.LeadSource + ',' + lead.Status+ ',' + lead.Country);
            if(lead.Status == 'Qualified' || (lead.LeadSource == 'YALI' && (lead.YALI_CertificateCode__c != '' && lead.YALI_CertificateCode__c != null))){
            	if(mapContact.get(lead.email)!=null){   //If Contact Available
            		for(String s: mapContact.KeySet()){
            			Contact con = mapContact.get(s);
            			if(String.isNotEmpty(lead.FirstName)){
            				con.FirstName = lead.FirstName;
            			}
            			if(String.isNotEmpty(lead.LastName)){
            				con.LastName = lead.LastName;
            			}
            			if(String.isNotEmpty(lead.Country)){
            				con.MailingCountry = lead.Country;
            			}
            			if(String.isNotEmpty(lead.Formal_Name__c)){
            				con.Formal_Name__c = lead.Formal_Name__c;
            			}
            			if(String.isNotEmpty(lead.Street)){
            				con.MailingStreet = lead.Street;
            			}
            			if(String.isNotEmpty(lead.City)){
            				con.MailingCity = lead.City;
            			}
            			if(String.isNotEmpty(lead.State)){
            				con.MailingState = lead.State;
            			}
            			if(String.isNotEmpty(lead.PostalCode)){
            				con.MailingPostalCode = lead.PostalCode;
            			}
            			if(String.isNotEmpty(lead.YALI_Ad_Referral__c)){
            				con.YALI_Ad_Referral__c = lead.YALI_Ad_Referral__c;
            			}
            			if(String.isNotEmpty(lead.YALI_Ad_Content_Referrer__c)){
            				con.YALI_Ad_Content_Referrer__c = lead.YALI_Ad_Content_Referrer__c;
            			}
            			if(String.isNotEmpty(lead.YALI_Ad_Medium_Referrer__c)){
            				con.YALI_Ad_Medium_Referrer__c = lead.YALI_Ad_Medium_Referrer__c;
            			}
            			if(String.isNotEmpty(lead.YALI_Ad_Source_Referrer__c)){
            				con.YALI_Ad_Source_Referrer__c = lead.YALI_Ad_Source_Referrer__c;
            			}
            			if(String.isNotEmpty(lead.YALI_CertificateCode__c)){
            				con.YALI_CertificateCode__c = lead.YALI_CertificateCode__c;
            			}
            			if(lead.LeadSource == 'YALI'){
            				con.YALI_Member__c = true;
            			}
            			if(lead.LeadSource == 'YLAI'){
            				con.YLAI_Member__c = true;
            			}
            			if(lead.LeadSource == 'YSEALI'){
            				con.YSEALI_Member__c = true;
            			}
            			if(String.isNotEmpty(lead.Region__c)){
            				con.Region__c = lead.Region__c;
            			}
            			if(String.isNotEmpty(String.valueof(lead.Birthdate__c))){
            				con.Birthdate = lead.Birthdate__c;
            			}
            			if(String.isNotEmpty(lead.Country__c)){
            				con.Citizenship__c = lead.Country__c;
            			}
            			if(String.isNotEmpty(lead.Interests__c)){/////need to update interests
            				con.Interests__c = lead.Interests__c;
            			}
            			lstUpdateContact.add(con);
            		}
            	}
            	else{
					String leadSource = lead.LeadSource;					
	                //If No Contact, create contact
	                Contact ct = new Contact();
	                ct.FirstName = lead.FirstName;
	                ct.LastName = lead.LastName;        
	                ct.Email = lead.Email;
	                ct.LeadSource = leadSource;
	                ct.Spoken_Languages__c = lead.Language__c;
           			if(lead.LeadSource == 'YALI'){
           				ct.YALI_Member__c = true;
           			}
           			if(lead.LeadSource == 'YLAI'){
           				ct.YLAI_Member__c = true;
           			}
           			if(lead.LeadSource == 'YSEALI'){
           				ct.YSEALI_Member__c = true;
           			}
	
	                if(String.isNotEmpty(lead.Interests__c)) {
	                	if(lead.Interests__c.contains('Community/Climate'))
	                    	lead.Interests__c = lead.Interests__c.replace('Community/Climate','Environment/Climate');
	                    if(lead.Interests__c.contains('Local/Government'))
	                        lead.Interests__c = lead.Interests__c.replace('Local/Government','Local Government');
	                    if(lead.Interests__c.contains('Community/Libraries'))
	                        lead.Interests__c = lead.Interests__c.replace('Community/Libraries','Education/Libraries');
	                    ct.Interests__c = lead.Interests__c;
					}
					                
	                if(lead.Birthdate__c != null)
	                	ct.Birthdate = lead.Birthdate__c;
	                    
	                String countryName = lead.Country__c;
	                if(String.isNotEmpty(countryName) && countryName.containsIgnoreCase('Lao')) {
	                   	countryName = 'Laos';
	                }
	                    
	                String missionName;
	                if(leadSource.equalsIgnoreCase(SHAREAMERICA_LEAD_SOURCE)) {
	                	missionName = SHAREAMERICA_LEAD_SOURCE;
	                }
	                else if(leadSource == 'YALI'){
	                	if(lead.Country == null){
	                		missionName = PREFIX_ACCOUNT_NAME + lead.Country__c;
	                	}
	                	else{
	                    	missionName = PREFIX_ACCOUNT_NAME + lead.Country;
	                	}
	                }
	                else{
	                    missionName = PREFIX_ACCOUNT_NAME + countryName;
	                }

	
				    //YALI
	                if(leadSource.equalsIgnoreCase(YALI_LEAD_SOURCE)){
	                	ct.YALI_Ad_Referral__c = lead.YALI_Ad_Referral__c;
	                    ct.YALI_CertificateCode__c = lead.YALI_CertificateCode__c;
	                   	if(lead.Country == null){
	                		ct.MailingCountry = lead.Country__c;
	                	}
	                	else{
	                    	ct.MailingCountry = lead.Country;
	                	}
	                    ct.MailingCity = lead.City;
	                    ct.Gender__c = lead.Gender__c;
	                    ct.Birthdate = lead.Birthdate__c;
	                    ct.Formal_Name__c = lead.Formal_Name__c;
	            		//lead.Country__c = lead.Country;
					}
	                
	                //YSEALI
	
	                if(leadSource.equalsIgnoreCase(YSEALI_LEAD_SOURCE))
	                	ct.Citizenship__c = lead.Country__c;    
	                	
system.debug('mapAccount---' +mapAccount);	                    
system.debug('malla---' +missionName + ',' + mapAccount.containsKey(missionName) + ',' + String.isEmpty(missionName));	                    
					//Check if account exists
					if(!mapAccount.containsKey(missionName)){
	                	if(!String.isEmpty(missionName)) {
		                    //If No Account Create account
		                    Account ac = new Account();
		                    ac.name = missionName;
		                    insert ac;
		                    ct.AccountId = ac.id;
	                    }
					}
	                else {
	                //If Account exists
	                	ct.AccountId = mapAccount.get(missionName).id;
					}
					lstContact.add(ct);
            	}                      
			}
		}//end of for Trigger.new loop
        
		//insert contacts
        if(!lstContact.isempty() && lstContact.size() > 0){
            insert lstContact;
        }
        
        //update contacts
        if(lstUpdateContact.size() > 0){
            update lstUpdateContact;
        }
        
    }
}
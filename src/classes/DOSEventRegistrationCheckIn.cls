public with sharing class DOSEventRegistrationCheckIn {
    public Id strEventId;    
    public Id strEventRegId;
    public Event__c objEvent;
    private transient ApexPages.Message currentMsg;
    private String eventStatus;
    private String eventType;
    
    public String sEventName {get;set;}
    public String sEventDesc {get;set;}
    
    public boolean showMainPage {get;set;}
    public boolean showThankYouPage{get;set;}
    public boolean showGuestsTable{get;set;}
    public boolean showErrorPage{get;set;}
    public boolean showCheckedIn{get;set;}
    
    public string FirstName{get;set;}
    public string LastName{get;set;}
    public string Email{get;set;}


    public Event_Registration__c objER{get;set;}  
    
    //Mission Address fields
    public string sEmbassyAddress{get;set;}
    public string sEmbassyPhone{get;set;}
    public string sEmbassyWebsite{get;set;}
    public string sEmbassyCountry{get;set;}

    public String sEventDisplayName{
        get{
                String fullURL = ApexPages.currentPage().getUrl();
                System.debug('fullURL: '+fullURL);
                String sTemp = fullURL.substringBetween('?','=');               
                return sTemp;
        }
        set;
    }
    
    
    public DOSEventRegistrationCheckIn(ApexPages.StandardController controller) {
    	
		showGuestsTable = true;
		showThankYouPage = false;
    	showErrorPage = false;
    	showCheckedIn = false;
    	
        strEventId = ApexPages.currentPage().getParameters().get('id');
        if(sEventDisplayName != null){
            strEventRegId = ApexPages.currentPage().getParameters().get('erid');
            if(strEventId != null)
                objEvent = [Select Id, Name, Event_Description__c, Status__c,Event_Type__c,Capacity_Full__c,OwnerId, Is_Past_Event__c, Disable_RSVP_Page__c,Show_Map__c, Host_Account__r.Id from Event__c where Id = :strEventId];
            else
                objEvent = [Select Id, Name, Event_Description__c, Status__c,Event_Type__c,Capacity_Full__c,OwnerId, Is_Past_Event__c, Disable_RSVP_Page__c,Show_Map__c, Host_Account__r.Id from Event__c where Display_Name__c = :sEventDisplayName]; 
          
            strEventId = objEvent.Id;
            sEventName = objEvent.Name;
            sEventDesc = objEvent.Event_Description__c;
            
            //Get Embassy Address for displaying in header/footer
            User currentUser;
            ID sAccountId = objEvent.Host_Account__r.Id;
            getEmbassyDetails(sAccountId);

            eventStatus = objEvent.Status__c;
            eventType = objEvent.Event_Type__c;
            //Hide the RSVP Page if it is either a past event or disabled event 
            Boolean bDisable = ((objEvent.Disable_RSVP_Page__c == true) || (objEvent.Is_Past_Event__c == true))? true : false;
    
            if(eventStatus  == 'Cancelled' || eventStatus  == 'Completed' || eventStatus  == 'Draft' || bDisable == true){
                showMainPage = false;
            }
            else if(objEvent.Capacity_Full__c == 100){
                showMainPage = false;
            }             
            else{                
                showMainPage = true;              
            } 
            
        }
        else
        {
            String msg = 'Event Id cannot be blank. Please make sure you have it in the URL';
            currentMsg = new ApexPages.Message(ApexPages.severity.WARNING, msg);
            ApexPages.addMessage(currentMsg);
            showMainPage = true;
        } 
    }
    
    
    public PageReference onAccept(){
//        List<Event_Registration__c> eventReg = [Select Id from Event_Registration__c where Attendee_First_Name__c = :FirstName and Attendee_Last_Name__c = :LastName and
//        												Contact_Email__c = :Email and Event__c = :strEventId];

        List<Event_Registration__c> eventReg = [Select Id from Event_Registration__c where (Contact_Email__c = :Email or Preferred_Email__c = :Email) and Event__c = :strEventId];
		
        if(eventReg.size() >0){
//        	Event_Registration__c updEventReg = [Select Id,Status__c from Event_Registration__c where Attendee_First_Name__c = :FirstName and Attendee_Last_Name__c = :LastName and
//        												Contact_Email__c = :Email and Event__c = :strEventId];

       		Event_Registration__c updEventReg = [Select Id,Status__c,Attendee_First_Name__c,Attendee_Last_Name__c
        													 from Event_Registration__c where (Contact_Email__c = :Email or Preferred_Email__c = :Email) and Event__c = :strEventId];
			if(updEventReg.Status__c == 'Attended'){
	        	FirstName = updEventReg.Attendee_First_Name__c;
	        	LastName = updEventReg.Attendee_Last_Name__c;
	        	Email = '';
	        	showErrorPage = false;
	        	showThankYouPage = false;
	        	showCheckedIn = true;
	        	return ApexPages.currentPage();				
			}
			else{
	        	FirstName = updEventReg.Attendee_First_Name__c;
	        	LastName = updEventReg.Attendee_Last_Name__c;
	        	updEventReg.Status__c = 'Attended';
	        	update updEventReg;
	        	Email = '';
	        	showThankYouPage = true;
	        	showErrorPage = false;
	        	showCheckedIn = false;
	        	return ApexPages.currentPage();
			}
        }
        else{
        	FirstName = '';
        	LastName = '';
        	Email = '';
        	showErrorPage = true;
        	showThankYouPage = false;
        	showCheckedIn = false;
        	return ApexPages.currentPage();
        }
    }
    

    public void getEmbassyDetails(ID sAccountId)
    {
        String sRoleName;
        List<Account> lstAccount;
        List<UserRole> lstRole;
        system.Debug('sAccountId: '+sAccountId);
        lstRole = [Select Id, Name from userrole where Id IN (Select UserRoleId from User where Id = :objEvent.OwnerId)];
        if(sAccountId == null)
        {        
            
            if(lstRole.size() > 0){
                lstAccount = [Select Id, Name,Mailing_Address__c,Phone,Website from Account where Name =: lstRole[0].Name LIMIT 1];
            }
        }
        else
            lstAccount = [Select Id, Name,Mailing_Address__c,Phone,Website from Account where Id =: sAccountId LIMIT 1];
                        
        
        if(lstAccount.size() > 0){
            sEmbassyAddress = lstAccount[0].Mailing_Address__c;
            sEmbassyPhone = lstAccount[0].Phone;
            sEmbassyWebsite = lstAccount[0].Website;
            if((lstRole[0].Name.length() > 7) && (lstRole[0].Name.substring(0,7) == 'Mission'))
                sEmbassyCountry = lstRole[0].Name.substring(8,lstRole[0].Name.length());
            else
                sEmbassyCountry = lstRole[0].Name;                   
        }   
    }  
         
}
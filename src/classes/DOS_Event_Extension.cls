public class DOS_Event_Extension {
    
    public Id strEventId;    
    public Id strEventRegId;
    public Event__c objEvent;
    private transient ApexPages.Message currentMsg;
    private String eventStatus;
    private String eventType;
    
    public String sEventName {get;set;}
    public String sEventDesc {get;set;}
    public String sStreetAddress {get;set;}
    public String sStreetAddress2 {get;set;}
    public String sCity {get;set;}
    public String sState {get;set;}
    public String sPostalCode {get;set;}
    public Boolean sMap {get;set;}
    public Integer iGuestCount {get;set;}
    
    public Boolean showSection2{get;set;}
    public Boolean showSection3{get;set;}    
    public boolean showMainPage {get;set;}
    public boolean showSorryPage {get;set;}
    public boolean showThankYouPage{get;set;}
    public boolean showContactPage{get;set;}
    public boolean showGuestPage{get;set;}
    public boolean addGuests{get;set;}
    public boolean showGuestsTable{get;set;}
    
    public string FirstName{get;set;}
    public string LastName{get;set;}
    public string Email{get;set;}
    public string Mobile{get;set;}   

    public Event_Registration__c objER{get;set;}  
    public string startDate{get;set;}    
    public string endDate{get;set;}
    
    //Mission Address fields
    public string sEmbassyAddress{get;set;}
    public string sEmbassyPhone{get;set;}
    public string sEmbassyWebsite{get;set;}
    public string sEmbassyCountry{get;set;}
    public Boolean showMap{get;set;}
    public List<guestWrapper> guests{get;set;}  
    public String sEventDisplayName{
        get{
                String fullURL = ApexPages.currentPage().getUrl();
                System.debug('fullURL: '+fullURL);
                String sTemp = fullURL.substringBetween('?','=');               
                return sTemp;
        }
        set;
    }
    
    public class guestWrapper{
        public Integer recCount{get;set;}
        public String firstName {get;set;}
        public String lastName {get;set;}
        public String email {get;set;}
        public String mobile {get;set;}
        
        public guestWrapper(Integer intCount){
             recCount = intCount;                                
        }
        
    }  
    //public String sEventName {get;set;}
    
    public DOS_Event_Extension(ApexPages.StandardController controller) {
    
        strEventId = ApexPages.currentPage().getParameters().get('id');
        addGuests = false;
        showGuestsTable = false;
        if(sEventDisplayName != null){
            strEventRegId = ApexPages.currentPage().getParameters().get('erid');
            if(strEventId != null)
                objEvent = [Select Id, Name, Event_Description__c, Street_Address__c, Street_Address2__c, City__c, State__c, Postal_Code__c, Status__c,Event_Type__c,Capacity_Full__c,Event_End_Date__c,Event_Start_Date__c,OwnerId,Show_Map__c,Disable_RSVP_Page__c, Is_Past_Event__c, No_of_guests_allowed__c,Is_Guests_Allowed__c, Host_Account__r.Id from Event__c where Id = :strEventId];
            else
                objEvent = [Select Id, Name, Event_Description__c, Street_Address__c, Street_Address2__c, City__c, State__c, Postal_Code__c, Status__c,Event_Type__c,Capacity_Full__c,Event_End_Date__c,Event_Start_Date__c,OwnerId,Show_Map__c,Disable_RSVP_Page__c, Is_Past_Event__c, No_of_guests_allowed__c,Is_Guests_Allowed__c, Host_Account__r.Id from Event__c where Display_Name__c = :sEventDisplayName]; 
          
            strEventId = objEvent.Id;
            sEventName = objEvent.Name;
            sEventDesc = objEvent.Event_Description__c;
            sStreetAddress = objEvent.Street_Address__c;
            sStreetAddress2 = objEvent.Street_Address2__c;
            sCity = objEvent.City__c;
            sState = objEvent.State__c;
            sPostalCode = objEvent.Postal_Code__c;
            sMap = objEvent.Show_Map__c;
            iGuestCount = Integer.valueOf(objEvent.No_of_guests_allowed__c);
            
            
            guests = new List<guestWrapper>();
            if(objEvent.Is_Guests_Allowed__c == true){
                Integer iGuests = Integer.valueOf(objEvent.No_of_guests_allowed__c);
                initGuests(iGuests);
                addGuests = true;
            }
            //Get Embassy Address for displaying in header/footer
            User currentUser;
            ID sAccountId = objEvent.Host_Account__r.Id;
            getEmbassyDetails(sAccountId);
            if(objEvent != null)
                currentUser = [Select TimeZoneSidKey from User where id =: objEvent.OwnerId];
            DateTime myDateTime = DateTime.newInstance(1993, 6, 6, 3, 3, 3);
            if(objEvent.Event_Start_Date__c != null)
                startDate = objEvent.Event_Start_Date__c.format('M/d/yyyy h:mm a',currentUser.TimeZoneSidKey); //'MMM dd yyyy HH:MM a'
                //startDate = objEvent.Event_Start_Date__c;
            if(objEvent.Event_End_Date__c != null)
                endDate = objEvent.Event_End_Date__c.format('M/d/yyyy h:mm a',currentUser.TimeZoneSidKey);
            if(strEventRegId != null)
                objER = [Select Id, Status__c, QR_Code__c from Event_Registration__c where Id = :strEventRegId];
            eventStatus = objEvent.Status__c;
            eventType = objEvent.Event_Type__c;
            //Hide the RSVP Page if it is either a past event or disabled event 
            Boolean bDisable = ((objEvent.Disable_RSVP_Page__c == true) || (objEvent.Is_Past_Event__c == true))? true : false;
    
            if(eventStatus  == 'Cancelled' || eventStatus  == 'Completed' || eventStatus  == 'Draft' || bDisable == true){
                showSection2 = true;
                showMainPage = false;
                showSection3 = false;                
            }
            else if(objEvent.Capacity_Full__c == 100){
                showSection2 = false;
                showMainPage = false;
                showSection3 = true;            
            }             
            else{
                showSection2 = false;                
                showMainPage = true;
                showSection3 = false;
                if(eventType  == 'Public' && strEventRegId == null)
                    showContactPage = true;
                
                //Show the map based on the preference set on Event
                if(objEvent.Show_Map__c == true)
                    showMap = true;
                else
                    showMap=false;                               
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
    
    
    public void onAccept(){
        
        String pageName;                       
        if(eventType  == 'Public' && strEventRegId == null){            
            onSubmitYes();
                                       
        }
        else
        {
            if(strEventRegId != null && objER != null){
                objER.Status__c = 'Accepted';                 
                update objER;                    
            }    
            
            showMainPage = false;
            showSection2 = false;
            showSection3 = false;             
            showThankYouPage = true;
            showSorryPage = false;   
        } 
        
        //Add the guests to the Event Registrations under the event.
        if(guests.size() > 0)
                addGuestsToEvent(guests);          
    
    }
    
    public void onDecline(){
        
        if(strEventRegId != null){ 
            objER.Status__c = 'Declined';           
            update objER;        
        }      
        
        showSection2 = false;
        showSection3 = false; 
        showMainPage = false; 
        showSorryPage = true;

    }
    /*public PageReference getPage(String inpPageName){
        
        String pageName = '/apex/'+ inpPageName;
        PageReference dirpage= new PageReference(pageName);
        dirpage.setRedirect(true);        
        return dirpage;
    }*/
    
    public void onSubmitYes(){       
        
        Boolean isValidInput = true;
        String msg;
        
        if(LastName == null || LastName == '')
        {
            msg = 'Last Name  cannot be blank. Please enter value in it';
            currentMsg = new ApexPages.Message(ApexPages.severity.WARNING, msg);
            ApexPages.addMessage(currentMsg);
            showMainPage = true;
            showContactPage = true;
            isValidInput = false;
        }
        
        if(Email == null || Email == '')
        {
            msg = 'Email cannot be blank. Please enter value in it';
            currentMsg = new ApexPages.Message(ApexPages.severity.WARNING, msg);
            ApexPages.addMessage(currentMsg);
            showMainPage = true;
            showContactPage = true;
            isValidInput = false;
        }
        else
        {
            isValidInput = checkEmail(Email); 
            //if(!isValidInput){       
                //showMainPage = true;
                //showContactPage = true;
            //}            
        }
            
        
        if(isValidInput)
        {   
          
            //update Event Registration
            if(strEventRegId != null){
                System.debug('strEventRegId: ' + strEventRegId);
                objER.Status__c = 'Accepted';
                update objER;
            }
            else
            {
                List<Contact> objContact = [select Id from Contact where Email = :Email];
            
                if(objContact.size() > 0){
                    if(!isEventRegistrationExists(strEventId, objContact.get(0).Id)){
                        Id newERId;
                        newERId = createEventRegistration(strEventId, objContact.get(0).Id, Email, null);
                        System.Debug('Event Registration created successfully Id: '+newERId);
                    }
                }
                else
                {
                    Event__c objEvent = [Select Id, Name, OwnerId from Event__c where Id = :strEventId];
                    List<UserRole> lstRole = [Select Id, Name from userrole where Id IN (Select UserRoleId from User where Id = :objEvent.OwnerId)];
                    System.Debug('lstRole.size(): '+lstRole.size());
                    if(lstRole.size() > 0){
                        Id sAccountId;
                        List<Account> accList = [Select Id, Name from Account where Name =: lstRole[0].Name LIMIT 1];
                        if(accList.size() > 0)sAccountId =  accList[0].Id;              
                        Id newContactId, newERId;
                        newContactId = createContact(FirstName, LastName, Email,Mobile, objEvent.OwnerId, sAccountId);
                        System.Debug('Contact created successfully Id: '+ newContactId );
                        newERId = createEventRegistration(strEventId, newContactId, Email, null);
                        System.Debug('Event Registration created successfully Id: '+ newERId);
                            
                  }  
                }
                
                //Thank the user after capturing the response
                showMainPage = false;
                showContactPage = false;     
                showThankYouPage = true;                
            } 
        }
        else
        {
            showMainPage = true;
            showContactPage = true;
        }        
         
    }     
    public Id createEventRegistration(String eventId, String contactId, String sEmail, String sComments){
    
        Event_Registration__c objNewER = new Event_Registration__c();
        objNewER.Event__c = eventId;
        if(contactId != null)
            objNewER.Contact__c = contactId;
         if(sEmail != null)   
                objNewER.Contact_Email_WF__c = sEmail;  
         if(sComments != null)
                objNewER.Comments__c = sComments;       
         objNewER.Status__c = 'Accepted';
         insert objNewER;
         
         return objNewER.Id;               
          
    
    } 
    public Id createContact(String firstName, String lastName, String email, String mobilePhone, Id ownerId, Id accountId){
    
        Contact objNewContact = new Contact();
        objNewContact.FirstName = firstName;
        objNewContact.LastName= lastName;
        objNewContact.Email = email;
        objNewContact.MobilePhone = mobilePhone;
        objNewContact.OwnerId = ownerId;
        objNewContact.AccountId = accountId;
        objNewContact.LeadSource = 'Event';           
        insert objNewContact;
        
        return objNewContact.Id;      
    
    }
    public Boolean checkEmail(String sEmail)
    {
        Boolean isValid = true;
        
        if(!Pattern.matches('^[a-zA-Z0-9._|\\\\%#~`=?&/$^*!}{+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,4}$', sEmail))
        {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING, 'Check your email format.'));
            isValid = false; 
        }
        return isValid;
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
    public Boolean isEventRegistrationExists(String sEventId, String sContactId){
        
        boolean bExists = false;       
        
        List<Event_Registration__c> lstER = [Select Id, Name from Event_Registration__c where Event__c =: sEventId AND Contact__c =: sContactId];
        
        if(lstER.size() > 0)
            bExists = true;
                        
        return bExists;
    } 
    public void addGuest(){     
        
        //Set this true so that Add Guests button gets diabled.     
        addGuests = false;
        showGuestsTable = true;
    }    
       
    //Resets the values on guest form  
    private void Reset(){
        /*GFirstName = null;
        GLastName = null;
        GEmail = null;
        GMobile = null;*/
    }    
     
     private void initGuests(Integer iCount){
                for(integer i=0; i<iCount; i++){
                        guestWrapper emptyGuest = new guestWrapper(i);
                        emptyGuest.firstName = null;
                        emptyGuest.lastName = null;
                        emptyGuest.Email = null;
                        emptyGuest.Mobile = null;
                        //emptyGuest.recCount = i+1;
                        guests.add(emptyGuest);
                }
     }
     
     public void addGuestsToEvent(List<guestWrapper> guestsToAdd){
        
        try{            
        
            List<Contact> lstContact = new List<Contact>();
            List<Event_Registration__c> lstERs = new List<Event_Registration__c>();
            List<Account> accList;
            Id newERId;
            //Event__c objEvent = [Select Id, Name, OwnerId from Event__c where Id = :strEventId];
            List<UserRole> lstRole = [Select Id, Name from userrole where Id IN (Select UserRoleId from User where Id = :objEvent.OwnerId)];
            System.Debug('lstRole.size(): '+lstRole.size());
            if(lstRole.size() > 0)
                accList = [Select Id, Name from Account where Name =: lstRole[0].Name LIMIT 1];
            
            for(Integer i = 0; i < guestsToAdd.size(); i++){
                String sEmail = guestsToAdd[i].email;
                if(sEmail != null && sEmail != ''){
                        
                        List<Contact> objContact = [select Id from Contact where Email = :sEmail];
                        
                        if(objContact.size() > 0){
                                if(!isEventRegistrationExists(strEventId, objContact.get(0).Id)){
                                    
                                    newERId = createEventRegistration(strEventId, objContact.get(0).Id, sEmail,null);
                                    System.Debug('Event Registration created successfully Id: '+newERId);
                                }
                        }
                        else{
                                Contact objNewContact = new Contact();
                                objNewContact.FirstName = guestsToAdd[i].firstName;
                                objNewContact.LastName= guestsToAdd[i].lastName;
                                objNewContact.Email = guestsToAdd[i].email;
                                objNewContact.MobilePhone = guestsToAdd[i].mobile;
                                objNewContact.OwnerId = objEvent.OwnerId; 
                                if(accList.size() > 0)
                                    objNewContact.AccountId = accList[0].Id;
                                objNewContact.LeadSource = 'Event';
                                lstContact.add(objNewContact);                  
                        }
                }
                else{
                        if(guestsToAdd[i].lastName != '' && guestsToAdd[i].lastName != null){
                                newERId = createEventRegistration(strEventId, null, null, guestsToAdd[i].firstName + ' ' + guestsToAdd[i].lastName);
                                System.debug('Successfully added guests for the event: ER Id: '+ newERId);
                        }
                }
                               
            }
            
            if(lstContact.size() > 0)
                insert lstContact;
            
            // Iterate through each returned result
            for (Integer i = 0; i < lstContact.size(); i++) {                
                    // Operation was successful, so get the ID of the record that was processed
                    System.debug('Successfully inserted contact. Contact ID: ' + lstContact[i].Id);
                    Event_Registration__c objNewER = new Event_Registration__c();
                    objNewER.Event__c = strEventId;
                    objNewER.Contact__c = lstContact[i].Id;
                    objNewER.Contact_Email_WF__c = lstContact[i].Email;
                    objNewER.Status__c = 'Accepted';
                    lstERs.add(objNewER);
                               
            }
            if(lstERs.size() > 0)
                insert lstERs;            
            System.debug('Successfully added guests for the event: ' + strEventId + ';No of guests added: '+lstERs.size());
         }
         catch(Exception e){
            String msg = 'Error occurred in addGuests method: ' + e.getMessage();            
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.WARNING, msg));
         }
         finally{
            //Cleanup1
         }
     } 
     
          
}
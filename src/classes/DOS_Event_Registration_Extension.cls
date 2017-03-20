public class DOS_Event_Registration_Extension {
	//nag
    public Id strEventRegId{get;set;}
    public Id strEventId{get;set;}
    public Id ContactId{get;set;}
    private Contact objContact{get;set;}
    public Event_Registration__c objER;
    
    //Contact Fields
    public string FirstName{get;set;}
    public string LastName{get;set;}
    public string Email{get;set;}
    public string Mobile{get;set;}
    public boolean eventOptOut{get;set;}    
    public string selectedValue{get;set;}
    private transient ApexPages.Message currentMsg;
    
    
    
    public DOS_Event_Registration_Extension(ApexPages.StandardController controller) {
    
        strEventRegId = ApexPages.currentPage().getParameters().get('id');
        strEventId = ApexPages.currentPage().getParameters().get('eventId');
        if(strEventRegId != null){
            objER = (Event_Registration__c )controller.getRecord();
            Event_Registration__c objEveReg = [Select Contact__r.id,Status__c from Event_Registration__c where Id = :strEventRegId];
            ContactId = objEveReg.Contact__r.id;
            if(objEveReg != null){
                objContact = [Select 
                                  FirstName, 
                                  LastName, 
                                  Email,
                                  MobilePhone                                  
                              from 
                                  Contact 
                              where Id = :ContactId];
                              
                if(objContact != null){
                    FirstName= objContact.FirstName;
                    LastName = objContact.LastName ;                    
                    Email = objContact.Email;
                    Mobile = objContact.MobilePhone;
                 }           
             }               
        }         

    }
    public PageReference onSubmit(){
        
        if(strEventRegId != null){
            objER.Status__c = 'Declined';
            update objER;        
        }        
   

        return getPage('EventRSVPThankYou');
    }
    
    public PageReference onSubmitYes(){
        
        if(FirstName == null || FirstName == '')
        {
            String msg = 'First Name cannot be blank. Please enter value in it';
            currentMsg = new ApexPages.Message(ApexPages.severity.WARNING, msg);
            ApexPages.addMessage(currentMsg);
            return null;
        }
        
        if(LastName == null || LastName == '')
        {
            String msg = 'Last Name  cannot be blank. Please enter value in it';
            currentMsg = new ApexPages.Message(ApexPages.severity.WARNING, msg);
            ApexPages.addMessage(currentMsg);
            return null;
        }
        
        if(Email == null || Email == '')
        {
            String msg = 'Email cannot be blank. Please enter value in it';
            currentMsg = new ApexPages.Message(ApexPages.severity.WARNING, msg);
            ApexPages.addMessage(currentMsg);
            return null;
        }
        
        if(Mobile == null || Mobile == '')
        {
            String msg = 'Mobile cannot be blank. Please enter value in it';
            currentMsg = new ApexPages.Message(ApexPages.severity.WARNING, msg);
            ApexPages.addMessage(currentMsg);
            return null;
        }
            
        //update Event Registration
        if(strEventRegId != null){
            objER.Status__c = 'Accepted';
            update objER;
        }
        else
        {
            List<Contact> objContact = [select Id from Contact where Email = :Email];
        
            if(objContact.size() > 0){
            
                Id newERId;
                newERId = createEventRegistration(strEventId, objContact.get(0).Id);
                System.Debug('Event Registration created successfully Id: '+newERId);
            }
            else
            {
                Id newContactId, newERId;
                newContactId = createContact(FirstName, LastName, Email,Mobile);
                System.Debug('Contact created successfully Id: '+newContactId );
                newERId = createEventRegistration(strEventId, newContactId );
                System.Debug('Event Registration created successfully Id: '+newERId);
                
            }
            
        }    
        
        return getPage('EventRSVPThankYou');    
                

        
    }
    public PageReference onCancel(){
    
        return getPage('EventRSVPThankYou');
    
    }
    public PageReference getPage(String inpPageName){
        
        String pageName = '/apex/'+ inpPageName;
        PageReference dirpage= new PageReference(pageName);
        dirpage.setRedirect(true);        
        return dirpage;
    }
    public Id createEventRegistration(String eventId, String contactId){
    
        Event_Registration__c objNewER = new Event_Registration__c();
        objNewER.Event__c = eventId;
        if(contactId != null)
            objNewER.Contact__c = contactId;
         objNewER.Status__c = 'Accepted';
         insert objNewER;
         
         return objNewER.Id;               
          
    
    } 
    public Id createContact(String firstName, String lastName, String email, String mobilePhone){
    
        Contact objNewContact = new Contact();
        objNewContact.FirstName = firstName;
        objNewContact.LastName= lastName;
        objNewContact.Email = email;
        objNewContact.MobilePhone = mobilePhone;        
        insert objNewContact;
        
        return objNewContact.Id;      
    
    }   
  

}
public class PDCRM_PrintEventGuestList {

    public Id strEventId;
    public Id strEventRegId;
    public Event__c objEvent;
    
    public string EventName{get;set;}
    public string NoOfAccepted{get;set;}
    public string capacity{get;set;}
    public string host{get;set;}
    public string startDate {get;set;}
    public string endDate{get;set;}
    public string declined{get;set;}
    public boolean guests{get;set;}
    public string location{get;set;}

            
    public string FirstName{get;set;}
    public string LastName{get;set;}
    public string Email{get;set;}
    public string Mobile{get;set;}
    public string Status{get;set;}

    public List<appWrapper> accRegistrations {get;set;}   

    public List<Event_Registration__c> objER;    

    public PDCRM_PrintEventGuestList(ApexPages.StandardController controller) {
    
        strEventId = ApexPages.currentPage().getParameters().get('id');
        if(strEventId != null){
            strEventRegId = ApexPages.currentPage().getParameters().get('erid');
            objEvent = [Select Id, Status__c,Event_Type__c,Event_End_Date__c,Event_Start_Date__c,Name,OwnerId,Total_Number_of_Accepted_Attendees__c,Maximum_Registration__c,
            					Event_Host__r.Name,Total_Number_of_Declined_Attendees__c,Is_Guests_Allowed__c,
            					Street_Address__c,Street_Address2__c,City__c,State__c,Postal_Code__c from Event__c where Id = :strEventId];
            EventName = objEvent.Name;
            NoOfAccepted = String.valueof(objEvent.Total_Number_of_Accepted_Attendees__c);
			capacity = String.valueof(objEvent.Maximum_Registration__c);
			host = objEvent.Event_Host__r.Name;
			startDate = String.valueof(objEvent.Event_Start_Date__c);
			endDate = String.valueof(objEvent.Event_End_Date__c);			
			declined = String.valueof(objEvent.Total_Number_of_Declined_Attendees__c);
			guests = objEvent.Is_Guests_Allowed__c;
			location = objEvent.Street_Address__c + ' ' +  objEvent.Street_Address2__c + ', ' +objEvent.City__c + ', ' + objEvent.State__c +  ', ' + objEvent.Postal_Code__c;
			
			objER = [Select Status__c,Contact_Name__c,Contact_Email__c,Attendee_Mobile_Phone__c
						 from Event_Registration__c where Event__c = :strEventId order by Status__c asc ];                       
        }
    }

    public List<appWrapper> getEveRegs (){
        
        accRegistrations = null;
        if(accRegistrations == null){
            accRegistrations = new List<appWrapper>();
        }
        for (Event_Registration__c a: this.objER) {
            appWrapper aw = new appWrapper();
            aw.er = a;
            aw.cSelect = false;
            accRegistrations.add(aw);
        }
        return accRegistrations;
    }

    public class appWrapper{
        public Event_Registration__c er {get;set;}
        public boolean cSelect {get;set;}
    }
    
    
}
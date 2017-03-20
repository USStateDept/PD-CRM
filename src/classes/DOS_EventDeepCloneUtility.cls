public class DOS_EventDeepCloneUtility {

    public DOS_EventDeepCloneUtility(ApexPages.StandardController controller) {

    }   
   
   public PageReference cloneEvent() 
    {
        // setup the save point for rollback
        Savepoint sp = Database.setSavepoint();
    try{    
        PageReference clonedEvent;    
        ID sEventId = Apexpages.currentPage().getParameters().get('Id');
        Event__c oldEvent = [select Id, Name, Display_Name__c,Event_Type__c, Event_Start_Date__c, Event_End_Date__c, Event_Description__c, Maximum_Registration__c, Show_Map__c, Street_Address__c, Street_Address2__c,  City__c, State__c, Postal_Code__c, Country__c, No_of_guests_allowed__c from Event__c where Id =: sEventId];
        List<Event_Registration__c> lstER = [Select Id, Name, Contact__c from Event_Registration__c where Event__c = :sEventId];
        System.Debug('Number of ERs: '+ lstER.size());
        Event__c newEvent = oldEvent.clone(false, true); //do a deep clone
        //insert the event record
        Datetime tsToday = Datetime.now();
        String myDate = tsToday.format('MMDDYYYYhh-mm-ss');
        System.debug('myDate: '+ myDate);
        newEvent.Display_Name__c = myDate;
        insert newEvent;
        System.debug('New Event Id: '+ newEvent.Id);
        
        if(lstER.size() > 0){
                //insert Event Registration records
                List<Event_Registration__c> copiedERList = new List<Event_Registration__c>(); 
                for(Event_Registration__c eve : lstER){
                    Event_Registration__c newER = eve.clone(false, true);
                    newER.Event__c = newEvent.Id;                   
                    copiedERList.add(newER);                               
                }               
                insert copiedERList;
                System.debug('ERs added successfully for the event: '+ newEvent.Id);
        }       
        clonedEvent = new pagereference('/'+ newEvent.Id);
        System.debug('clonedEvent: '+ clonedEvent);
        clonedEvent.setRedirect(true);
        //String msg = 'Event got cloned successfully';            
        //ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.INFO, msg));          
        return clonedEvent; 
    }       
        catch(DmlException e){
                // roll everything back in case of error
                Database.rollback(sp);
                System.Debug(e.getMessage());
                String msg = 'Event can not be cloned due to a system error. Please contact your administrator';            
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, msg));
                return null;
           }     
     
    }    
}
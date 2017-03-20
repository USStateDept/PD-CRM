public with sharing class DOSAddEventController {
    
   private final ApexPages.StandardSetController cntr;
   private final PageReference fromPage;
   private final List<Contact> objs;   
   private transient ApexPages.Message currentMsg;
   private final String newLine ='<br></br>';
   
   private Integer listSize=20; //listSize determines the number of records to display.
   private Integer eventCounter=0; // Determines how many records to be skipped
   private Integer eventTotalSize{get;set;} // Stores the total number of records in the org
   
   private String sType;  
   private String currentStep;   
   public List<Event__c> eventList {get;set;}
   public List<eveWrapper> openEvents {get;set;}
   public List<eveWrapper> selectedEvents {get;set;}
   public List<selectedRecords> Records = new List<selectedRecords>();
   //Keeps track of selected events during pagination
   Map <id,Event__c> selectedEventMap = new Map <id,Event__c>(); 
   private Map<String, ID>  mapERs = new  Map<String, ID>();
   private static boolean bypassERTrigger = false;
   
   public static Boolean isBypassER(){
   		return bypassERTrigger;
   }
   public Boolean DisablePreviousEvent
   {
        get{
            if(eventCounter <= 0)
                return true;
            else
                return false;           
                
        }
        set;
        
   }
   
   public Boolean DisableNextEvent
   {
        get{
            if((eventTotalSize <= listSize) || ((eventCounter +  listSize) >= eventTotalSize))
                return true;
            else
                return false;
        }
        set;
   }  
        
   public List<eveWrapper> getEvents(){
        
        openEvents = null;
        if(openEvents == null){
            openEvents = new List<eveWrapper>();
        }   
        for (Event__c e: this.eventList) {
            eveWrapper ew = new eveWrapper();
            ew.event = e;
            if(selectedEventMap .ContainsKey(e.id))
                ew.cSelect = true;
            else
                ew.cSelect = false;
            openEvents .add(ew);
        }       
        return(openEvents);          
    }
    
    public class eveWrapper{
        public Event__c event {get;set;}
        public boolean cSelect {get;set;}       
    }

    public class selectedRecords{
        public string Name;
        public string Id;
    }  
   
   public DOSAddEventController(ApexPages.StandardSetController controller) {
       currentStep = '1';
       controller.setPageSize(1000);
       cntr = (ApexPages.StandardSetController)controller;
       fromPage = cntr.cancel();
       if (this.objs == null) {
            this.objs = (List<Contact>)cntr.getSelected();
       }      
       
       
       if (getRecordSize()<1) {
            String msg = 'No record was selected on the list view.  Please click Previous button and select records for mass update.'; 
            currentMsg = new ApexPages.Message(ApexPages.severity.ERROR, msg);
       }
       String msg = 'No of Contacts selected:' + getRecordSize(); 
       currentMsg = new ApexPages.Message(ApexPages.severity.INFO, msg);
   
       getEventList();           
       ApexPages.addMessage(currentMsg);      
       
   }
   
    public String getStep() {
        return currentStep;
    }        
   
    public integer getRecordSize() {
     if (objs!=null) {
        return objs.size();
     } else {
        return 0;
     }
    }   
       
    public PageReference cancel() {
        return fromPage;
    }

    public PageReference step1() { 
        
        currentStep='1';         
        return ApexPages.currentPage();
    }
    
   public void getSelectedEvents(){
                
                if(openEvents.size() > 0){
                        if(selectedEvents == null)
                selectedEvents = new List<eveWrapper>();            
            for(Integer i=0;i<openEvents.size();i++){
                if(openEvents.get(i).cSelect == true && !selectedEventMap .ContainsKey(openEvents.get(i).event.Id)){                    
                    selectedEvents.add(openEvents[i]);
                    selectedEventMap.put(openEvents[i].event.Id, openEvents[i].event);
                }    
            }
        } 
   }   
   private void populateERMap(List<eveWrapper> sourceList){
   		
   		String queryExpr = '';
   		Integer i = 1;
   		if(sourceList.size() > 0){
   			
	   		for(eveWrapper e : sourceList){
	   			if(i < sourceList.size())
	   				queryExpr += '\'' + e.event.Id + '\',';
	   			else
	   				queryExpr += '\'' + e.event.Id + '\'';	
	   			i++;
	   		}
	   		//queryExpr = '';	
	   		system.debug('queryExpr: ' + queryExpr);
	   		
	   		String sQueryER = 'Select Event__r.Id, Contact__r.Id from Event_Registration__c where Event__c IN (' + queryExpr + ')';
	   		List<Event_Registration__c> sQueryResult = Database.query(sQueryER);
	   		
	   		//Integer i = 1;
	   		for(Event_Registration__c er : sQueryResult){
	   			String concatEC = (String)er.Event__c + (String)er.Contact__c;
	   			mapERs.put(concatEC, er.Id);
	   			//i++;
	   		}
	   		system.debug('mapERs:' + mapERs);
	   	}   		
   	
   } 
   public PageReference step4() {
        
        getSelectedEvents();        
        
        List<Event_Registration__c> erList = new List<Event_Registration__c>();
        String sEventNames = '';
        Id sPreviousEvent = null;
        if(selectedEvents.size() > 0){
            populateERMap(selectedEvents);
            for(Integer i=0;i<selectedEvents.size();i++){
                 for(Integer j=0;j<objs.size();j++){
                 		String concatEC = (String)selectedEvents[i].event.Id + (String)objs[j].Id;
                        //if(!isInviteeRegistered(selectedEvents[i].event.Id, objs[j].Id))
                        if(!mapERs.containsKey(concatEC))
                        { 
                                Event_Registration__c er = new Event_Registration__c();
                            er.Contact__c = objs[j].Id;
                            er.Event__c = selectedEvents[i].event.Id;                            
                            if(sPreviousEvent != selectedEvents[i].event.Id){
                                 sPreviousEvent = selectedEvents[i].event.Id;
                                 sEventNames += selectedEvents[i].event.Name + '</br>'; 
                            }     
                            er.Status__c = 'Planned';                            
                            erList.add(er);
                        }
                   }                
            }
            if(erList.size() > 0){
            	try{
            	bypassERTrigger = true;
                Insert erList;
            	}
            	catch(DmlException e){
            		bypassERTrigger = false;
            		system.debug('Error while inserting ERs: ' + e.getMessage());
            	}
                bypassERTrigger = false;
            }
            
            //Call the web service to send the event info to Campaign Monitor
            for(Integer i=0;i<selectedEvents.size();i++){
            	system.debug('Event Id: '+ selectedEvents[i].event.Id);
            	if(selectedEvents[i].event.Status__c == 'Published')
            		CreateContactsInSegments.CreateContactsInList(selectedEvents[i].event.Id);
            }
        }
        
        
        
        String msg = 'Contacts are added successfully for the below Events: <br></br>' + sEventNames; 
        msg = msg + '<br><b>Number of Contacts Added: </b>' + erList.size() +'</br>';
        System.Debug('No of Event Registrations added: '+ erList.size());
        
        currentMsg = new ApexPages.Message(ApexPages.severity.INFO, msg);
        ApexPages.addMessage(currentMsg);
        currentStep='2';                
        return ApexPages.currentPage();
    } 
    
    public PageReference finish(){
    
        return fromPage;
    }
    
    public boolean isInviteeRegistered(String sEventId, String sContactId){
    
        boolean bExists = false;       
        
        List<Event_Registration__c> lstER = [Select Id, Name from Event_Registration__c where Event__c =: sEventId AND Contact__c =: sContactId];
        
        if(lstER.size() > 0)
            bExists = true;
            
        return bExists;   
    
    }
    
    public PageReference getEventList(){                     

        if(eventList !=null){
            eventList.clear();
        }
        if(eventTotalSize != 0){
            eventTotalSize = [Select count() from Event__c ];
        }
                
        eventList = [Select Id, Name, Event_Start_Date__c, Event_End_Date__c, Status__c from Event__c where Status__c in ('Draft','Published') AND (Capacity_Full__c < 100) order by createddate desc limit : listSize offset : eventCounter];
        openEvents = getEvents();
             
        return null;
    } 
    
    //Displays the next set of records
    public void nextEvent(){
    
        eventCounter = eventCounter + listSize;
        getSelectedEvents();
        getEventList();
    }
    
    //Displays the previous set of records
    public void previousEvent(){
        if(eventCounter > listSize)
                eventCounter = eventCounter - listSize;
        else
                eventCounter = 0;
        getSelectedEvents();            
        getEventList();
    }     
    
    //Displays the last set of records irrespective of current position
    public void  nextLastEvent(){
    
        if(math.mod(eventTotalSize, listSize) == 0){
            eventCounter = (eventTotalSize - listSize);
        }
        else if(math.mod(eventTotalSize, listSize) !=0) {
            eventCounter = (eventTotalSize - listSize);
        }    
        getSelectedEvents();
        getEventList();
    }
    
    //Displays the first set of records irrespective of current position
    public void previousFirstEvent(){
        eventCounter=0;
        getSelectedEvents();
        getEventList();
    } 
    
    
    
}
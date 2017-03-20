public with sharing class EventRegistrationCheckinExt {
	
    public Id strEventRegId {get;set;}
    public Event_Registration__c objEvent {get;set;}
    
           
    public string FirstName{get;set;}
    public string LastName{get;set;}
    public string Title{get;set;}
    public string Org{get;set;}
    public boolean showConf{get;set;}
    public boolean showGuest{get;set;}
	public boolean checkedin{get;set;}

    public EventRegistrationCheckinExt(ApexPages.StandardController controller) {
    	showGuest = false;
    	showConf = false;
    	checkedin = false;
        strEventRegId = ApexPages.currentPage().getParameters().get('fieldValue');
		system.debug('strEventRegId-- ' + strEventRegId);
        if(strEventRegId != null){

            objEvent = [Select Attendee_First_Name__c, Attendee_Last_Name__c,Attendee_Title__c,Attendee_Organization__c,QR_Code__c,Status__c
            				 from Event_Registration__c where Id = :strEventRegId];
            FirstName = objEvent.Attendee_First_Name__c;
            LastName = objEvent.Attendee_Last_Name__c;
            Title = objEvent.Attendee_Title__c;
            Org = objEvent.Attendee_Organization__c;
			if(objEvent.Status__c == 'Attended'){
		    	showGuest = false;
		    	showConf = false;
		    	checkedin = true;				
			}
			
        }
    } 
    
     public void checkIn() {
     	system.debug('strEventRegId-- ' + strEventRegId);
     	Event_Registration__c er = [Select Id,Status__c from Event_Registration__c where Id = :strEventRegId]; 
     	if(er.Status__c != 'Attended'){
     		er.Status__c = 'Attended';
     		update er;
     		showConf = true;
     		showGuest = false;
     	}
     	//return null;
     }		
  
     
/*public id redirectId {get;set;}
//  public list<sObject> multipleResultList {get;set;}
  public string searchResult {get;set;}
  public string fieldValue;

  public EventRegistrationCheckinExt(ApexPages.StandardController controller){
    string objectName = ApexPages.CurrentPage().getParameters().get('objectName');
    string fieldName = ApexPages.CurrentPage().getParameters().get('fieldName');
    fieldValue = ApexPages.CurrentPage().getParameters().get('fieldValue');
//    strEventRegId = ApexPages.CurrentPage().getParameters().get('fieldValue');

    system.debug('url:' + ApexPages.currentPage().getURL());
    system.debug('objectName:' + objectName);
    system.debug('fieldName:' + fieldName);
    system.debug('fieldValue:' + fieldValue);

//    string query = 'select id, Name,Status__c from ' + objectName + ' where ' + fieldName + ' = \'' + fieldValue + '\'';
//    system.debug(query);

	if(fieldValue != null){
//	    List<sObject> sobjList = Database.query(query);

	    List<Event_Registration__c> sobjList = [Select Id,Status__c from Event_Registration__c where Id = :fieldValue];

		system.debug('sobjList size:' + sobjList.size() + sobjList.get(0).Status__c);
	
	    if (sobjList.size()==0){
	      searchResult = 'no matches';
	    } else if (sobjList.size()==1 && sobjList.get(0).Status__c == 'Accepted'){
	      searchResult = 'match';
	      redirectId = (Id)sobjList[0].get('Id');
system.debug('redirectId:' + redirectId);
	      redirectId = fieldValue;
system.debug('redirectId:' + redirectId);

	    } else if (sobjList.size()==1 && sobjList.get(0).Status__c == 'Attended'){
	      searchResult = 'checkedin';
	      redirectId = (Id)sobjList[0].get('Id');
//	    } else if (sobjList.size()>1){
//	      searchResult = 'Multiple matches found';
//	      multipleResultList = sobjList;
	    }
	}
	else{
		searchResult = 'no matches';
	}   

  }
  
  public void checkIn() {
  		if(fieldValue != null){
	     	system.debug('strEventRegId-- ' + fieldValue);
	     	Event_Registration__c er = [Select Id,Status__c from Event_Registration__c where Id = :fieldValue]; 
	     	er.Status__c = 'Attended';
	     	update er;
  		}	
     }	
*/  
  
  
}
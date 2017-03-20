@isTest
public class DOS_TestDataUtility {
/**
* DOS_TestDataUtility class
*
* @author  Nag Malluru
* @date   09/29/2016
* @desc   Creates test data for the DOS code-base.
*/ 

public DOS_TestDataUtility(){
        
    }
    
    public account newAccount(){
        Account objacct = new Account();
        objacct.Name = 'Global Account'+ randomString5();                   
        insert objacct; 
        System.assert(objacct != null);
        return objacct;
    }

    public Contact newContact(){
        Contact objCont = new Contact();
        objCont.FirstName = 'Global Contact'+ randomString5();
        objcont.LastName = 'LastName' + randomString5();
        objcont.Email = randomString5()+'test@email.com';       
        objcont.AccountId = newAccount().id;
        objcont.MailingStreet = 'Mailing Street'+ randomString5();
        objcont.MailingCity = 'Mailing City'+ randomString5();
        objcont.MailingState = 'Ohio';
        objcont.MailingCountry = 'United States';
        objcont.MailingPostalCode = '32092';    
        insert objcont; 
        System.assert(objcont != null);        
        return objcont;
    } 	
    
    public String randomString5() {
       return randomString().substring(0, 5);
     }
    
    public String randomString() {
      //return random string of 32 chars
      return EncodingUtil.convertToHex(Crypto.generateAesKey(128));
    }
    
    public Event__c newEvent(String sStatus){
    	Event__c objEvent = new Event__c();
    	objEvent.Name = 'Test Event' + 	randomString5();
    	if(sStatus == null)
    		sStatus = 'Published';
    	objEvent.Status__c = sStatus;
    	objEvent.Street_Address__c = 'Event Street'+ randomString5();
        objEvent.City__c = 'Event City'+ randomString5();
        objEvent.State__c = 'Ohio';        
        objEvent.Postal_Code__c = '32092';
        objEvent.Event_Start_Date__c = date.today();
        objEvent.Event_End_Date__c = date.today()+20; 
        objEvent.Event_Description__c = 'Event description' + randomString5();   
    	objEvent.Maximum_Registration__c = 50;
    	objEvent.Display_Name__c = 'Test'+ randomString5();
    	insert objEvent;
    	System.assert(objEvent != null);        
        return objEvent;    	
    }
    
    public List<Event__c> createMultipleEvents(Integer iEvents){
    	
    	List<Event__c> lstEvents = new List<Event__c>();
    	for(Integer i=0; i < iEvents; i++){
    		Event__c e = newEvent('Published');
    		lstEvents.add(e);
    	}
    	
    	return lstEvents;
    }
    public Event_Registration__c newEventRegistration(String sEventId, String sContactId){
    	Event_Registration__c objER = new Event_Registration__c();
    	objER.Contact__c = sContactId;
    	objER.Event__c = sEventId;
    	objER.Status__c = 'Planned';
    	insert objER;
    	System.assert(objER != null);        
        return objER;       	    
    	
    }
    public User newUser(){
    	User usershare = new User();
      	usershare.Username = randomString5()+ '@test.com';
      	usershare.LastName = 'DOSTestLastName';
      	usershare.Email = 'DOSTestEmail@test.com';
      	usershare.alias = 'DOStest';
      	usershare.TimeZoneSidKey = 'America/New_York';
      	usershare.LocaleSidKey = 'en_US';
      	usershare.EmailEncodingKey = 'ISO-8859-1';
      	usershare.ProfileId = [select id from Profile where Name='PD CRM'].Id;
      	usershare.LanguageLocaleKey = 'en_US';      	
      	insert usershare; 
      	System.assert(usershare != null);  
      	return usershare;
    }
    
    public UserRole newUserRole(String roleName, String devName){
    	UserRole r = new UserRole();
    	r.developerName = devName;
    	r.Name = roleName;
    	insert r;
    	system.assert(r != null);
    	return r;
    }
    
    public wbsendit__Campaign_Monitor_Campaign__c newCMCampaign(){
    	wbsendit__Campaign_Monitor_Campaign__c objCMC = new wbsendit__Campaign_Monitor_Campaign__c();
    	objCMC.Name = 'Test Campaign'+ randomString5();
    	objCMC.wbsendit__From_Email__c = 'DOSTestEmail@test.com';
    	objCMC.wbsendit__From_Name__c = 'Test From Name' + randomString5();
    	objCMC.wbsendit__Reply_To__c = 'DOSTestEmail2@test.com';
    	objCMC.wbsendit__Sent_Date__c = date.Today();
    	objCMC.wbsendit__Subject__c = 'Test Subject' + randomString5(); 
    	objCMC.wbsendit__Campaign_ID__c = '100';   	
    	insert objCMC;
    	System.assert(objCMC != null);  
    	return objCMC;
    }
    
    public Campaign newCampaign(String sType){
    	Campaign cm = new Campaign();
    	cm.name = 'Test Campaign'+ randomString5();
    	cm.Type = sType;
    	cm.StartDate = date.today();
    	cm.EndDate = date.today() + 10;
    	cm.isActive = true;
    	cm.Description = 'Test description '+ randomString5();
    	insert cm;
    	
    	return cm;
    	
    }
    
    public CampaignMember newCM(ID campaignId, ID contactId){
    	
    	CampaignMember objCM = new CampaignMember();
    	objCM.CampaignId = campaignId;
    	objCM.ContactId = contactId;
    	insert objCM;
    	return objCM;  	
    	
    }
    
}
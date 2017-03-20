global with sharing class CreateContactsInSegments {

@future(callout=true)
  global static void CreateList(String clientId,String listName, String listId,String regAttend) {

        try{
            HttpRequest req = new HttpRequest();
    
            req.setEndpoint(KeyValueStoreHelper.getTextValue('ActiveSubscribersURL') +clientId+'.json');
            req.setMethod('POST');
    
            Blob headerValue = Blob.valueOf(KeyValueStoreHelper.getTextValue('UserName') + ':' + KeyValueStoreHelper.getTextValue('Password'));
            String authorizationHeader = KeyValueStoreHelper.getTextValue('AuthorizationHeader') + ' ' + EncodingUtil.base64Encode(headerValue);
    
            req.setHeader('Authorization', authorizationHeader);
    
            listBody bodyRequest = new listBody();
            bodyRequest.Title = listName;
            bodyRequest.UnsubscribePage = 'iipstate.createsend.com/t/GenericUnsubscribe';
            bodyRequest.UnsubscribeSetting = 'AllClientLists';
            bodyRequest.ConfirmedOptIn = false;
            bodyRequest.ConfirmationSuccessPage = 'iipstate.createsend.com/t/Confirmed';
            req.setBody(JSON.serialize(bodyRequest));                                    
            System.debug('req--'+ req);           
            Http http = new Http();
            //HTTPResponse res = http.send(req);
            HTTPResponse res;
            if(!Test.isRunningTest())
                res = http.send(req);
        
            string respId;
            if(!Test.isRunningTest())
                respId = res.getBody();
            else
                respId = '{"foo" : "bar|bar1|bar2"}';  
    
            String specialChars = '"|&';
            for(integer i=0; i<specialChars.split('|').size(); i++)
    
                respId = respId.replace(specialChars.split('|')[i], '');
            
                CreateContactsInSegments.AddCustomField(respId,'Registration Status');
                CreateContactsInSegments.AddCustomField(respId,'Event URL');
                CreateContactsInSegments.AddCustomField(respId,'FName');
                CreateContactsInSegments.AddCustomField(respId,'LName');
                CreateContactsInSegments.AddCustomField(respId,'Organization');
                CreateContactsInSegments.AddCustomField(respId,'Salutation');
                CreateContactsInSegments.AddCustomField(respId,'Title');
                CreateContactsInSegments.AddCustomField(respId,'DressCode');
                CreateContactsInSegments.AddCustomField(respId,'GuestType');
                CreateContactsInSegments.AddCustomField(respId,'FormalName');


                CreateContactsInSegments.AddSegments(respId,'Planned');
                CreateContactsInSegments.AddSegments(respId,'Invited');
                CreateContactsInSegments.AddSegments(respId,'Accepted');
                CreateContactsInSegments.AddSegments(respId,'Declined');
                CreateContactsInSegments.AddSegments(respId,'Attended');
                CreateContactsInSegments.AddSegments(respId,'No-Show');
    
            if(Integer.valueof(regAttend) > 0){
              CreateContactsInSegments.CreateContactsInListForDraftEvents(listId,respId);
            }
    
            System.debug('segments are created');
            Event__c eve = [Select Campaign_Monitor_List_Id__c,Registered_Attendees__c from Event__c where Id = :listId];
            eve.Campaign_Monitor_List_Id__c = respId;
            update eve;
        }
        catch(Exception e){
           String msg = 'CreateContactsInSegments Exception--: ' + e.getMessage();
           PDCRM_ErrorLog.CreateNewError(String.valueof(e.getLineNumber()),e.getMessage(),'CreateContactsInSegments','CreateList','Creating List in CM','https://api.createsend.com/api/v3.1/subscribers',clientId+'.json');
        }
  }

    public class listBody
    {
        string Title {get;set;}
        string UnsubscribePage {get;set;}
        string UnsubscribeSetting {get;set;}
        boolean ConfirmedOptIn {get;set;}
        string ConfirmationSuccessPage {get;set;}
    }


@future(callout=true)
  global static void UpdateList(String listId,String listName) {

        try{
            HttpRequest req = new HttpRequest();
    
            listUpdateBody bodyRequest = new listUpdateBody();
            bodyRequest.Title = listName;
            bodyRequest.UnsubscribePage = 'iipstate.createsend.com/t/GenericUnsubscribe';
            bodyRequest.UnsubscribeSetting = 'AllClientLists';
            bodyRequest.ConfirmedOptIn = false;
            bodyRequest.ConfirmationSuccessPage = 'iipstate.createsend.com/t/Confirmed';
            bodyRequest.AddUnsubscribesToSuppList = true;
            bodyRequest.ScrubActiveWithSuppList = true;
        
    
            req.setEndpoint('https://api.createsend.com/api/v3.1/lists/'+listId+'.json');
            req.setMethod('PUT');
            Blob headerValue = Blob.valueOf(KeyValueStoreHelper.getTextValue('UserName') + ':' + KeyValueStoreHelper.getTextValue('Password'));
            String authorizationHeader = KeyValueStoreHelper.getTextValue('AuthorizationHeader') + ' ' + EncodingUtil.base64Encode(headerValue);
    
            req.setHeader('Authorization', authorizationHeader);                          
            req.setBody(JSON.serialize(bodyRequest));
            
            System.debug('addSubscribers req--'+ JSON.serialize(bodyRequest));
            Http http = new Http();
            //HTTPResponse res = http.send(req);
            HTTPResponse res;
            if(!Test.isRunningTest())
                res = http.send(req);
        }
        catch(Exception e){
           String msg = 'UpdateList Exception--: ' + e.getMessage();
           PDCRM_ErrorLog.CreateNewError(String.valueof(e.getLineNumber()),e.getMessage(),'CreateContactsInSegments','UpdateList','Updating a List in CM','https://api.createsend.com/api/v3.1/lists/',listId+'.json');
        }               

  }

    public class listUpdateBody
    {
        string Title {get;set;}
        string UnsubscribePage {get;set;}
        string UnsubscribeSetting {get;set;}
        boolean ConfirmedOptIn {get;set;}
        string ConfirmationSuccessPage {get;set;}
        boolean AddUnsubscribesToSuppList {get;set;}
        boolean ScrubActiveWithSuppList {get;set;}
    }


  global static void CreateContactsInListForDraftEvents(Id EventId, String respId) {

        try{
            HttpRequest req = new HttpRequest();
    
            List<Event_Registration__c> lstRegistrations = [Select Contact_Email__c,Status__c,Event__c,Id,Campaign_Monitor_List_Id__c,Attendee_First_Name__c,Attendee_Last_Name__c,Contact__r.Name,
                                                                    Attendee_Organization__c,Attendee_Salutation__c,Attendee_Title__c,Dress_Code__c,Preferred_Email__c,Preferred_Phone__c,
                                                                    Guest_Type__c, Contact_Name__c from Event_Registration__c where Event__c = :EventId]; 
    
            listOfSubscribers bodyRequest = new listOfSubscribers();
            bodyRequest.Resubscribe = false;
            bodyRequest.QueueSubscriptionBasedAutoResponders = false;
            bodyRequest.RestartSubscriptionBasedAutoresponders = false;

            bodyRequest.Subscribers = new List<listOfSubscribers.Subscriber>();
    
            for(Event_Registration__c er : lstRegistrations ){
                listOfSubscribers.Subscriber sub = new listOfSubscribers.Subscriber();
                if(er.Preferred_Email__c != null){
                    sub.EmailAddress = er.Preferred_Email__c;
                }else{
                    sub.EmailAddress = er.Contact_Email__c;             
                }
                sub.Name = er.Contact__r.Name;
                System.debug('Name--' + er.Contact__r.Name);
                List<listOfSubscribers.CustomField> cfl = new List<listOfSubscribers.CustomField>();          
                listOfSubscribers.CustomField cf = new listOfSubscribers.CustomField();
                cf.Key = 'Registration Status';
                cf.Value = er.Status__c;
                cfl.add(cf);
                listOfSubscribers.CustomField cf1 = new listOfSubscribers.CustomField();
                cf1.Key = 'Event URL';
                cf1.Value = KeyValueStoreHelper.getTextValue('SitePage') + '?erid=' + er.Id + '&id=' + er.Event__c;
                cfl.add(cf1);
                listOfSubscribers.CustomField cf2 = new listOfSubscribers.CustomField();
                cf2.Key = 'FName';
                cf2.Value = er.Attendee_First_Name__c;
                cfl.add(cf2);
                listOfSubscribers.CustomField cf3 = new listOfSubscribers.CustomField();
                cf3.Key = 'LName';
                cf3.Value = er.Attendee_Last_Name__c;
                cfl.add(cf3);
                listOfSubscribers.CustomField cf4 = new listOfSubscribers.CustomField();
                cf4.Key = 'Organization';
                cf4.Value = er.Attendee_Organization__c;
                cfl.add(cf4);
                listOfSubscribers.CustomField cf5 = new listOfSubscribers.CustomField();
                cf5.Key = 'Salutation';
                cf5.Value = er.Attendee_Salutation__c;
                cfl.add(cf5);
                listOfSubscribers.CustomField cf6 = new listOfSubscribers.CustomField();
                cf6.Key = 'Title';
                cf6.Value = er.Attendee_Title__c;
                cfl.add(cf6);
                listOfSubscribers.CustomField cf7 = new listOfSubscribers.CustomField();
                cf7.Key = 'DressCode';
                cf7.Value = er.Dress_Code__c;
                cfl.add(cf7);
                listOfSubscribers.CustomField cf8 = new listOfSubscribers.CustomField();
                cf8.Key = 'GuestType';
                cf8.Value = er.Guest_Type__c;
                cfl.add(cf8);
                listOfSubscribers.CustomField cf9 = new listOfSubscribers.CustomField();
                cf9.Key = 'FormalName';
                cf9.Value = er.Contact_Name__c;
                cfl.add(cf9);
    
                sub.CustomFields = cfl;
                bodyRequest.Subscribers.add(sub);
            }
    
            req.setEndpoint('https://api.createsend.com/api/v3.1/subscribers/'+respId+'/import.json');
            req.setMethod('POST');
    
            Blob headerValue = Blob.valueOf(KeyValueStoreHelper.getTextValue('UserName') + ':' + KeyValueStoreHelper.getTextValue('Password'));
            String authorizationHeader = KeyValueStoreHelper.getTextValue('AuthorizationHeader') + ' ' + EncodingUtil.base64Encode(headerValue);
    
            req.setHeader('Authorization', authorizationHeader);                          
            req.setBody(JSON.serialize(bodyRequest));
            
            System.debug('addSubscribers req--'+ JSON.serialize(bodyRequest));
            Http http = new Http();
            //HTTPResponse res = http.send(req);
            HTTPResponse res;
            if(!Test.isRunningTest())
                res = http.send(req);
        }   
        catch(Exception e){
           String msg = 'CreateContactsInListForDraftEvents Exception--: ' + e.getMessage();
           PDCRM_ErrorLog.CreateNewError(String.valueof(e.getLineNumber()),e.getMessage(),'CreateContactsInSegments','CreateContactsInListForDraftEvents','CreateContactsInListForDraftEvents in CM','https://api.createsend.com/api/v3.1/subscribers/',respId+'/import.json');
        }
  }


@future(callout=true)
  global static void CreateContactsInList(Id EventId) {

        String listId;

        try{
            HttpRequest req = new HttpRequest();
    
            List<Event_Registration__c> lstRegistrations = [Select Contact_Email__c,Status__c,Event__c,Id,Campaign_Monitor_List_Id__c,Attendee_First_Name__c,Attendee_Last_Name__c,Contact__r.Name,
                                                                    Attendee_Organization__c,Attendee_Salutation__c,Attendee_Title__c,Dress_Code__c,Preferred_Email__c,Preferred_Phone__c,
                                                                    Guest_Type__c, Contact_Name__c from Event_Registration__c where Event__c = :EventId]; 
    
            listOfSubscribers bodyRequest = new listOfSubscribers();
            bodyRequest.Resubscribe = true;
            bodyRequest.QueueSubscriptionBasedAutoResponders = false;
            bodyRequest.RestartSubscriptionBasedAutoresponders = true;
    
            bodyRequest.Subscribers = new List<listOfSubscribers.Subscriber>();
    
            for(Event_Registration__c er : lstRegistrations ){
                listOfSubscribers.Subscriber sub = new listOfSubscribers.Subscriber();
                if(er.Preferred_Email__c != null){
                    sub.EmailAddress = er.Preferred_Email__c;
                }else{
                    sub.EmailAddress = er.Contact_Email__c;             
                }
                sub.Name = er.Contact__r.Name;
                System.debug('Name--' + er.Contact__r.Name);
                List<listOfSubscribers.CustomField> cfl = new List<listOfSubscribers.CustomField>();          
                listOfSubscribers.CustomField cf = new listOfSubscribers.CustomField();
                cf.Key = 'Registration Status';
                cf.Value = er.Status__c;
                cfl.add(cf);
                listOfSubscribers.CustomField cf1 = new listOfSubscribers.CustomField();
                cf1.Key = 'Event URL';
                cf1.Value = KeyValueStoreHelper.getTextValue('SitePage') + '?erid=' + er.Id + '&id=' + er.Event__c;
                cfl.add(cf1);
                listOfSubscribers.CustomField cf2 = new listOfSubscribers.CustomField();
                cf2.Key = 'FName';
                cf2.Value = er.Attendee_First_Name__c;
                cfl.add(cf2);
                listOfSubscribers.CustomField cf3 = new listOfSubscribers.CustomField();
                cf3.Key = 'LName';
                cf3.Value = er.Attendee_Last_Name__c;
                cfl.add(cf3);
                listOfSubscribers.CustomField cf4 = new listOfSubscribers.CustomField();
                cf4.Key = 'Organization';
                cf4.Value = er.Attendee_Organization__c;
                cfl.add(cf4);
                listOfSubscribers.CustomField cf5 = new listOfSubscribers.CustomField();
                cf5.Key = 'Salutation';
                cf5.Value = er.Attendee_Salutation__c;
                cfl.add(cf5);
                listOfSubscribers.CustomField cf6 = new listOfSubscribers.CustomField();
                cf6.Key = 'Title';
                cf6.Value = er.Attendee_Title__c;
                cfl.add(cf6);
                listOfSubscribers.CustomField cf7 = new listOfSubscribers.CustomField();
                cf7.Key = 'DressCode';
                cf7.Value = er.Dress_Code__c;
                cfl.add(cf7);
                listOfSubscribers.CustomField cf8 = new listOfSubscribers.CustomField();
                cf8.Key = 'GuestType';
                cf8.Value = er.Guest_Type__c;
                cfl.add(cf8);
                listOfSubscribers.CustomField cf9 = new listOfSubscribers.CustomField();
                cf9.Key = 'FormalName';
                cf9.Value = er.Contact_Name__c;
                cfl.add(cf9);
    
                sub.CustomFields = cfl;
                bodyRequest.Subscribers.add(sub);
                listId = er.Campaign_Monitor_List_Id__c;
            }
    
            req.setEndpoint('https://api.createsend.com/api/v3.1/subscribers/'+listId+'/import.json');
            req.setMethod('POST');
    
            Blob headerValue = Blob.valueOf(KeyValueStoreHelper.getTextValue('UserName') + ':' + KeyValueStoreHelper.getTextValue('Password'));
            String authorizationHeader = KeyValueStoreHelper.getTextValue('AuthorizationHeader') + ' ' + EncodingUtil.base64Encode(headerValue);
    
            req.setHeader('Authorization', authorizationHeader);                          
            req.setBody(JSON.serialize(bodyRequest));
            
            System.debug('addSubscribers req--'+ JSON.serialize(bodyRequest));
            Http http = new Http();
            //HTTPResponse res = http.send(req);
            HTTPResponse res;
            if(!Test.isRunningTest())
                res = http.send(req);
        }

        catch(Exception e){
           String msg = 'CreateContactsInList Exception--: ' + e.getMessage();
           PDCRM_ErrorLog.CreateNewError(String.valueof(e.getLineNumber()),e.getMessage(),'CreateContactsInSegments','CreateContactsInList','CreateContactsInList in CM','https://api.createsend.com/api/v3.1/subscribers/',listId+'/import.json');
        }

  }

@future(callout=true)
  global static void UpdateContactsInSegments(Id EventRegId) {

        String listId;
        try{
            HttpRequest req = new HttpRequest();
    
            Event_Registration__c lstRegistrations = [Select Contact_Email__c,Status__c,Event__c,Id,Campaign_Monitor_List_Id__c,Attendee_First_Name__c,Attendee_Last_Name__c,Contact__r.Name,
                                                                    Attendee_Organization__c,Attendee_Salutation__c,Attendee_Title__c,Dress_Code__c,Preferred_Email__c,Preferred_Phone__c,
                                                                    Guest_Type__c, Contact_Name__c from Event_Registration__c where Id = :EventRegId];
            Subscriber bodyRequest = new Subscriber();
            bodyRequest.Resubscribe = true;
//            bodyRequest.QueueSubscriptionBasedAutoResponders = false;
            bodyRequest.RestartSubscriptionBasedAutoresponders = true;
            if(lstRegistrations.Preferred_Email__c != null){
                bodyRequest.EmailAddress = lstRegistrations.Preferred_Email__c;
            }
            else{
                bodyRequest.EmailAddress = lstRegistrations.Contact_Email__c;           
            }
            bodyRequest.Name = lstRegistrations.Contact__r.Name;
    
            bodyRequest.CustomFields = new List<CreateContactsInSegments.CustomField>();
            CreateContactsInSegments.CustomField cf = new CreateContactsInSegments.CustomField();
            cf.Key = 'Registration Status';
            cf.Value = lstRegistrations.Status__c;
            bodyRequest.CustomFields.add(cf);
    
            CreateContactsInSegments.CustomField cf1 = new CreateContactsInSegments.CustomField();
            cf1.Key = 'Event URL';
            cf1.Value = KeyValueStoreHelper.getTextValue('SitePage') + '?erid=' + lstRegistrations.Id + '&id=' + lstRegistrations.Event__c;
            bodyRequest.CustomFields.add(cf1);

            CreateContactsInSegments.CustomField cf2 = new CreateContactsInSegments.CustomField();
            cf2.Key = 'FName';
            cf2.Value = lstRegistrations.Attendee_First_Name__c;
            bodyRequest.CustomFields.add(cf2);

            CreateContactsInSegments.CustomField cf3 = new CreateContactsInSegments.CustomField();
            cf3.Key = 'LName';
            cf3.Value = lstRegistrations.Attendee_Last_Name__c;
            bodyRequest.CustomFields.add(cf3);

            CreateContactsInSegments.CustomField cf4 = new CreateContactsInSegments.CustomField();
            cf4.Key = 'Organization';
            cf4.Value = lstRegistrations.Attendee_Organization__c;
            bodyRequest.CustomFields.add(cf4);

            CreateContactsInSegments.CustomField cf5 = new CreateContactsInSegments.CustomField();
            cf5.Key = 'Salutation';
            cf5.Value = lstRegistrations.Attendee_Salutation__c;
            bodyRequest.CustomFields.add(cf5);

            CreateContactsInSegments.CustomField cf6 = new CreateContactsInSegments.CustomField();
            cf6.Key = 'Title';
            cf6.Value = lstRegistrations.Attendee_Title__c;
            bodyRequest.CustomFields.add(cf6);

            CreateContactsInSegments.CustomField cf7 = new CreateContactsInSegments.CustomField();
            cf7.Key = 'DressCode';
            cf7.Value = lstRegistrations.Dress_Code__c;
            bodyRequest.CustomFields.add(cf7);

            CreateContactsInSegments.CustomField cf8 = new CreateContactsInSegments.CustomField();
            cf8.Key = 'GuestType';
            cf8.Value = lstRegistrations.Guest_Type__c;
            bodyRequest.CustomFields.add(cf8);

            CreateContactsInSegments.CustomField cf9 = new CreateContactsInSegments.CustomField();
            cf9.Key = 'FormalName';
            cf9.Value = lstRegistrations.Contact_Name__c;
            bodyRequest.CustomFields.add(cf9);

            listId = lstRegistrations.Campaign_Monitor_List_Id__c;  
            
            req.setEndpoint('https://api.createsend.com/api/v3.1/subscribers/'+listId+'.json'+'?email=' + lstRegistrations.Contact_Email__c);
            req.setMethod('PUT');
    
            Blob headerValue = Blob.valueOf(KeyValueStoreHelper.getTextValue('UserName') + ':' + KeyValueStoreHelper.getTextValue('Password'));
            String authorizationHeader = KeyValueStoreHelper.getTextValue('AuthorizationHeader') + ' ' + EncodingUtil.base64Encode(headerValue);
    
            req.setHeader('Authorization', authorizationHeader);                          
            req.setBody(JSON.serialize(bodyRequest));
            
            System.debug('addSubscribers req--'+ JSON.serialize(bodyRequest));
            Http http = new Http();
            //HTTPResponse res = http.send(req);
            HTTPResponse res;
            if(!Test.isRunningTest())
                  res = http.send(req);
        }
        catch(Exception e){
           String msg = 'UpdateContactsInSegments Exception--: ' + e.getMessage();
           PDCRM_ErrorLog.CreateNewError(String.valueof(e.getLineNumber()),e.getMessage(),'CreateContactsInSegments','UpdateContactsInSegments','UpdateContactsInSegments in CM','https://api.createsend.com/api/v3.1/subscribers/',listId+'.json'+'?email=');
        }      

  }

    public class Subscriber
    {
      public Boolean Resubscribe {get;set;}
      public Boolean QueueSubscriptionBasedAutoResponders {get;set;}
      public Boolean RestartSubscriptionBasedAutoresponders {get;set;}  
      public String EmailAddress {get;set;}
      public String Name {get;set;}  
      public List<CustomField> CustomFields{get;set;}          
    }
    
    public class CustomField {
        public String Key {get;set;}
        public String Value {get;set;}
    }

@future(callout=true)
  global static void DeleteSubscriber(String ListId,String email) {

        HttpRequest req = new HttpRequest();

        req.setEndpoint('https://api.createsend.com/api/v3.1/subscribers/'+listId+'.json'+'?email='+email);
        req.setMethod('DELETE');
        Blob headerValue = Blob.valueOf(KeyValueStoreHelper.getTextValue('UserName') + ':' + KeyValueStoreHelper.getTextValue('Password'));
        String authorizationHeader = KeyValueStoreHelper.getTextValue('AuthorizationHeader') + ' ' + EncodingUtil.base64Encode(headerValue);

        req.setHeader('Authorization', authorizationHeader);       
        Http http = new Http();
        //HTTPResponse res = http.send(req);
        HTTPResponse res;
        if(!Test.isRunningTest())
          res = http.send(req);

  }


//@future(callout=true)
  global static void AddCustomField(String ListId,String fieldName) {

        HttpRequest req = new HttpRequest();
    
        ListCustomField bodyRequest = new ListCustomField();
        bodyRequest.FieldName = fieldName;
        bodyRequest.DataType = 'Text';
        bodyRequest.VisibleInPreferenceCenter = true;
        

        req.setEndpoint('https://api.createsend.com/api/v3.1/lists/'+listId+'/customfields.json');
        req.setMethod('POST');
        Blob headerValue = Blob.valueOf(KeyValueStoreHelper.getTextValue('UserName') + ':' + KeyValueStoreHelper.getTextValue('Password'));
        String authorizationHeader = KeyValueStoreHelper.getTextValue('AuthorizationHeader') + ' ' + EncodingUtil.base64Encode(headerValue);

        req.setHeader('Authorization', authorizationHeader);                          
        req.setBody(JSON.serialize(bodyRequest));
        
        System.debug('addSubscribers req--'+ JSON.serialize(bodyRequest));
        Http http = new Http();
        //HTTPResponse res = http.send(req);
        HTTPResponse res;
        if(!Test.isRunningTest())
          res = http.send(req);

  }

//@future(callout=true)
  global static void AddSegments(String ListId,String Title) {

        HttpRequest req = new HttpRequest();

        listOfSegments bodyRequest = new listOfSegments();
        bodyRequest.Title = Title;

        bodyRequest.RuleGroups = new List<listOfSegments.RuleGroup>();
        listOfSegments.RuleGroup rg = new listOfSegments.RuleGroup();
    
        List<listOfSegments.Rule> rgRules = new List<listOfSegments.Rule>();          
         listOfSegments.Rule rr = new listOfSegments.Rule();
        rr.RuleType = 'Registration Status';
        rr.Clause = 'CONTAINS ' + Title;
        rgRules.add(rr);
        rg.Rules = rgRules;

        bodyRequest.RuleGroups.add(rg);

        req.setEndpoint('https://api.createsend.com/api/v3.1/segments/'+listId+'.json');
        req.setMethod('POST');
        Blob headerValue = Blob.valueOf(KeyValueStoreHelper.getTextValue('UserName') + ':' + KeyValueStoreHelper.getTextValue('Password'));
        String authorizationHeader = KeyValueStoreHelper.getTextValue('AuthorizationHeader') + ' ' + EncodingUtil.base64Encode(headerValue);

        req.setHeader('Authorization', authorizationHeader);                          
        req.setBody(JSON.serialize(bodyRequest));
        
        System.debug('addSubscribers req--'+ JSON.serialize(bodyRequest));
        Http http = new Http();
        //HTTPResponse res = http.send(req);
        HTTPResponse res;
        if(!Test.isRunningTest())
            res = http.send(req);

  }

    public class ListCustomField
    {
      public String FieldName {get;set;}
      public String DataType {get;set;}
      public Boolean VisibleInPreferenceCenter {get;set;}  
    }

  global static void UpdateInvitedContactsInSegments(Id EventId) {

        String listId;
        try{
            HttpRequest req = new HttpRequest();

            List<Event_Registration__c> lstRegistrations = [Select Contact_Email__c,Status__c,Event__c,Id,Campaign_Monitor_List_Id__c,Attendee_First_Name__c,Attendee_Last_Name__c,Contact__r.Name,
                                                                    Attendee_Organization__c,Attendee_Salutation__c,Attendee_Title__c,Dress_Code__c,Preferred_Email__c,Preferred_Phone__c,
                                                                    Guest_Type__C,Contact_Name__c from Event_Registration__c where Event__c = :EventId and Status__c = 'Planned'];
    System.debug('--- lstRegistrations ---' + lstRegistrations.size());
            listOfSubscribers bodyRequest = new listOfSubscribers();
            bodyRequest.Resubscribe = true;
            bodyRequest.QueueSubscriptionBasedAutoResponders = false;
            bodyRequest.RestartSubscriptionBasedAutoresponders = true;
    
            bodyRequest.Subscribers = new List<listOfSubscribers.Subscriber>();
    
            for(Event_Registration__c er : lstRegistrations ){
                listOfSubscribers.Subscriber sub = new listOfSubscribers.Subscriber();
                if(er.Preferred_Email__c != null){
                    sub.EmailAddress = er.Preferred_Email__c;
                }
                else{
                    sub.EmailAddress = er.Contact_Email__c;         
                }
                sub.Name = '';
                List<listOfSubscribers.CustomField> cfl = new List<listOfSubscribers.CustomField>();          
                listOfSubscribers.CustomField cf = new listOfSubscribers.CustomField();
                cf.Key = 'Registration Status';
                cf.Value = 'Invited';
                cfl.add(cf);
                listOfSubscribers.CustomField cf1 = new listOfSubscribers.CustomField();
                cf1.Key = 'Event URL';
                cf1.Value = KeyValueStoreHelper.getTextValue('SitePage') + '?erid=' + er.Id + '&id=' + er.Event__c;
                cfl.add(cf1);
                listOfSubscribers.CustomField cf2 = new listOfSubscribers.CustomField();
                cf2.Key = 'FName';
                cf2.Value = er.Attendee_First_Name__c;
                cfl.add(cf2);
                listOfSubscribers.CustomField cf3 = new listOfSubscribers.CustomField();
                cf3.Key = 'LName';
                cf3.Value = er.Attendee_Last_Name__c;
                cfl.add(cf3);
                listOfSubscribers.CustomField cf4 = new listOfSubscribers.CustomField();
                cf4.Key = 'Organization';
                cf4.Value = er.Attendee_Organization__c;
                cfl.add(cf4);
                listOfSubscribers.CustomField cf5 = new listOfSubscribers.CustomField();
                cf5.Key = 'Salutation';
                cf5.Value = er.Attendee_Salutation__c;
                cfl.add(cf5);
                listOfSubscribers.CustomField cf6 = new listOfSubscribers.CustomField();
                cf6.Key = 'Title';
                cf6.Value = er.Attendee_Title__c;
                cfl.add(cf6);
                listOfSubscribers.CustomField cf7 = new listOfSubscribers.CustomField();
                cf7.Key = 'DressCode';
                cf7.Value = er.Dress_Code__c;
                cfl.add(cf7);
                listOfSubscribers.CustomField cf8 = new listOfSubscribers.CustomField();
                cf8.Key = 'GuestType';
                cf8.Value = er.Guest_Type__c;
                cfl.add(cf8);
                listOfSubscribers.CustomField cf9 = new listOfSubscribers.CustomField();
                cf9.Key = 'FormalName';
                cf9.Value = er.Contact_Name__c;
                cfl.add(cf9);
                
                
                sub.CustomFields = cfl;
                bodyRequest.Subscribers.add(sub);
                listId = er.Campaign_Monitor_List_Id__c;
            }
            req.setEndpoint('https://api.createsend.com/api/v3.1/subscribers/'+listId+'/import.json');
            
            req.setMethod('POST');
    
            Blob headerValue = Blob.valueOf(KeyValueStoreHelper.getTextValue('UserName') + ':' + KeyValueStoreHelper.getTextValue('Password'));
            String authorizationHeader = KeyValueStoreHelper.getTextValue('AuthorizationHeader') + ' ' + EncodingUtil.base64Encode(headerValue);
    
            req.setHeader('Authorization', authorizationHeader);                          
            req.setBody(JSON.serialize(bodyRequest));
            
            System.debug('addSubscribers req--'+ JSON.serialize(bodyRequest));
            Http http = new Http();
            HTTPResponse res;
            if(!Test.isRunningTest())
              res = http.send(req);
        }
        catch(Exception e){
           String msg = 'UpdateInvitedContactsInSegments Exception--: ' + e.getMessage();
           PDCRM_ErrorLog.CreateNewError(String.valueof(e.getLineNumber()),e.getMessage(),'CreateContactsInSegments','UpdateContactsInSegments','UpdateInvitedContactsInSegments in CM','https://api.createsend.com/api/v3.1/subscribers/',listId+'.json');
        }

  }

    global static void DeleteSegment(String segmentId) {

        //Delete Segment
        HttpRequest req = new HttpRequest();

        req.setEndpoint('https://api.createsend.com/api/v3.1/segments/'+segmentId+'.json');
        req.setMethod('DELETE');
        Blob headerValue = Blob.valueOf(KeyValueStoreHelper.getTextValue('UserName') + ':' + KeyValueStoreHelper.getTextValue('Password'));
        String authorizationHeader = KeyValueStoreHelper.getTextValue('AuthorizationHeader') + ' ' + EncodingUtil.base64Encode(headerValue);

        req.setHeader('Authorization', authorizationHeader);                          
        Http http = new Http();
        HTTPResponse res;
        if(!Test.isRunningTest())
            res = http.send(req);
    }

@future(callout=true)
    global static void GetSegments(String listId) {

        //Get Segments
        HttpRequest req = new HttpRequest();

        req.setEndpoint('https://api.createsend.com/api/v3.1/lists/'+listId+'/segments.json');
        req.setMethod('GET');
        Blob headerValue = Blob.valueOf(KeyValueStoreHelper.getTextValue('UserName') + ':' + KeyValueStoreHelper.getTextValue('Password'));
        String authorizationHeader = KeyValueStoreHelper.getTextValue('AuthorizationHeader') + ' ' + EncodingUtil.base64Encode(headerValue);

        req.setHeader('Authorization', authorizationHeader);                          
        Http http = new Http();
        HTTPResponse res;
        if(!Test.isRunningTest())
            res = http.send(req);

        system.debug('respList--' + res.getBody());
        
        List<SegmentDetails> respList = (List<SegmentDetails>) JSON.deserialize(res.getBody(),List<SegmentDetails>.class);              

        system.debug('respList--' + respList);
        
        for(SegmentDetails sd : respList){
            if(sd.Title == 'Planned' || sd.Title == 'Invited'){
                DeleteSegment(sd.SegmentID);
            }
        }
        
    }

    public class SegmentDetails
    {
        public String ListID {get;set;}
        public String SegmentID {get;set;}
        public String Title {get;set;}  
    }

@future(callout=true)
    global static void DeleteList(String listId) {

        //Get Segments
        HttpRequest req = new HttpRequest();

        req.setEndpoint('https://api.createsend.com/api/v3.1/lists/'+listId+'.json');
        req.setMethod('DELETE');
        Blob headerValue = Blob.valueOf(KeyValueStoreHelper.getTextValue('UserName') + ':' + KeyValueStoreHelper.getTextValue('Password'));
        String authorizationHeader = KeyValueStoreHelper.getTextValue('AuthorizationHeader') + ' ' + EncodingUtil.base64Encode(headerValue);

        req.setHeader('Authorization', authorizationHeader);                          
        Http http = new Http();
        HTTPResponse res;
        if(!Test.isRunningTest())
            res = http.send(req);       
    }   

}
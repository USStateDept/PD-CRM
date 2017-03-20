public with sharing class YALI_SendCampaign {
    
    public YALI_SendCampaign(ApexPages.StandardController controller) {

    }   
   
    public PageReference sendCampaign() {

            try{
            ID CampaignId = Apexpages.currentPage().getParameters().get('Id');  
            List<Campaign> lstcm = [Select Name from Campaign where Id = :CampaignId and type = 'Campaign'];
            if(lstcm.size()>0){

                Campaign cm = [Select Name,wbsendit__Campaign_Monitor_Id__c from Campaign where Id = :CampaignId and type = 'Campaign'];
                String cmName = cm.Name;
                if(cm.wbsendit__Campaign_Monitor_Id__c != '' && cm.wbsendit__Campaign_Monitor_Id__c != null){
                    ApexPages.Message  errorMessage = new ApexPages.Message(ApexPages.Severity.ERROR, 'Campaign already exist in Campaign Monitor');
                    ApexPages.addMessage(errorMessage);
                    return null;                    
                }

                User user = [Select Alias, UserRoleId, UserRole.Id, UserRole.Name from User where Id = :UserInfo.getUserId()];
                string roleName = user.UserRole.Name;
                system.debug('roleName' + roleName);
                string clientId;
                if(!Test.isRunningTest()){
                    List<wbsendit__Client__c> client = [Select wbsendit__Client_Id__c from wbsendit__Client__c where wbsendit__Client_Name__c = :roleName];
                system.debug('roleName' + roleName);
                    if(client.size() > 0){
                        clientId = client.get(0).wbsendit__Client_Id__c;
                    }
                    else{
                        clientId = 'c7ff9567600935607d3e7aacb7e325f7';
                    }                
                }
                else{
                    clientId = 'c7ff9567600935607d3e7aacb7e325f7';    
                }
    
                HttpRequest req = new HttpRequest();
    
                req.setEndpoint(KeyValueStoreHelper.getTextValue('ActiveSubscribersURL') +clientId+'.json');
                req.setMethod('POST');
    
                Blob headerValue = Blob.valueOf(KeyValueStoreHelper.getTextValue('UserName') + ':' + KeyValueStoreHelper.getTextValue('Password'));
                String authorizationHeader = KeyValueStoreHelper.getTextValue('AuthorizationHeader') + ' ' + EncodingUtil.base64Encode(headerValue);
    
                req.setHeader('Authorization', authorizationHeader);
    
                listBody bodyRequest = new listBody();
                bodyRequest.Title = cmName;
                bodyRequest.UnsubscribePage = 'iipstate.createsend.com/t/GenericUnsubscribe';
                bodyRequest.UnsubscribeSetting = 'AllClientLists';
                bodyRequest.ConfirmedOptIn = false;
                bodyRequest.ConfirmationSuccessPage = 'iipstate.createsend.com/t/Confirmed';
                req.setBody(JSON.serialize(bodyRequest));                                    
                System.debug('req--'+ req);           
                
                Http http = new Http();
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
            
                System.debug('response--'+ respId);
                
                List<String> pledges = new List<String>();
                List<Campaign> listCampaign = [Select Name from Campaign where Parent.Id = :CampaignId and type in ('Pledge','Certificate')];
                for(Campaign c : listCampaign){
                    pledges.add(c.Name);
                }
                
                System.debug('pledges--'+ pledges);
                List<String> nullString = new List<String>();
                
                YALI_SendCampaign.AddCustomField(respId,'Pledges/Certificates','MultiSelectMany',pledges);
                YALI_SendCampaign.AddCustomField(respId,'Country','Text',nullString);
                YALI_SendCampaign.AddCustomField(respId,'City','Text',nullString);
                YALI_SendCampaign.AddCustomField(respId,'Gender','Text',nullString);
                YALI_SendCampaign.AddCustomField(respId,'Age','Text',nullString);
    //          YALI_SendCampaign.AddCustomField(respId,'Interests','MultiSelectMany',pledges);
                
                cm.wbsendit__Campaign_Monitor_Id__c = respId;
                update cm;
                
                Pagereference proj = new Pagereference('/' + CampaignId);
                return proj;
            }
            else{
                ApexPages.Message  errorMessage = new ApexPages.Message(ApexPages.Severity.ERROR, 'Goto Campaign record to send data');
                ApexPages.addMessage(errorMessage);
                return null;
            }
        }
        catch(Exception e){
            System.debug('YALI_SendCampaign Exception--' + e.getMessage());
            String msg = 'YALI_SendCampaign Exception--: ' + e.getMessage();
            PDCRM_ErrorLog.CreateNewError(String.valueof(e.getLineNumber()),e.getMessage(),'YALI_SendCampaign','sendCampaign','Sending Campaign to CM',KeyValueStoreHelper.getTextValue('ActiveSubscribersURL'),'clientId.json');
            return null;
        }
//      return null;
    }
    
    public class listBody
    {
        string Title {get;set;}
        string UnsubscribePage {get;set;}
        string UnsubscribeSetting {get;set;}
        boolean ConfirmedOptIn {get;set;}
        string ConfirmationSuccessPage {get;set;}
    }

    public static void AddCustomField(String ListId,String fieldName, String fieldType,List<String> pledges) {

        try{
            HttpRequest req = new HttpRequest();
    
            ListCustomField bodyRequest = new ListCustomField();
            bodyRequest.FieldName = fieldName;
            bodyRequest.DataType = fieldType;
            if(pledges.size() > 0 ){
                bodyRequest.Options = pledges;
            }
            bodyRequest.VisibleInPreferenceCenter = true;
        
    
            req.setEndpoint('https://api.createsend.com/api/v3.1/lists/'+listId+'/customfields.json');
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
            
            System.debug('addSubscribers res--'+ res.getBody());

        }

        catch(Exception e){
           String msg = 'YALI_SendCampaign Exception--: ' + e.getMessage();
           PDCRM_ErrorLog.CreateNewError(String.valueof(e.getLineNumber()),e.getMessage(),'YALI_SendCampaign','AddCustomField','Sending Campaign to CM','https://api.createsend.com/api/v3.1/lists/','customfields.json');
        }


  }

    public class ListCustomField
    {
      public String FieldName {get;set;}
      public String DataType {get;set;}
      public List<String> options {get;set;}
      public Boolean VisibleInPreferenceCenter {get;set;}  
    }


    public PageReference CreateContactsInList() {

        String listId;
        try{
            ID CampaignId = Apexpages.currentPage().getParameters().get('Id');  
            List<Campaign> lstcm = [Select Name from Campaign where Id = :CampaignId and type = 'Campaign'];
            if(lstcm.size()>0){
                HttpRequest req = new HttpRequest();
        
                Campaign cm = [Select Name,wbsendit__Campaign_Monitor_Id__c from Campaign where Id = :CampaignId and type = 'Campaign'];
                System.debug('CampaignId --'+ CampaignId );
        
                List<CampaignMember> lstMembers = [Select Email,Campaign.Name,Country,City,Gender__c,Age__c
                                                             from CampaignMember where Campaign.Parent.Id = :CampaignId order by Email ];
        
        
                System.debug('lstMembers--'+ lstMembers.size());
                listOfSubscribers bodyRequest = new listOfSubscribers();
                bodyRequest.Resubscribe = true;
                bodyRequest.QueueSubscriptionBasedAutoResponders = false;
                bodyRequest.RestartSubscriptionBasedAutoresponders = true;
        
                bodyRequest.Subscribers = new List<listOfSubscribers.Subscriber>();
        
    /*          List<CMSubscriber> CMSL = new List<CMSubscriber>();
        
                for(CampaignMember cam : lstMembers ){
                    CMSubscriber CMS = new CMSubscriber();
                    CMS.EmailAddress = cam.Email;
                    CMS.CampaignName = cam.Campaign.Name;
                    CMSL.add(CMS);
                }
        
                List<CMSubscriber> calloutReqRes = new List<CMSubscriber>();
                Map<String, List<CMSubscriber>> subscriberMap = new Map<String, List<CMSubscriber>>();
    
                for(CampaignMember oh : lstMembers)
                {
                    CMSubscriber cmsub = new CMSubscriber();
                    cmsub.EmailAddress = oh.Email;
                    cmsub.CampaignName = oh.Campaign.Name;
                    calloutReqRes.add(cmsub);
                    subscriberMap.put(oh.Email, calloutReqRes);
                }     */    
    
                List<String> pickListValuesList= new List<String>();
                Schema.DescribeFieldResult fieldResult = Contact.Interests__c.getDescribe();
                List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
                for( Schema.PicklistEntry pickListVal : ple){
                    pickListValuesList.add(pickListVal.getLabel());
                }     
    
    
                List<CampaignMember> calloutReqRes = new List<CampaignMember>();    
                Map<String, List<CampaignMember>> subscriberMap = new Map<String, List<CampaignMember>>();
                for (CampaignMember oh : lstMembers) {
                    calloutReqRes.add(oh);              
                    subscriberMap.put(oh.Email, calloutReqRes);
                }
    
                for(String s: subscriberMap.KeySet()){
                    List<CampaignMember> campresp = subscriberMap.get(s);
                    listOfSubscribers.Subscriber cmc = new listOfSubscribers.Subscriber();
                    cmc.EmailAddress = s;
                    cmc.Name = '';
                    List<listOfSubscribers.CustomField> cfl = new List<listOfSubscribers.CustomField>();
                    for (Integer i = 0; i < campresp.size(); i++) {
                        if(s == campresp.get(i).Email){
                            listOfSubscribers.CustomField cf = new listOfSubscribers.CustomField();
                            cf.Key = 'Pledges';
                            cf.Value = campresp.get(i).Campaign.Name;
                            cfl.add(cf);                    
                            listOfSubscribers.CustomField cf1 = new listOfSubscribers.CustomField();
                            cf1.Key = 'Country';
                            cf1.Value = campresp.get(i).Country;
                            cfl.add(cf1);
                            listOfSubscribers.CustomField cf2 = new listOfSubscribers.CustomField();
                            cf2.Key = 'City';
                            cf2.Value = campresp.get(i).City;
                            cfl.add(cf2);
                            listOfSubscribers.CustomField cf3 = new listOfSubscribers.CustomField();
                            cf3.Key = 'Gender';
                            cf3.Value = campresp.get(i).Gender__c;
                            cfl.add(cf3);
                            listOfSubscribers.CustomField cf4 = new listOfSubscribers.CustomField();
                            cf4.Key = 'Age';
                            cf4.Value = String.valueof(campresp.get(i).Age__c);
                            cfl.add(cf4);                                   
    //                      listOfSubscribers.CustomField cf5 = new listOfSubscribers.CustomField();
    //                      cf5.Key = 'Interests';
    //                      cf5.Value = campresp.get(i).Campaign.Name;
    //                      cfl.add(cf5);
                        }
                    }
                    cmc.CustomFields = cfl;
                    bodyRequest.Subscribers.add(cmc);               
                }
    
    
    /*          for(String s: subscriberMap.KeySet()){
                    List<CMSubscriber> campresp = subscriberMap.get(s);
                    listOfSubscribers.Subscriber cmc = new listOfSubscribers.Subscriber();
                    cmc.EmailAddress = s;
                    cmc.Name = '';
                    List<listOfSubscribers.CustomField> cfl = new List<listOfSubscribers.CustomField>();
    
    
                    for (Integer i = 0; i < campresp.size(); i++) {
                        listOfSubscribers.CustomField cf = new listOfSubscribers.CustomField();
                        if(s == campresp.get(i).EmailAddress){
                            cf.Key = 'Pledges';
                            cf.Value = campresp.get(i).CampaignName;
                            cfl.add(cf);                    
                        }               
                    }
                    cmc.CustomFields = cfl;
                    bodyRequest.Subscribers.add(cmc);
                }   */
    
    
    
                listId = cm.wbsendit__Campaign_Monitor_Id__c;
                req.setEndpoint('https://api.createsend.com/api/v3.1/subscribers/'+listId+'/import.json');
                req.setMethod('POST');
        
                Blob headerValue = Blob.valueOf(KeyValueStoreHelper.getTextValue('UserName') + ':' + KeyValueStoreHelper.getTextValue('Password'));
                String authorizationHeader = KeyValueStoreHelper.getTextValue('AuthorizationHeader') + ' ' + EncodingUtil.base64Encode(headerValue);
        
                req.setHeader('Authorization', authorizationHeader);                          
                req.setBody(JSON.serialize(bodyRequest));
                System.debug('bodyRequest--'+ JSON.serialize(bodyRequest));
                
                Http http = new Http();
                HTTPResponse res;
                if(!Test.isRunningTest())
                  res = http.send(req);
                
        //        System.debug('addSubscribers res--'+ res.getBody());
        
                Pagereference proj = new Pagereference('/' + CampaignId);
                return proj;
            }
            else{
                ApexPages.Message  errorMessage = new ApexPages.Message(ApexPages.Severity.ERROR, 'Goto Campaign record to send data');
                ApexPages.addMessage(errorMessage);
                return null;
            }
        }
        
        catch(Exception e){
           String msg = 'YALI_SendCampaign Member Exception--: ' + e.getMessage();
           PDCRM_ErrorLog.CreateNewError(String.valueof(e.getLineNumber()),e.getMessage(),'YALI_SendCampaign Member','CreateContactsInList','Sending Contacts to CM','https://api.createsend.com/api/v3.1/subscribers',listId+'import.json');
            return null;
        }

    }


//    public class CMSubscriber
//    {
//        public String EmailAddress {get;set;}
//        public String CampaignName {get;set;}
//    }

        
}
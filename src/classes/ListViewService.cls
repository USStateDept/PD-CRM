/** This class gets the list view service **/
public with sharing class ListViewService {

    @TestVisible
    private static Map<String,String> fieldLogicMapping;
    //private static Map<String,String> missionClientIDMap;
    public static Map<String,Object> listViewObjectsMap;
    public static Set<String> subscribersListSet;
    //private Set<String> subscribersListSet;
    public static String sessionId;
    public static String clientID = '';
    static {

        fieldLogicMapping = new Map<String,String>();
        //missionClientIDMap = new Map<String,String>();

        fieldLogicMapping.put('notEquals','notequalto');
        fieldLogicMapping.put('equals','equals');
        //fieldLogicMapping.put('like','doesnotcontain');
        fieldLogicMapping.put('like','contains');
        //fieldLogicMapping.put('startswith','startswith');
        //fieldLogicMapping.put('greaterThanOrEqualTo','greaterThanOrEqualTo');
        //fieldLogicMapping.put('lessThanOrEqualTo','lessThanOrEqualTo');
/* Move these clients mapping to key_store__c
        missionClientIDMap.put('Mission Austria','bb7414cb5e5166bd24039dd3eb73ce34');
        missionClientIDMap.put('EUR - Austria - CRM Demo','db3ec9a7e0636494ceb0e7d030c69d24');
        missionClientIDMap.put('Mission United Kingdom','0688b8ec1c36f8e517c3e713487176c4');
        missionClientIDMap.put('Mission Indonesia','7c29d7d5ae8e75300dcb07d490acd760');
        missionClientIDMap.put('Mission ASEAN','a2e99b28867468dbe374523a713d921f');
        missionClientIDMap.put('IIP Front Office','fb120ddf91a8b31ce163f694e89a6e39');
*/
    }
    
    public static void getInterestsLists(Set<String> interestsLists) {
        if(interestsLists != null && interestsLists.size() > 0) {
            for(String name : interestsLists) {
                if(subscribersListSet != null && !subscribersListSet.contains(name)) {
                    String cmListID = createCampaignMonitorList(name);

                    if (String.isBlank(cmListID)) {
                        return;
                    }
                    
                    cmListID = cmListID.remove('"');
                    System.debug('cmListId...'+cmListID);
                }
            }
        }
    }
    
    //get the list of list views for the contacts
    public static void getContactsListViews(Set<String> newViewIds) {
        Set<String> viewIds = new Set<String>();
        Map<String,ListViewDetail> listViewMap = new Map<String, ListViewDetail>();
        
        for (ListView lv: [SELECT CreatedBy.UserRole.Name,CreatedDate,DeveloperName,Id,IsSoqlCompatible,
                Name,NamespacePrefix,SobjectType FROM ListView where sObjectType='Contact' 
                AND CreatedById = :UserInfo.getUserID() AND IsSoqlCompatible = true 
                AND DeveloperName NOT IN ('RecentlyViewedContacts','AllContacts','MyContacts','NewLastWeek'
                                        ,'NewThisWeek','BirthdaysThisMonth') AND 
                        (createdDate = YESTERDAY OR createdDate = TODAY 
                                            OR lastModifiedDate = YESTERDAY 
                                            OR lastModifiedDate = TODAY)]) {
            viewIds.add(lv.id);
            listViewMap.put(lv.id, new ListViewDetail(lv.CreatedBy.UserRole.Name,
                                                      lv.CreatedDate,lv.Name, lv.ID,lv.DeveloperName));
            
            System.debug(lv.id);
        }
        
        List<String> listViewIds = new List<String>(listViewObjectsMap.keySet());
        for(String listViewId : listViewIds) {
            ListView lv = (ListView) listViewObjectsMap.get(listViewId);
            listViewMap.put(listViewId, new ListViewDetail(lv.CreatedBy.UserRole.Name,
                                                      lv.CreatedDate,lv.Name, lv.ID,lv.DeveloperName));
        }       
        
        //Retrieve current user role name
        /*
        List<UserRole> urs = [SELECT Id, Name FROM UserRole WHERE Id = :UserInfo.getUserRoleId() LIMIT 1];
        if(urs != null && urs.size() > 0) {
            String roleName = urs.get(0).Name;
            clientID = missionClientIDMap.get(roleName);
            //Transaction 1
            String subListJSonResp = getSubscribersList(clientID);
            System.debug(subListJSonResp);
            if(subListJSonResp != null) {
                subscribersListSet = new Set<String>();
                List<Object> subListJSonRespObjList = (List<Object>)JSON.deserializeUntyped(subListJSonResp);
                for(Object subListJSonRespObj : subListJSonRespObjList) {
                    Map<String,Object> subListJSonMap = (Map<String, Object>)subListJSonRespObj;
                    //Add this to a new map for lookup later
                    String listName = (String)subListJSonMap.get('Name');
                    subscriberslistSet.add(listName);
                }
            }
        }
        */
        //Set<String> newViewIDs = searchForListViews(viewIds);
        //System.debug('newViewIDs...'+newViewIDs);
        //TODO:  This logic needs to be split as per Batch classes
        Integer loopCount = 0;
        for (String s: newViewIDs) {
            if (loopCount > 0){
                return;
            }
            loopCount++;
            //clientID = missionClientIDMap.get(listViewMap.get(s).roleName);
            //Transaction 2
            
            String jsonResponse = getListViewsDetails(s);
            System.debug(jsonResponse);
            if(jsonResponse == null) {
                return;
            }
            Map<String, Object> jsonRespObj = (Map<String, Object>)JSON.deserializeUntyped(jsonResponse);
            String queryString = (String) jsonRespObj.get('query');
            List<FieldCriteria> fcList = processJSON(jsonRespObj);
            
            //Transaction 3
            List<CMFieldCriteria> cmFieldCreterias = transformToCM(fcList);//TODO:  Failing
            
            String listViewName = listViewMap.get(s).listViewName;

            if(!subscribersListSet.contains(listViewName)) {
                //Transaction 4
                String cmListID = createCampaignMonitorList(listViewName);

                if (String.isBlank(cmListID)) {
                    return;
                }
                
                cmListID = cmListID.remove('"');
                System.debug('cmListId...'+cmListID);

                //Transaction 5
                syncContactsToList(cmListID,queryString,listViewMap.get(s).roleName);
                //Transaction 6
                ID crID = createSendItSubscriberList(cmListID,listViewMap.get(s).listViewName,clientID);
                createListViewRecord(cmListID,s,true);
                
                //TODO:  Create automatic subscription
                createSendITSubscription(cmListID,listViewMap.get(s).listViewName,clientId,cmFieldCreterias,crID);
            }
        }
    }

    @TestVisible
    private static void syncContactsToList(String cmListID, String queryString, String roleName){
        System.debug('---- Start syncContactsToList ---');
        List<sObject> contactList = Database.query(getQuery(queryString,roleName));
        List<SubscriberInfo> subsciberInfoList = new List<SubscriberInfo>();
        for (sObject s: contactList){
            Contact c = (Contact)s;
            if (String.isNotBlank(c.email))
                subsciberInfoList.add(new SubscriberInfo(c.email));
        }

        if (subsciberInfoList.size() ==0 ){
            return;
        }

        Subscriber s = new Subscriber(subsciberInfoList);

        HttpRequest req = new HttpRequest();
        String endPoint = 'https://api.createsend.com/api/v3.1/subscribers/'+cmListID+'/import.json';
        req.setEndpoint(endPoint);
        req.setMethod('POST');
        String authorizationHeader = 'Basic N2ZkZTdiMWVkNTdhMmE0N2NmNzQ4ODE0ZWEyZWEyM2U6bnVsbA==';
        req.setHeader('Authorization', authorizationHeader);
        System.debug(JSON.serialize(s));
        req.setBody(JSON.serialize(s));                                    
        Http http = new Http();
        HTTPResponse res = http.send(req);
        System.debug(res);
        System.debug(req);
        if (res.getStatusCode() == 201 || res.getStatusCode() == 200) {
            // res.getBody();
            //TODO: What to do here..

        } else if(res.getStatusCode() == 205) {
            //TODO:  Error Handling
        } else {
                //TODO:  Error Handling
        }
    
    }

    @TestVisible
    private static Id createSendItSubscriberList(String cmListID, String listName, String clientIdIn) {
        System.debug('--- Start createSendItSubscriberList ---');
        wbsendit__Subscriber_List__c subscriberList = new wbsendit__Subscriber_List__c();


        subscriberList.wbsendit__List_Id__c = cmListID;
        subscriberList.wbsendit__List_Name__c = listName;
        subscriberList.wbsendit__Campaign_Monitor_Client__c = [SELECT Id FROM wbsendit__Client__c where wbsendit__Client_Id__c = :clientIdIn].id;
        Database.UpsertResult  cr = Database.upsert(subscriberList, 
                                    wbsendit__Subscriber_List__c.Fields.wbsendit__List_Id__c, 
                                    true);

        return cr.getId();
        //TODO Check the return code

    }   

    @TestVisible
    private static void createSendITSubscription(String listName, String cmLISTID,
        String clientIdIn, List<CMFieldCriteria> cfcList, ID crID){

        //Id sendITSubscriberListID = [SELECT Id FROM wbsendit__Subscriber_List__c where wbsendit__List_Id__c = :cmLISTID LIMIT 1].id;
        
        wbsendit__AutoSubscription__c autoSub = new wbsendit__AutoSubscription__c();
        autoSub.Name = listName;
        autoSub.wbsendit__Subscriber_List_Id__c = cmLISTID;
        autoSub.wbsendit__Subscriber_List_Name__c = listName;
        autoSub.wbsendit__Object__c = 'Contact';
        autoSub.wbsendit__Action__c = 'Add';
        autoSub.wbsendit__Subscriber_List__c = crID;
        autoSub.wbsendit__Resubscribe__c = true;
        autoSub.wbsendit__Evaluation_Time__c = 'Every time a record is created or edited';
        autoSub.wbsendit__Criteria__c= JSON.serialize(cfcList);//TODO:  need to add proper validation rules for data types and operator
        insert autoSub;
    }


    @TestVisible
    private static String getQuery(String queryString, String roleName){

        String newQueryString = 'SELECT id, Email from Contact WHERE Account.Name = \'' + roleName + '\''; 
        Integer fromPosition = queryString.indexOfIgnoreCase('FROM CONTACT') + 12;

        Integer wherePosition = queryString.indexOfIgnoreCase(' WHERE ') + 7;
        Boolean hasWherePosition = true;
        if (wherePosition == 6) {
            hasWherePosition = false;
        }
        
        Integer orderByPosition = queryString.indexOfIgnoreCase(' ORDER BY ') + 1;
        Boolean hasOrderByPosition = true;

        if (orderByPosition == 0) {
            hasOrderByPosition = false;
        }

        if (hasWherePosition && hasOrderByPosition) {
            newQueryString = newQueryString + ' AND (' + 
                        queryString.substring(wherePosition,orderByPosition) + ' ) ' + 
                        queryString.substring(orderByPosition); 
        } else if (hasWherePosition){
            newQueryString = newQueryString + ' AND (' + 
                        queryString.substring(wherePosition) + ' ) ';
        } else if (hasOrderByPosition || fromPosition > 13){
            newQueryString = newQueryString +  
                        queryString.substring(fromPosition);
        }

        System.debug(newQueryString);
        
        return newQueryString;

    }

    @TestVisible
    private static String createCampaignMonitorList(String listName) {
        CMList cmListObj = new CMList(listName,
                                        'iipstate.createsend.com/t/GenericUnsubscribe',
                                        'AllClientLists',
                                        false,
                                        'iipstate.createsend.com/t/Confirmed');
        
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://api.createsend.com/api/v3.1/lists/' + clientID +'.json');
        req.setMethod('POST');
        String authorizationHeader = 'Basic N2ZkZTdiMWVkNTdhMmE0N2NmNzQ4ODE0ZWEyZWEyM2U6bnVsbA==';
        req.setHeader('Authorization', authorizationHeader);
        req.setBody(JSON.serialize(cmListObj));                                    
        Http http = new Http();
        HTTPResponse res = http.send(req);
        if (res.getStatusCode() == 201) {
            return res.getBody();

        } 

        return null;

    }

    @TestVisible
    private static Id createListViewRecord(String cmListID,String listViewID, boolean  contactsSynced) {
        System.debug('--- Start createListViewRecord ---');
        List_View_Sync__c lvi = new List_View_Sync__c();
        lvi.CM_List_View_ID__c = cmListID;
        lvi.List_View_ID__c = listViewID;
        lvi.Are_Contacts_Synced__c = contactsSynced;
        insert lvi;
        return lvi.id;
    }

    public static Set<String> searchForListViews(Set<String> viewIds) {
        Set<String> newViewIDs2 = new Set<String>();
        
        newViewIDs2.addAll(viewIds);
        for (List_View_Sync__c lvs : [SELECT id,Are_Contacts_Synced__c, 
                                        CM_List_View_ID__c, 
                                        List_View_ID__c from List_View_Sync__c 
                                        WHERE List_View_ID__c IN :viewIds]) {

            
            if (newViewIDs2.contains(lvs.List_View_ID__c)){
                newViewIDs2.remove(lvs.List_View_ID__c);    
            }
        }

        return newViewIDs2;
    }

    @TestVisible
    private static String getListViewsDetails(Id listViewID) {
        HTTP ht = new HTTP();
        HttpRequest hRequest = new HttpRequest();
        hRequest.setEndpoint(URL.getSalesforceBaseUrl().toExternalForm() + 
                                         '/services/data/v35.0/sobjects/Contact/listviews/' +
                                         listViewID + '/describe');
        hRequest.setMethod('GET');
        hRequest.setHeader('Authorization', 'OAuth ' + sessionId);
        HttpResponse hResponse = ht.send(hRequest);
        if(hResponse.getStatusCode() == 200)
            return hResponse.getBody();
        return null;      
    }

    @TestVisible
    public static String getSubscribersList(String clientIdIn) {
        HTTP ht = new HTTP();
        HttpRequest hRequest = new HttpRequest();
        hRequest.setEndpoint('https://api.createsend.com/api/v3.1/clients/' + clientIdIn +'/lists.json');
        hRequest.setMethod('GET');
        String authorizationHeader = 'Basic N2ZkZTdiMWVkNTdhMmE0N2NmNzQ4ODE0ZWEyZWEyM2U6bnVsbA==';
        hRequest.setHeader('Authorization', authorizationHeader);
        HttpResponse hResponse = ht.send(hRequest);

        if(hResponse.getStatusCode() == 200) {
            return hResponse.getBody();
        }
        
        return null;
    }

   /**
    ** Process JSON
    **/
    @TestVisible
    private static List<FieldCriteria> processJSON(Map<String, Object> jsonRespObj) {

        List<FieldCriteria> fieldCriterias = new List<FieldCriteria>();
        Map<String, Object>  whereCondition = (Map<String, Object>) jsonRespObj.get('whereCondition');
        System.debug(whereCondition);
        List<Object> conditions = (List<Object>) whereCondition.get('conditions');
        if (conditions == null || conditions.size() == 0){
            fieldCriterias.add(processACondition(whereCondition));
        } else {
            System.debug(conditions);
            for (Object condition : conditions){
                //TODO:  There can be multiple Conditions
                FieldCriteria fc = processACondition((Map<String, Object>) condition);
                if (fc != null)
                    fieldCriterias.add(fc);
            }
        }

        return fieldCriterias;

    }

   /**
    **  This method processes 'a' condition
    **/
    @TestVisible
    private static FieldCriteria processACondition(Map<String, Object> fieldCriteriaMap){
        System.debug(fieldCriteriaMap);
        System.debug(fieldCriteriaMap.get('field'));
        System.debug(fieldCriteriaMap.get('operator'));
        System.debug(fieldCriteriaMap.get('values'));
        if (!'Account.Name'.equals(fieldCriteriaMap.get('field'))) {
            FieldCriteria fc = new FieldCriteria((String) fieldCriteriaMap.get('field'),
                                            (String) fieldCriteriaMap.get('operator'),
                                            (Object []) fieldCriteriaMap.get('values'));    
            System.debug(fc);

            return fc;

        }

        return null;
    }

    
   /**
    ** This methid transforms to Campaign Monitor
    **/
    @TestVisible
    private static List<CMFieldCriteria> transformToCM(List<FieldCriteria> fieldCriterias) {

        List<CMFieldCriteria> cmFieldCriterias = new List<CMFieldCriteria>();
        for (FieldCriteria fc :  fieldCriterias){
            if(fc.field != null)
                cmFieldCriterias.add(new CMFieldCriteria(fc));
        }
        return cmFieldCriterias;

    }

    public class CMList {
        String Title {get;set;}
        String UnsubscribePage {get;set;}
        String UnsubscribeSetting {get;set;}
        Boolean ConfirmedOptIn {get;set;}
        String ConfirmationSuccessPage {get;set;}

        public CMList(String Title,String UnsubscribePage, String UnsubscribeSetting, 
                            Boolean ConfirmedOptIn, String ConfirmationSuccessPage) {
            this.Title = Title;
            this.UnsubscribePage = UnsubscribePage;
            this.UnsubscribeSetting = UnsubscribeSetting;
            this.ConfirmedOptIn = ConfirmedOptIn;
            this.ConfirmationSuccessPage = ConfirmationSuccessPage;

        }

    }

    public class CMFieldCriteria {
        String fieldName {get;set;}
        String fieldTypeName {get;set;}
        String operatorName {get;set;}
        String value {get;set;}
        Boolean isPickList {get;set;}

        public CMFieldCriteria(FieldCriteria fc) {
            this.fieldName = fc.field;
            this.fieldTypeName = getFieldType(fc.field).toUpperCase();
            this.operatorName = fieldLogicMapping.get(fc.operator);
            if (this.fieldTypeName.equalsIgnoreCase('PickList')){
                this.isPickList = true;
            } else {
                this.isPickList = false;
            }
            //this.operatorName = fc.operator;
            Integer cnt = 0;
            for (Object o : fc.values){
                if (cnt == 0){
                    this.value = (String)o; 
                    cnt++;
                } else {
                    this.value += ','+(String)o;
                }

                if (this.value == null || this.value == '' || this.value == 'null') {
                    this.value = '';
                } else if (this.value.contains('%') || this.value.contains('\'')) {
                    this.value = this.value.remove('%');
                    this.value = this.value.remove('\'');
                } 
                
                
            }
        }

        private String getFieldType(String field) {
            
            Schema.DisplayType f =  Schema.sObjectType.Contact.fields.getMap().get(field).getDescribe().getType();
            System.debug(f);
            if (Schema.DisplayType.String == f) {
                return 'STRING';
            } else if (Schema.DisplayType.Picklist == f) {
                return 'PICKLIST';
            } else if (Schema.DisplayType.TextArea == f) {
                return 'TEXTAREA';
            } else if (Schema.DisplayType.Phone == f) {
                return 'PHONE';
            } else if (Schema.DisplayType.Integer == f) {
                return 'INTEGER';
            }

            return 'STRING';

        }
    }

    public class FieldCriteria {
        String field {get;set;}
        String operator {get;set;}
        Object[] values {get;set;}
        String queryString {get;set;}

        public FieldCriteria(String field,String operator, Object[] values) {

            this.field = field;
            this.operator = operator;
            this.values = values;

        }

    }

    public Class SubscriberInfo {
        String EmailAddress{get;set;}
        String Name {get;set;}

        public SubscriberInfo() {

        }

        public SubscriberInfo(String EmailAddress){
            this.EmailAddress = EmailAddress;
            this.Name = '';
        }

    }

    public class Subscriber {
        Boolean Resubscribe {get;set;}
        Boolean QueueSubscriptionBasedAutoResponders {get;set;}
        Boolean RestartSubscriptionBasedAutoresponders {get;set;}
        List<SubscriberInfo> Subscribers {get;set;}
        public Subscriber(List<SubscriberInfo> Subscribers){
            this.Subscribers = Subscribers;
            this.QueueSubscriptionBasedAutoResponders = false;
            this.RestartSubscriptionBasedAutoresponders = true;
            this.Resubscribe = true;
        }
    }

    public class ListViewDetail {
        String roleName {get;set;}
        DateTime createDate {get;set;}
        String listViewName {get;set;}
        String listViewID {get;set;}
        String DeveloperName {get;set;}
        String query {get;set;}

        public ListViewDetail() {

        }

        public ListViewDetail(String roleName,DateTime createDate,String listViewName, String listViewID, String DeveloperName) {
            this.roleName = roleName;
            this.createDate = createDate;
            this.listViewName = listViewName;
            this.listViewID = listViewID;
            this.DeveloperName = DeveloperName;

        }
    }




}
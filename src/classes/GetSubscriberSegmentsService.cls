public with sharing class GetSubscriberSegmentsService {
    
    public static void updateSubsDetails(List<wbsendit__Subscription__c> lstSubs){
		List<wbsendit__Subscription__c> lstUpdateValue = new List<wbsendit__Subscription__c>();
        
        Map<String,String> mapSegmentUpdate = new Map<String,String>();
        List<String> lstContactID = new List<String>();	//This will save the Contact Id List
        
        for(wbsendit__Subscription__c objwSub : lstSubs){
            
            String strEndPointURl = 'https://api.createsend.com/api/v3.1/lists/'+ objwSub.wbsendit__List_Id__c +'/segments.json';            
            String jsonResp = processHttpCalls(strEndPointURl);
            System.debug('**** jsonResp ' + jsonResp);
            List<list_segmentsObject> respList = (List<list_segmentsObject>) System.JSON.deserialize(jsonResp, List<list_segmentsObject>.class);
            for(list_segmentsObject resp : respList){
                String strEndPointURl2 = 'https://api.createsend.com/api/v3.1/segments/'+ resp.SegmentID  +'/active.json?date=2015-01-03&page=1&pagesize=10&orderfield=date&orderdirection=asc';            
            	String jsonRespSegment = processHttpCalls(strEndPointURl2);
                System.debug('***** jsonRespSegment ' + jsonRespSegment);
                active_subscribersObject actSigment = (active_subscribersObject) System.JSON.deserialize(jsonRespSegment, active_subscribersObject.class);
                for(Results objRes : actSigment.Results){
                    for(CustomFields objcf : objRes.CustomFields){
                        System.debug('***** objRes ' + objRes.EmailAddress);
                        System.debug('***** objRes ' + objRes);
                        System.debug('***** objcf ' + objcf.Key);
                        System.debug('***** objcf 1 ' + objcf.Value);
                        
                        if(objcf.Key =='Salesforce Contact Id'){
                            lstContactID.add(objcf.Value);
                            mapSegmentUpdate.put(objcf.Value+resp.ListID,resp.Title);
                        }
                    }
                }
            }
        }
        System.debug(' *** mapSegmentUpdate ' + mapSegmentUpdate);
        //Get all the Contacts and update Segment Title
        List<wbsendit__Subscription__c> lstsubc = [Select id, Segments__c,wbsendit__Contact__c,wbsendit__List_Id__c from wbsendit__Subscription__c where wbsendit__Contact__c IN:lstContactID];
        for(wbsendit__Subscription__c ws : lstsubc){
            System.debug('***** Segment ' + mapSegmentUpdate.get(ws.wbsendit__Contact__c+ws.wbsendit__List_Id__c));
            if(mapSegmentUpdate.get(ws.wbsendit__Contact__c+ws.wbsendit__List_Id__c)==null) continue;
            
            if(ws.Segments__c==null)
            	ws.Segments__c = mapSegmentUpdate.get(ws.wbsendit__Contact__c+ws.wbsendit__List_Id__c);
            else
            	ws.Segments__c = ws.Segments__c + ', ' + mapSegmentUpdate.get(ws.wbsendit__Contact__c+ws.wbsendit__List_Id__c);
        }
        
        if(!lstsubc.isEmpty()) update lstsubc;
    }
    
    public static String processHttpCalls(String strEndPointURL){
        HttpRequest req = new HttpRequest();
            System.debug('**** ' + strEndPointURL);
            req.setEndpoint(strEndPointURL);
            req.setMethod('GET');
            Blob headerValue = Blob.valueOf(KeyValueStoreHelper.getTextValue('UserName') + ':' + KeyValueStoreHelper.getTextValue('Password'));
            String authorizationHeader = KeyValueStoreHelper.getTextValue('AuthorizationHeader') + ' ' + EncodingUtil.base64Encode(headerValue);
            req.setHeader('Authorization', authorizationHeader); 
            
            Http http = new Http();
            HTTPResponse res = http.send(req);
            System.debug(res.getBody());   
	
	        return res.getBody();
    }
    
    public class list_segmentsObject{
        public String ListID;
        public String SegmentID;
        public String Title;
    }
    public class CustomFields {
        public String Key;
        public String Value;
    }    
    public class Results {
        public String EmailAddress;
        public String Name;
        public String Dates;
        public String State;
        public List<CustomFields> CustomFields;
    }
    public class active_subscribersObject {
        public List<Results> Results;
        public String ResultsOrderedBy;
        public String OrderDirection;
        public Integer PageNumber;
        public Integer PageSize;
        public Integer RecordsOnThisPage;
        public Integer TotalNumberOfRecords;
        public Integer NumberOfPages;
        
    }   
}
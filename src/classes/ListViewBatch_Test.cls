@isTest
public class ListViewBatch_Test {
    @testsetup
    static void setup() {
        Interest__c interest1 = new Interest__c(Name='Arts/Music/Culture',is_Active__c=true);
        Interest__c interest2 = new Interest__c(Name='Business/Finance/Trade',is_Active__c=true);
        Interest__c interest3 = new Interest__c(Name='Diversity/Minorities/Migration',is_Active__c=true);
        List<Interest__c> interests = new List<Interest__c>();
        interests.add(interest1);
        interests.add(interest2);
        interests.add(interest3);
        insert interests;
    }
    
    static testMethod void execute() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockListView());
        ListViewBatch batch = new ListViewBatch();
        Database.executeBatch(batch);
        Test.stopTest();
    }
    
    class MockListView implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest request) {
            Map<String,Object> clientIdMap1 = new Map<String,Object>();
            clientIdMap1.put('ClientID', 'db3ec9a7e0636494ceb0e7d030c69d24');
            clientIdMap1.put('Name', 'EUR - Austria - CRM Demo');
            
            Map<String,Object> clientIdMap2 = new Map<String,Object>();
            clientIdMap2.put('ClientID', '2c375fd4362ad5420d85975d50276fce');
            clientIdMap2.put('Name', 'Washington DC');
            
            Map<String,Object> listMap1 = new Map<String,Object>();
            listMap1.put('ListID', 'aa7db5775702cbf386b160b97638e209');
            listMap1.put('Name', 'Agriculture');
            
            Map<String,Object> listMap2 = new Map<String,Object>();
            listMap2.put('ListID', 'aa7db5775702cbf386b160b97638e209');
            listMap2.put('Name', 'Democracy/Governance/Civil Society');
            
			Map<String,Object> listMap3 = new Map<String,Object>();
            listMap3.put('ListID', 'bafb05f31e2bc81754ce2da8f8283603');
            listMap3.put('Name', 'Information Resource Center');
            
            List<Map<String,Object>> subsribersList  = new List<Map<String,Object>>();
            subsribersList.add(listMap1);
            subsribersList.add(listMap2);
            subsribersList.add(listMap3);
            subsribersList.add(clientIdMap1);
            subsribersList.add(clientIdMap2);
            String jsonResp = JSON.serialize(subsribersList);
            
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody(jsonResp);
            response.setStatusCode(200);
            return response;
        }
    }
}
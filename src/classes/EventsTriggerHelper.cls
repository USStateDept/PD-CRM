public with sharing class EventsTriggerHelper extends TriggerHelper{

    public override void processAfterInsert() {
        CreateNewList(trigger.newMap,trigger.oldMap);
    }

    public override void processBeforeUpdate() {
        CreateNewList(trigger.newMap,trigger.oldMap);
        UpdateList(trigger.newMap,trigger.oldMap);
    }

    public override void processAfterUpdate() {

    }
    
    public override void processBeforeInsert(){
    	updateEvent(trigger.new);
    }
    
    public void updateEvent(List<Event__c> newEvents){
    	 //1. Retrieve current user role name  
        //2. Retrieve an account by user role name from step 1 (account and user role name have the same name)
        //3. Assign an account id from step 2 to the current event before insert to populate host account
                
        String roleid = UserInfo.getUserRoleId();
        String accountId;
        String profId = UserInfo.getProfileId();
        Map<String,UserRole> userRoleMap = new Map<String,UserRole>();
        Map<String,Account> accountMap = new Map<String,Account>();
        
        for (Event__c eve : newEvents){ 
            //Need to check if event doesn't have any host account; otherwise, the unit tests will fail
            if(eve.Host_Account__c == null) {
                //check for user profileID = PD CRM
                List <Profile> p = [select id, name from Profile where Id = :profid LIMIT 1];
                String pr = p.get(0).Name;
                
                List <UserRole> ur = null;
                
                if(!userRoleMap.containsKey(roleId)) {
                    ur = [select Id, name from UserRole
                          Where id = :roleid LIMIT 1];
                } else {
                    ur = new List<UserRole>();
                    ur.add(userRoleMap.get(roleId));
                }
                
                if(ur != null && ur.size() > 0) {
                    String userRole = ur.get(0).Name;
                    if(!userRoleMap.containsKey(roleId)) {
                        userRoleMap.put(userRole, ur.get(0));
                    }
                    
                    List<Account> accounts = null;

                    if(!accountMap.containsKey(userRole)) {
                        accounts = [SELECT id, name FROM Account 
                                    WHERE name = :userRole LIMIT 1];
                    }
                    else {
                        accounts = new List<Account>();
                        accounts.add(accountMap.get(userRole));
                    }

                    if(accounts != null && accounts.size() > 0) {
                        Account account = accounts.get(0);
                        accountId = account.Id;
                        if(!accountMap.containsKey(userRole)) {
                            accountMap.put(userRole, account);
                        }
                    }
                    else{
                        System.debug('$$$$$$$$$$$$');
                    }            
                    
                }
                System.debug('accountId: '+accountId);
                if (pr.equalsIgnoreCase('PD CRM')) {
                	system.debug('Host Account is set');
                    eve.Host_Account__c = accountId;
                }
            }           
            
        } 
 }
 

    public void CreateNewList(Map<Id, SObject> newMap,Map<Id, SObject> oldMap){
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
                clientId = 'db3ec9a7e0636494ceb0e7d030c69d24';
            }                
        }
        else{
            clientId = 'db3ec9a7e0636494ceb0e7d030c69d24';    
        }
        system.debug('clientId' + clientId);
        for(SObject eventSObject : trigger.newMap.Values()){
            Event__c eventNewInstance = (Event__c) eventSObject;
            String listId = eventNewInstance.Id;
            String regAttend = String.valueof(eventNewInstance.Registered_Attendees__c);
            system.debug('listId' + eventNewInstance.Status__c);
            system.debug('listId' + eventNewInstance.Campaign_Monitor_List_Id__c);
            if(eventNewInstance.Status__c == 'Published' && eventNewInstance.Campaign_Monitor_List_Id__c == null){
                //String listId = wbsendit.SendItAPI.createSubscriberList(clientId , eventNewInstance.Name);
                CreateContactsInSegments.CreateList(clientId,eventNewInstance.Name,listId,regAttend);
                system.debug('listId' + listId);
            }
        }
    }

    public void UpdateList(Map<Id, SObject> newMap,Map<Id, SObject> oldMap){
        User user = [Select Alias, UserRoleId, UserRole.Id, UserRole.Name from User where Id = :UserInfo.getUserId()];
        string roleName = user.UserRole.Name;
        system.debug('roleName' + roleName);
        for(SObject eventSObject : trigger.newMap.Values()){
            Event__c eventNewInstance = (Event__c) eventSObject;
            Event__c eventOldInstance = (Event__c) trigger.oldMap.get(eventNewInstance.Id);
            String listId = eventNewInstance.Id;
            String regAttend = String.valueof(eventNewInstance.Registered_Attendees__c);
            //Update Event Name in CM
            if(eventNewInstance.Campaign_Monitor_List_Id__c != null && (eventNewInstance.Name != eventOldInstance.Name)){
                CreateContactsInSegments.UpdateList(eventNewInstance.Campaign_Monitor_List_Id__c,eventNewInstance.Name);
            }
            else if(eventNewInstance.Status__c == 'Completed' && (eventNewInstance.Status__c != eventOldInstance.Status__c)){
                //GetSegments
              CreateContactsInSegments.GetSegments(eventNewInstance.Campaign_Monitor_List_Id__c);
            }   
            else if(eventNewInstance.Status__c == 'Cancelled'){
                //DeleteSegments
              CreateContactsInSegments.DeleteList(eventNewInstance.Campaign_Monitor_List_Id__c);
            }   

        }
    }
 

}
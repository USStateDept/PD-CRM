public with sharing class ContactTriggerHandler {
	public void onBeforeInsert(List<Contact> newContacts)
    {
        System.debug('Contact Trigger On Before Insert');
		updateContact(newContacts);
    }
    
    public void onAfterInsert(List<Contact> newContacts)
    {
         System.debug('Contact Trigger On After Insert');
    }
    
    public void onAfterUpdate( List<Contact> newContacts, List<Contact> oldContacts, Map<ID, Contact> newContactMap , Map<ID, Contact> oldContactMap )
    {
        System.debug('Contact Trigger On After Update ');
    }
    
    public void onBeforeUpdate( List<Contact> newContacts, List<Contact> oldContacs, Map<ID, Contact> newContactMap , Map<ID, Contact> oldContactMap )
    {
        System.debug('Contact Trigger On Before Update ');
        updateContact(newContacts);
    }
        
    public void updateContact(List<Contact> newContacts) {
        //1. Retrieve current user role name  
        //2. Retrieve an account by user role name from step 1 (account and user role name have the same name)
        //3. Assign an account id from step 2 to the current contact before insert
                
        String roleid = UserInfo.getUserRoleId();
        String accountId;
        String profId = UserInfo.getProfileId();
        Map<String,UserRole> userRoleMap = new Map<String,UserRole>();
        Map<String,Account> accountMap = new Map<String,Account>();
        
        for (Contact con : newContacts){ 
            //Need to check if contact doesn't have any assigned account; otherwise, the unit tests will fail
            if(con.AccountId == null) {
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
                
                if (pr.equalsIgnoreCase('PD CRM')) {
                    con.AccountId = accountId;
                }
            }
            
            if(con.eContacts__Created_By_eContacts__c == true) {
                con.LeadSource = 'Card Scanner';
                if(con.LeadSource == null){
                    con.LeadSource = 'Manual';
                }
            }
            
        } 
    }
}
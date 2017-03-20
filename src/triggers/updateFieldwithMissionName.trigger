trigger updateFieldwithMissionName on Contact (before insert, before update, after insert, after update){ 
    ContactTriggerHandler handler = new ContactTriggerHandler();
    
    if(Trigger.isInsert) {
        if(Trigger.isBefore) {
            handler.onBeforeInsert(Trigger.new);
        }
    }
    else if(Trigger.isUpdate) {
        if(Trigger.isBefore) {
            handler.onBeforeUpdate(Trigger.new, Trigger.old, Trigger.newMap, Trigger.oldMap);
        }
        else {
            handler.onAfterUpdate(Trigger.new, Trigger.old, Trigger.newMap, Trigger.oldMap);
        }
    }
        //1. Retrieve current user role name  
        //2. Retrieve an account by user role name from step 1 (account and user role name have the same name)
        //3. Assign an account id from step 2 to the current contact before insert
            
    /*
    String roleid = UserInfo.getUserRoleId();
    String accountId;
    String profId = UserInfo.getProfileId();
    Map<String,UserRole> userRoleMap = new Map<String,UserRole>();
    Map<String,Account> accountMap = new Map<String,Account>();
    
        for (Contact con : Trigger.new){ 
            //Need to check if contact doesn't have any assigned account; otherwise, the unit tests will fail
            if(con.AccountId == null) {
                //check for user profileID = PD CRM
                List <Profile> p = [select id, name from Profile where Id = :profid LIMIT 1];
                    String pr = p.get(0).Name;
                    System.debug('current profile is...'+pr);
                
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
                    System.debug('current user role...'+userRole);
                    if(!userRoleMap.containsKey(roleId)) {
                        userRoleMap.put(userRole, ur.get(0));
                    }
                    
                    List<Account> accounts = null;
                    
                    if(!accountMap.containsKey(userRole)) {
                        accounts = [SELECT id FROM Account 
                                    WHERE name = :userRole LIMIT 1];
                    }
                    else {
                        accounts = new List<Account>();
                        accounts.add(accountMap.get(userRole));
                    }
                    
                    if(accounts != null && accounts.size() > 0) {
                        Account account = accounts.get(0);
                        System.debug('account id...'+account.Id);
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
                   System.debug('account is assigned to contact...'+con);  
                }
            }
            
            if(con.eContacts__Created_By_eContacts__c == true) {
                con.LeadSource = 'Card Scanner';
                if(con.LeadSource == null){
                    con.LeadSource = 'Manual';
                }
            }

        } 
*/
}
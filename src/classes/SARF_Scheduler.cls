global class SARF_Scheduler implements Schedulable {
    
    global void execute(SchedulableContext sc) {
        deactivateUsers();
        deactivateSarfs();
    }
    
    //Deactivate users if they reach their expiration dates
    @Future(callout=true)
	global static void deactivateUsers() {
        
        //Query all users with expiration_date__c is today
        List<CMS_SARF__c> expiredSarfsList = [SELECT User_ID__c, expiration_date__c, is_deactivated__c, is_current__c
                                              	FROM CMS_SARF__C
												WHERE expiration_date__c = TODAY
                                             	AND is_deactivated__c = false
                                             	AND is_current__c = true];

        //Loop thru each expired Sarf to build a user ids list and update
        //these users' isActive to 'false'
        if(expiredSarfsList != null && expiredSarfsList.size() > 0) {
        	Set<Id> userIds =  new Set<Id>();
            for(CMS_SARF__c sarf : expiredSarfsList) {
                //Add ids to the list to deactivate users later
                userIds.add(sarf.User_ID__c);
            }
            
            //Update users
            if(!userIds.isEmpty()) {
                List<User> expiredUsers = 
                    [SELECT name, id, isActive FROM User WHERE id IN :userIds];
                if(expiredUsers != null && !expiredUsers.isEmpty()) {
                    Integer i = 0;
                    for(User expiredUser : expiredUsers) {
                        expiredUser.isActive = false;
                        expiredUsers.set(i, expiredUser);
                        i++;
                    }
                    update(expiredUsers);
                }
                
            }//end of if userIds is not empty
        }//end of expiredSarfsList
    }
    
    @Future(callout=true)
    global static void deactivateSarfs() {
        List<CMS_SARF__c> expiredSarfsList = [SELECT User_ID__c, expiration_date__c, is_deactivated__c, is_current__c
                                              	FROM CMS_SARF__C
												WHERE expiration_date__c = TODAY
                                             	AND is_deactivated__c = false
                                             	AND is_current__c = true];
        if(expiredSarfsList != null && !expiredSarfsList.isEmpty()) {
            Integer i = 0;
            for(CMS_SARF__c sarf : expiredSarfsList) {
                //Deactivate SARFs
                sarf.Is_Deactivated__c = true;
                sarf.Current_Time_Tracker__c = DateTime.now();
                expiredSarfsList.set(i,sarf);
                i++;
            }
            update(expiredSarfsList);
        }

    }
}
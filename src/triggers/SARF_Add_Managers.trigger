trigger SARF_Add_Managers on CMS_SARF__c (before insert, before update) {
    /*
    List<GroupMember> GMlist = new List<GroupMember>();
    List<Id> userIdList = new List<Id>();    
    
    Group theGroup = [select id from Group where Name = 'SARF Managers'];
    
    if(theGroup != NULL){
        theGroup = new Group();
    }
    
    for(CMS_SARF__c sarf : Trigger.New){
        if(sarf.manager__c != NULL){ // this will handle all SARFs except for the initial externally created non AmericanSpaces Site.com SARFs
            // Set String "role" to Sarf Role__c value
            String role = sarf.role__c;
            // Query Users with the role approver permission set
            //if(String.isNotEmpty(role) && role.endsWith('Approver')) {
                
            //}
            // Add Manager__c to list (this is the approving manager)
            userIdList.add(sarf.manager__c);       
        }
    }
    
    theGroup = [select id from Group where Name = 'SARF Managers'];
    if(theGroup != NULL){
        // Need to clear the Manager group first, then add users to group
        SARF_Manager_Group_Creator.addUsersToGroup(theGroup.id, userIdList);
    }*/
}
public with sharing class PreferenceTriggerHelper extends TriggerHelper{

    public override void processAfterInsert() {
        InsertContactShare(trigger.new);
    }
    
    public override void processAfterDelete() {
        DeleteContactShare(trigger.old);
    }
    
    public override void processAfterUpdate() {
        DeleteContactShare(trigger.old);
        InsertContactShare(trigger.new);
    }
    
    
    public void InsertContactShare(List<Preference__c> newList){
    
        List<ContactShare> contactShares = new List<ContactShare>();
        for (Preference__c pref : newList) 
        {
            if (pref.Country__c != null) {
                
                //String prefName = '%' + pref.Country__c.replaceAll(' ','_');
                List<Preference_Country__c> prefCountry;
                String prefName;
                prefCountry = [select Role__c from Preference_Country__c WHERE Name = :pref.Country__c];
                if(prefCountry.size() > 0){
                    prefName = prefCountry.get(0).Role__c;
                }
                Id groupId;
                if(prefName != null){
                    groupId = [select id from Group WHERE DeveloperName LIKE :prefName and type = 'Role'].Id;
                }    
        
                if(groupId != null){
                    if (!Test.isRunningTest()) {
                        ContactShare contactShare = new ContactShare();
                        contactShare.ContactId = [SELECT ID, ContactName__c from  Preference__c where id = :pref.id].ContactName__c;
                        contactShare.ContactAccessLevel = 'Edit';
                        contactShare.UserOrGroupId = groupId;
                        contactShares.add(contactShare);
                    }
                }
                else{
                    pref.addError('Adding ' + pref.Country__c + ' is not allowed');
                }
            }
            
        }
        //insert contact share record
        if (!contactShares.isEmpty())
        insert contactShares;
    
    
    }
    
    public void DeleteContactShare(List<Preference__c> oldList){
    
        for (Preference__c pref : oldList){
        
            //String prefName = '%' + pref.Country__c.replaceAll(' ','_');
            List<Preference_Country__c> prefCountry;
            String prefName;
            prefCountry = [select Role__c from Preference_Country__c WHERE Name = :pref.Country__c];
            if(prefCountry.size() > 0){
                prefName = prefCountry.get(0).Role__c;
            }
            ID groupId;
            if(prefName != null){
                groupId = [select id from Group WHERE DeveloperName LIKE :prefName and type = 'Role'].Id;
            }

            System.debug('groupId --'+groupId );
            Delete [Select Id from ContactShare where UserOrGroupId = :groupId and ContactId = :pref.ContactName__c];
        }
    }
        
}
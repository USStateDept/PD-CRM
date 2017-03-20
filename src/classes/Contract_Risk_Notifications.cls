public class Contract_Risk_Notifications{

    //Checks to see if owner has changed, comparing new ('n') and old ('o') triggers
    public static boolean checkNewOwner(Contract_Risk__c[] n, Contract_Risk__c[] o){
       boolean isNew = false;
       for (Contract_Risk__c x: n){ // for each Risk in new trigger
           for (Contract_Risk__c y: o){  // iterate through each Risk in old trigger
               isNew = false; // no new assignment
               x.Is_New_Assignment__c = isNew; // set is_new_assignment__c checkbox to false
               if (x.id == y.id){ // if Risk id is found in both new and old trigger
                   if (!(((String)x.OwnerId).equals((String)y.OwnerId))){
                      isNew = true; // new assignment!
                      x.Is_New_Assignment__c = isNew; // set checkbox to true
                   }
               }
           }
        }
        return isNew;
    }
  
    //Checks to see if Risk has been triggered, comparing new ('n') and old ('o') triggers
    public static boolean checkTriggered(Contract_Risk__c[] n, Contract_Risk__c[] o){
        boolean isTriggered = false;
        for (Contract_Risk__c x: n){ // for each Risk in new trigger
            for (Contract_Risk__c y: o){ // iterate through each Risk in old trigger
                if (x.id == y.id){ // if Risk id is found in both new and old trigger
                    // if new is triggered, old is not, OR if date triggered !null
                    if ((x.RARisk_Status__c == 'TRIGGERED' && y.RARisk_Status__c != 'TRIGGERED')){
                        x.IADateTime_Triggered__c = DateTime.now();
                        isTriggered = true;
                        x.Is_Triggered__c = isTriggered; // set is_Triggered__c checkbox to true, email alert will fire
                    }else if(x.RARisk_Status__c != 'TRIGGERED' && y.RARisk_Status__c == 'TRIGGERED'){ // 
                        isTriggered = false;
                        x.Is_Triggered__c = isTriggered; // set is_Triggered__c checkbox to false, email alert will not fire
                        x.IADateTime_Triggered__c = null;
                    }
                }
            }
        }
        return isTriggered;
    }
}
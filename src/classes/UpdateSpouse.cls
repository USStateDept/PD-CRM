/*
User Story:W-000312
Invoked From: UpdateSpouse process builder
Requirement: When spouse field gets populated on a Contact, it will update Spouse fild on selected Contact

*/


public class UpdateSpouse{
@InvocableMethod
    public static void UpdateSpouseField(List<Id> sId){
        
        //Gets selected Spouse Id  
        //Contact con = [Select Spouse__c,Id from Contact where Id = :sId];
        /******** 9-15-16 FIX *********/
        List<Contact> spouses = [Select Spouse__c,Id from Contact where Id IN :sId];

        //Make it null if SpouseField has been removed
//System.debug('sId--' + sId);
//System.debug('Spouse--' + con.Spouse__c);

		/******** 9-15-16 FIX *********/
        if(spouses != null) {
            for(Contact con : spouses) {
                //Make it null if SpouseField has been removed
            	if(con.Spouse__c == null){
                    //No need to run the same query here
                    Contact remCon = con;
                    remCon.Spouse__c = null;
                    Update remCon;
                }
                
                //Update Spouse field on the selected contact
                else {
                    Contact updCon = [Select Spouse__c from Contact where Id = :con.Spouse__c];
                    updCon.Spouse__c = con.Id;
                    Update updCon;
                    
                    //Delete if any Contact has this Contact Id as Spouse
                    List<Contact> delListCon = [Select Spouse__c,Id from Contact where Spouse__c = :sId and Id != :con.Spouse__c];
                    if (delListCon.size() > 0) 
                    {
                        Contact delCon = [Select Spouse__c,Id from Contact where Spouse__c = :sId and Id != :con.Spouse__c];
                        delCon.Spouse__c = null;
                        update delCon;
                    }
                }
            }
        }
//    if(!Test.isRunningTest()){
       /* if(con.Spouse__c == null){
            Contact remCon = [Select Spouse__c from Contact where Id = :sId];
            remCon.Spouse__c = null;
            Update remCon;
        }*/
//    }
        
        //Update Spouse field on the selected contact
        /*if(con.Spouse__c != null){
            Contact updCon = [Select Spouse__c from Contact where Id = :con.Spouse__c];
            updCon.Spouse__c = con.Id;
            Update updCon;
        }*/
       
        //Delete if any Contact has this Contact Id as Spouse
        /*List<Contact> delListCon = [Select Spouse__c,Id from Contact where Spouse__c = :sId and Id != :con.Spouse__c];
        if (delListCon.size() > 0) 
        {
            Contact delCon = [Select Spouse__c,Id from Contact where Spouse__c = :sId and Id != :con.Spouse__c];
            delCon.Spouse__c = null;
            update delCon;
        }*/
 
    }
}
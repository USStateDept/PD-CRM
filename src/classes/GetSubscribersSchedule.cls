global class GetSubscribersSchedule implements Schedulable {
    
    global void execute(SchedulableContext sc) {
        GetSubscriberDetailsBatch b = new GetSubscriberDetailsBatch(); 
        database.executebatch(b,5);
        //updateSubsDetails();
   }
/*
    @Future(callout=true)
    global static void updateSubsDetails() {
        List<wbsendit__Subscription__c> subscribers = (List<wbsendit__Subscription__c>) 
            [Select id, wbsendit__Email__c, wbsendit__List_Id__c, 
             wbsendit__State__c, wbsendit__Lead__c 
             from wbsendit__Subscription__c 
             where wbsendit__State__c = 'Active' and wbsendit__Lead__c != null
             LIMIT 30];
        if(subscribers != null) {
            GetSubscriberDetailsService.updateSubsDetails(subscribers);
        }
    }
*/
}
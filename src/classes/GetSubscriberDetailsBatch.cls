global class GetSubscriberDetailsBatch implements Database.Batchable<SObject>, Database.AllowsCallouts {

    Map<String, String> calloutResponse = new Map<String, String>();
    
   global Database.queryLocator start(Database.BatchableContext ctx){
        return Database.getQueryLocator([Select id, wbsendit__Email__c, wbsendit__List_Id__c, 
                                         wbsendit__State__c, wbsendit__Lead__c 
                                         from wbsendit__Subscription__c 
                                         where wbsendit__State__c = 'Active' 
                                         and wbsendit__Lead__c != null
                                         and wbsendit__Subscriber_List__r.wbsendit__List_Name__c LIKE '%Lead%'
                                        ]);
    }
    
    global void execute(Database.BatchableContext ctx, List<Sobject> subscribers){
        List<wbsendit__Subscription__c> getSubscribers = (List<wbsendit__Subscription__c>)subscribers;
        
        System.debug('***** lstSubs ' + getSubscribers.size());
        
        GetSubscriberDetailsService.updateSubsDetails(getSubscribers );
        
    }
        
    global void finish(Database.BatchableContext ctx){

                AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed,
                            TotalJobItems, CreatedBy.Email
                            FROM AsyncApexJob WHERE Id =:ctx.getJobId()];

        // Send an email to the Apex job's submitter notifying of job completion.
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
 //         String[] toAddresses = new String[] {a.CreatedBy.Email};
        String[] toAddresses = new String[] {'satya.malla@reisystems.com'};
        mail.setToAddresses(toAddresses);
        mail.setSubject('Subscriber details ' + a.Status);
        mail.setPlainTextBody ('The batch Apex job processed ' + a.TotalJobItems +
                                    ' batches with '+ a.NumberOfErrors + ' failures.');
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });

        
    }
    
}
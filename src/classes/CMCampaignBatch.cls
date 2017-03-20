global class CMCampaignBatch implements Database.Batchable<SObject>, Database.AllowsCallouts {

    global Database.queryLocator start(Database.BatchableContext ctx){
    	return Database.getQueryLocator([SELECT Id, wbsendit__Campaign_ID__c FROM wbsendit__Campaign_Monitor_Campaign__c where Event_Processed__c = false ]);
    }
    
    global void execute(Database.BatchableContext ctx, List<Sobject> cmListViewObjects){
		try{
        List<wbsendit__Campaign_Monitor_Campaign__c> cmList = (List<wbsendit__Campaign_Monitor_Campaign__c>)cmListViewObjects;
	        if(cmList.size() > 0){
		        System.debug('--- cmList list count ---' + cmList.size());
				wbsendit.SendItClass.CampaignSegmentList csl;
				if(!Test.isRunningTest())
					csl = new wbsendit.SendItClass.CampaignSegmentList();			
		
				for(wbsendit__Campaign_Monitor_Campaign__c cm : cmList){
						if(!Test.isRunningTest())
				        	csl = wbsendit.SendItAPI.getCampaignLists(cm.wbsendit__Campaign_ID__c);
				}
		
				List<wbsendit.SendItClass.CampaignSegment> segList = new List<wbsendit.SendItClass.CampaignSegment>();
				if(!Test.isRunningTest())
					segList = csl.segments;
		
				List<Event_Registration__c> updERList = new List<Event_Registration__c>();
				
				for(wbsendit.SendItClass.CampaignSegment seg : segList){
					System.debug('--- listID ---' + seg.listID);
					System.debug('--- segmentID ---' + seg.segmentID);
					System.debug('--- title ---' + seg.title);
	
					List<Event__c> eList = [Select Id from Event__c where Campaign_Monitor_List_Id__c = :seg.listID];
		
					for(Event__c e : eList){
		System.debug('--- event id ---' + e.Id);
						CreateContactsInSegments.UpdateInvitedContactsInSegments(e.Id);
					}
	
					List<Event_Registration__c> erList = [Select Id, Status__c from Event_Registration__c 
															where Campaign_Monitor_List_Id__c = :seg.listID and Status__c = 'Planned'];
															
		
					for(Event_Registration__c el : erList){
						el.Status__c = 'Invited';
						updERList.add(el);
					}
					
				}		
		
				if(updERList.size() > 0){
					update updERList;
				}
		
		        List<wbsendit__Campaign_Monitor_Campaign__c> cmUpdList = new List<wbsendit__Campaign_Monitor_Campaign__c>();
		
				if(cmList.size() > 0){
					for(wbsendit__Campaign_Monitor_Campaign__c cmc : cmList){
						cmc.Event_Processed__c = true;
						cmUpdList.add(cmc);
					}
				}
				
				if(cmUpdList.size() > 0){
					update cmUpdList;
				}
	        }
		}
        catch(Exception e){
           String msg = 'Error occurred in CMCampaignBatch method: ' + e.getMessage();
           PDCRM_ErrorLog.CreateNewError(String.valueof(e.getLineNumber()),e.getMessage(),'CMCampaignBatch','execute','Campaign Batch Jon to Update Status to Invite','','');
        }
        finally{
           //Cleanup1
        }		
		
    }    
    global void finish(Database.BatchableContext ctx){
        AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed,
                          TotalJobItems, CreatedBy.Email
                          FROM AsyncApexJob WHERE Id =:ctx.getJobId()];

        // Send an email to the Apex job's submitter notifying of job completion.
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] {UserInfo.getUserEmail()};
//        String[] toAddresses = new String[] {'mallasn@america.gov'};
        mail.setToAddresses(toAddresses);
        mail.setSubject('Sync List details ' + a.Status);
        mail.setPlainTextBody ('The batch Apex job processed ' + a.TotalJobItems +
                                    ' batches with '+ a.NumberOfErrors + ' failures.');
                        
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }

}
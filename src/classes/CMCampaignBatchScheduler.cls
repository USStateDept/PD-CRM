global class CMCampaignBatchScheduler implements Schedulable{
	
	global void execute(SchedulableContext sc) {
		CMCampaignBatch b = new CMCampaignBatch(); 
		database.executebatch(b);
	}
    
}
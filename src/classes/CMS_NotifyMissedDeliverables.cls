global class CMS_NotifyMissedDeliverables implements Schedulable
{
	global void execute (SchedulableContext sc)
	{
		indentifyDeliverables();
	}
	
	
	global static void indentifyDeliverables()
	{
		Date todayObj = date.today();
		Date startDate = todayObj.toStartOfWeek();
    	Date endDate = startDate.addDays( 5 );
		
		for (CMS_Milestone_Task__c task : [SELECT Id, Name, Assigned_Users__c, Functional_Roles__c, Completed_Date__c, Due_Date__c, Start_Date__c, CMS_Milestone__r.CMS_Projects__r.name, CMS_Milestone__r.name, CMS_Milestone__r.CMS_Projects__r.Project_Number__c 
		                                     FROM CMS_Milestone_Task__c 
		                                    WHERE Due_Date__c >= :startDate 
		                                      AND Start_Date__c <= :endDate
		                                      AND (Percentage__c != 100 or Override_Percentage__c != 100)])
		{
			System.debug( task );
		}
	}
}
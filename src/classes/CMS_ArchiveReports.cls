global class CMS_ArchiveReports implements Schedulable
{
	global void execute (SchedulableContext sc)
	{
		archiveReports();
	}
	
	global static void archiveReports()
	{
		Date todayObj = date.today();
		Date startDate = todayObj.toStartOfWeek();
    	Date endDate = startDate.addDays( -13 );
		
		List<CMS_Weekly_Status_Report__c> reports = new List<CMS_Weekly_Status_Report__c>();
		
		for (CMS_Weekly_Status_Report__c report : [SELECT id, Status__c FROM CMS_Weekly_Status_Report__c WHERE Report_End_Date__c < :endDate AND Status__c = 'Submitted'])
		{
			report.Status__c = 'Archived';
			reports.add( report );
		}
		
		update reports;
	}
	
	
	public static testMethod void testCMS_ArchiveReports()
    {             
        Test.startTest();
        
        CMS_Weekly_Status_Report__c a = new CMS_Weekly_Status_Report__c();
    	
    	Date b = Date.newInstance( 2013, 1, 27 );
    	Date c = Date.newInstance( 2013, 2, 2 );
		a.Project_Manager__c = 'Ikjae Park';
		a.Report_Start_Date__c = b;
		a.Report_End_Date__c = c;
		a.Supervisor__c = 'Rhonda Urbanczyk';
		a.OwnerId = UserInfo.getUserId();
        
        insert a;
        
        CMS_ArchiveReports.archiveReports();
    }
}
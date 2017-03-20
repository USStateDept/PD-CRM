public with sharing class CMS_CustomReport
{
	public Map<String, String> reports = new Map<String, String>();
	public CMS_Weekly_Status_Report__c report{ get; set; }
	
	public CMS_CustomReport()
	{
		if (report == null)
		{
			report = new CMS_Weekly_Status_Report__c();
			
			Date todayObj = date.today();
	    	report.Report_Start_Date__c = todayObj.toStartOfWeek();
	    	report.Report_End_Date__c = report.Report_Start_Date__c.addDays( 6 );
		}
		
		Date startDate = report.Report_Start_Date__c;
	   	Date endDate = report.Report_End_Date__c;
		
		for (Project_Tasks__c task : [SELECT name, Comments__c, Child__r.owner.name
		       						    FROM Project_Tasks__c
		       						   WHERE Child__r.Report_Start_Date__c >= :startDate
		       						   	 AND Child__r.Report_End_Date__c <= :endDate])
		{
			if (task.Comments__c != null && task.Comments__c.length() > 0)
			{
				String newComment = task.Comments__c;
				newComment = newComment.replace( '\n', '' );
				newComment = newComment.replace( '\r', '' );
				
				if (reports.containsKey( task.name ))
	        	{
	        		reports.put( task.name, reports.get( task.name ) + '<br/>' + newComment );
	        	}
	        	else
	        	{
	        		reports.put( task.name, newComment + '<br/>' );
	        	}
			}
		}
	}
	
	public PageReference refresh()
	{
		return null;
	}	
	
	
	public List<CustomReport> getReports()
	{
		Date startDate = report.Report_Start_Date__c;
	   	Date endDate = report.Report_End_Date__c;
		
		String soqlStr = '';
		soqlStr += 'SELECT name, Functional_Roles__c, Project_Numbers__c, max(Completed_Date__c) completedDate, SUM(Hours__c) hours, Min(Start_Date__c) startDate, max(Due_Date__c) dueDate, AVG(Percentage_Complete__c) percentage ';
		soqlStr += 'FROM Project_Tasks__c '; 
		soqlStr += 'WHERE Hours__c != null ';
		soqlStr += 'AND O_M__c = false ';
		soqlStr += 'AND Child__r.Report_Start_Date__c >= :startDate ';
		soqlStr += 'AND Child__r.Report_End_Date__c <= :endDate ';
		soqlStr +=  'GROUP BY name, Functional_Roles__c, Project_Numbers__c';
		
		List<CustomReport> listOfTasks = new List<CustomReport>();
		
		for (AggregateResult aggregatedData : Database.query( soqlStr ))
        {
        	Decimal hours = (Decimal) aggregatedData.get( 'hours' );
        	
        	if (hours > 0)
        	{
	        	CustomReport myTask = new CustomReport();
	        	myTask.name = (String) aggregatedData.get( 'name' );
	        	myTask.totalHours = hours;
	        	myTask.completeDate = (Date) aggregatedData.get( 'completedDate' );
	        	myTask.startDate = (Date) aggregatedData.get( 'startDate' );
	        	myTask.dueDate = (Date) aggregatedData.get( 'dueDate' );
	        	myTask.percentage = Integer.valueOf( (Decimal) aggregatedData.get( 'percentage' ));
	        	myTask.projectNumber = (String) aggregatedData.get( 'Project_Numbers__c' );
	        	myTask.functionalRole = (String) aggregatedData.get( 'Functional_Roles__c' );
	        	myTask.comments = reports.get( myTask.name );
	        	
	        	listOfTasks.add( myTask );
        	}
        }
        
		return listOfTasks;
	}
	
	
	public List<CustomReport> getReportsOM()
	{
    	Date startDate = report.Report_Start_Date__c;
	   	Date endDate = report.Report_End_Date__c;
		
		String soqlStr = '';
		soqlStr += 'SELECT name, Project_Numbers__c, Min(Start_Date__c) startDate, SUM(Hours__c) hours,  max(Due_Date__c) dueDate, AVG(Percentage_Complete__c) percentage ';
		soqlStr += 'FROM Project_Tasks__c '; 
		soqlStr += 'WHERE Hours__c != null ';
		soqlStr += 'AND O_M__c = true ';
		soqlStr += 'AND Child__r.Report_Start_Date__c >= :startDate ';
		soqlStr += 'AND Child__r.Report_End_Date__c <= :endDate ';
		soqlStr +=  'GROUP BY name, Functional_Roles__c, Project_Numbers__c';
		
		List<CustomReport> listOfTasks = new List<CustomReport>();
		
		for (AggregateResult aggregatedData : Database.query( soqlStr ))
        {
        	Decimal hours = (Decimal) aggregatedData.get( 'hours' );
        	
        	if (hours > 0)
        	{
	        	CustomReport myTask = new CustomReport();
	        	myTask.name = (String) aggregatedData.get( 'name' );
	        	myTask.totalHours = hours;
	        	myTask.startDate = (Date) aggregatedData.get( 'startDate' );
	        	myTask.dueDate = (Date) aggregatedData.get( 'dueDate' );
	        	myTask.projectNumber = (String) aggregatedData.get( 'Project_Numbers__c' );
	        	myTask.percentage = Integer.valueOf( (Decimal) aggregatedData.get( 'percentage' ));
	        	myTask.comments = reports.get( myTask.name );
	        	
	        	listOfTasks.add( myTask );
        	}
        }
        
		return listOfTasks;
	}
	
	
	public List<CustomReport> getReportsOncomingLeave()
	{
		Date startDate = report.Report_Start_Date__c;
	   	Date endDate = report.Report_End_Date__c;

		List<CustomReport> listOfTasks = new List<CustomReport>();
		
		for (Upcoming_Leave__c leave : [SELECT Child__r.owner.name, Start_Date__c, End_Date__c 
										  FROM Upcoming_Leave__c
										 WHERE Start_Date__c <= :endDate
										   AND End_Date__c >= :startDate])
        {
        	CustomReport myTask = new CustomReport();
        	myTask.name = leave.Child__r.owner.name;
        	myTask.startDate = leave.Start_Date__c;
        	myTask.dueDate = leave.End_Date__c;
	        listOfTasks.add( myTask );
        }
        
		return listOfTasks;
	}
	
	
	public List<CustomReport> getFutureTaskList()
    {
    	List<CustomReport> listOfTasks = new List<CustomReport>();
    	
		Date futureStartDate = report.Report_End_Date__c;
		Date futureEndDate = report.Report_End_Date__c.addDays( 14 );
		
    	for (CMS_Milestone_Task__c task : [SELECT Id, Name, Assigned_Users__c, Completed_Date__c, Due_Date__c, Start_Date__c, CMS_Milestone__r.CMS_Projects__r.name, CMS_Milestone__r.name 
    	                                     FROM CMS_Milestone_Task__c
    	                                    WHERE Due_Date__c >= :futureStartDate
    	                                      AND Due_Date__c <= :futureEndDate])
    	{
    		CustomReport myTask = new CustomReport();
        	myTask.name = task.Name;
        	myTask.dueDate = task.Due_Date__c;
        	myTask.projectNumber = task.CMS_Milestone__r.CMS_Projects__r.name;
        	listOfTasks.add( myTask );
    	}
        
        return listOfTasks;
    }
	
	
	
	public class CustomReport
	{
		public String name{ set; get; }
		public String functionalRole{ set; get; }
		public String projectNumber{ set; get; }
		public Date completeDate{ set; get; }
		public Date startDate{ set; get; }
		public Date dueDate{ set; get; }
		public Decimal totalHours{ set; get; }
		public String comments{ set; get; }
		public Integer percentage{ get; set; }
	}
	
	
	public static testMethod void testCMS_CustomReport()
    {
    	Test.startTest();
    	
    	ApexPages.currentPage().getParameters().put( 'projectName', 'SF:test' );
    	User u3 = [SELECT Id FROM User WHERE name like 'Integrator Functional%' LIMIT 1];
        CMS_CustomReport rc = new CMS_CustomReport();
        
        CMS_Weekly_Status_Report__c b = new CMS_Weekly_Status_Report__c();        
        Date todayObj = date.today();
        Date startDate = todayObj.toStartOfWeek();
        Date endDate = startDate.addDays( 6 );
        b.Project_Manager__c = 'Ikjae Park';
        b.Report_Start_Date__c = startDate;
        b.Report_End_Date__c = endDate;
        b.Supervisor__c = 'Rhonda Urbanczyk';
        b.OwnerId = UserInfo.getUserId();
        insert b;
        
        Project_Tasks__c testTaskRecord = new Project_Tasks__c();
        testTaskRecord.Name = 'Create test';
        testTaskRecord.Project_Numbers__c = 'SF:test';
        testTaskRecord.Active__c = true;
        testTaskRecord.Functional_Roles__c = 'test';
        testTaskRecord.Hours__c = 3;
        testTaskRecord.Child__c = b.id;
        testTaskRecord.Percentage_Complete__c = 100;
        insert testTaskRecord;

        CMS_Weekly_Status_Report__c b2 = new CMS_Weekly_Status_Report__c();        
        b2.Project_Manager__c = 'Ikjae Park';
        b2.Report_Start_Date__c = startDate;
        b2.Report_End_Date__c = endDate;
        b2.Supervisor__c = 'Rhonda Urbanczyk';
        b2.OwnerId = UserInfo.getUserId();
        insert b2;
        
        
        Project_Tasks__c testTaskRecord2 = new Project_Tasks__c();
        testTaskRecord2.Name = 'Create test';
        testTaskRecord2.Project_Numbers__c = 'OM:test';
        testTaskRecord2.Active__c = true;
        testTaskRecord2.Functional_Roles__c = 'test';
        testTaskRecord2.Hours__c = 3;
        testTaskRecord2.Child__c = b.id;
        insert testTaskRecord2;
        
        System.RunAs( u3 )
    	{
    		rc.getReports();
    		rc.getReportsOM();
    	}
    }
}
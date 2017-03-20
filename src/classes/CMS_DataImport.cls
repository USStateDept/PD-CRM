public with sharing class CMS_DataImport
{
	private Document weeklyReport;
    private Document user;
    private Document ongoingTasks;
    private Document projectTasks;
    private Document upcomingTasks;
    private Document upcomingLeaveTasks;
    private Document miscTasks;
        
    public CMS_DataImport()
    {
        weeklyReport = [SELECT Body, Description FROM Document WHERE name = 'Weekly Report' ];
        user = [SELECT Body, Description FROM Document WHERE name = 'Users' ];
        ongoingTasks = [SELECT Body, Description FROM Document WHERE name = 'Ongoing Tasks' ];
        projectTasks = [SELECT Body, Description FROM Document WHERE name = 'Project Tasks' ];
        upcomingTasks = [SELECT Body, Description FROM Document WHERE name = 'Upcoming Tasks' ];
        upcomingLeaveTasks = [SELECT Body, Description FROM Document WHERE name = 'Upcoming Leave Tasks' ];
        miscTasks = [SELECT Body, Description FROM Document WHERE name = 'Misc Tasks' ];
    }
    
    public void processDataRestoreForWeeklyReport()
    {
        String[] linesForReports = weeklyReport.Body.toString().split('\n', -1);
        String[] linesForUsers = user.Body.toString().split('\n', -1);
        
        
        Map<String, String> oldMappingID = new Map<String, String>();
        Map<String, String> oldMappingName = new Map<String, String>();
        
        for (Integer i = 1; i < linesForUsers.size() - 1; i++)
        {
        	String[] inputs = linesForUsers[i].split(',', -1);
        	
        	String isActive = inputs[3].replaceAll( '"', '' );
        	String name =  inputs[2] + ' ' + inputs[1];
        	name = name.replaceAll( '"', '' );
        	String id = inputs[0].replaceAll( '"', '' );
        	if (isActive == 'true')
        	{
	        	oldMappingID.put( id, name );
	        	oldMappingName.put( name, id );
        	}
        }

		List<String> userNames = oldMappingID.values();
		
        for(User u : [SELECT id, name, isActive FROM user where name in :userNames])
        {
			String oldID = oldMappingName.get( u.name );
			oldMappingID.put( oldID, u.id );
			
			if (!u.IsActive)
			{
				oldMappingID.remove( oldID );
			}
        }
        
        List<CMS_Weekly_Status_Report__c> reports = new List<CMS_Weekly_Status_Report__c>();
        
		List<String> cantProcess = new List<String>();
        
        for (Integer i = 1; i < linesForReports.size() - 1; i++)
        {
        	String[] inputs = linesForReports[i].split(',', -1);
        	
        	String migrateID = inputs[0].replaceAll( '"', '' );
        	String ownerID = inputs[1].replaceAll( '"', '' );
        	String projectManager = inputs[10];
        	String supervisor = inputs[11];
        	String reportStartDate = inputs[12];
        	String reportEndDate = inputs[13];
        	String contractNumber = inputs[14];
        	String status = inputs[16];

        	if (oldMappingID.containsKey( ownerID ))
        	{
        		try
        		{
        			CMS_Weekly_Status_Report__c report = new CMS_Weekly_Status_Report__c();
		        	report.Contract_ID__c = contractNumber;
		        	report.OwnerId = oldMappingID.get( ownerID );
		        	report.Project_Manager__c = projectManager;
		        	report.Supervisor__c = supervisor;
		        	report.Report_Start_Date__c = date.parse(reportStartDate);
		        	report.Report_End_Date__c = date.parse(reportEndDate);
		        	report.Status__c = status;
		        	report.Migrated_ID__c = migrateID;
		        	reports.add( report );
        		}
        		catch (Exception e)
        		{
        			cantProcess.add( ownerID );
        		}
	        	
        	}
        	else
        	{
        		cantProcess.add( ownerID );
        	}
        }
        
        system.debug( 'Failed records: ' );
        for (String id : cantProcess)
        {
        	system.debug( id );
        }
    	
    	insert( reports );
    }
    
    
    public void processOngoingTasks()
    {
    	String[] lines = ongoingTasks.Body.toString().split('\n', -1);
    	
    	List<Ongoing_Tasks__c> taks = new List<Ongoing_Tasks__c>();
    	System.debug( lines.size()  + ' ' +  ongoingTasks.id );
    	for (Integer i = Integer.valueof( ongoingTasks.Description ); i < lines.size() - 1; i++)
        {
        	String[] inputs = lines[i].split(',', -1);
        	System.debug( 'Line Number- ' + i );
        	String id = inputs[0];
        	String name = inputs[2];
        	String reportID = inputs[9];
        	String functionalRole = inputs[10];
        	String comments = inputs[11];
        	String hours = inputs[12];
        	
        	CMS_Weekly_Status_Report__c myReport;
        	
        	try
        	{
	        	myReport = [SELECT id FROM CMS_Weekly_Status_Report__c WHERE Migrated_ID__c = :reportID];
			}
        	catch (Exception e)
        	{

        	}
        	
        	if (myReport != null)
        	{
	        	Ongoing_Tasks__c task = new Ongoing_Tasks__c();
	        	task.name = replaceComma( name );
	        	task.Child__c = myReport.id;
	        	if (comments.length() > 255 )
	        	{
	        		task.Comments__c = comments.SubString(0,254);
	        	}
	        	else
	        	{
	        		task.Comments__c = comments;
	        	}
				task.Functional_Roles__c = functionalRole;
				
				if (hours.length() > 0)
				{
					task.Hours__c = Decimal.valueOf( hours );
				}
				taks.add( task );
        	}
        	
        	if (i == Integer.valueof( ongoingTasks.Description ) + 90)
            {
                ongoingTasks.Description = String.valueOf( i + 1 );
                break;
            }
            else if (i == lines.size() - 2)
            {
                
                ongoingTasks.Description = String.valueOf( i + 1 );
                break;
            }
        }
        
        insert( taks );
        update ongoingTasks;
    }
    
    
    public void processKeyTasks()
    {
    	String[] lines = upcomingTasks.Body.toString().split('\n', -1);
    	
    	List<Key_Task_Planned_for_Next_Period2__c> taks = new List<Key_Task_Planned_for_Next_Period2__c>();
    	
    	for (Integer i = Integer.valueof( upcomingTasks.Description ); i < lines.size() - 1; i++)
        {
        	String[] inputs = lines[i].split(',', -1);
        	System.debug( i );
        	String id = inputs[0];
        	String name = inputs[2];
        	String reportID = inputs[9];
        	String functionalRole = inputs[11];
        	String projectNumber = inputs[12];
        	String dueDate = inputs[13];
        	String comments = inputs[14];

        	CMS_Weekly_Status_Report__c myReport;
        	
        	try
        	{
	        	myReport = [SELECT id FROM CMS_Weekly_Status_Report__c WHERE Migrated_ID__c = :reportID];
			}
        	catch (Exception e)
        	{

        	}
        	
        	if (myReport != null)
        	{
	        	Key_Task_Planned_for_Next_Period2__c task = new Key_Task_Planned_for_Next_Period2__c();
	        	task.name = name;
	        	task.Child__c = myReport.id;
	        	task.Comments__c = comments;
	        	if (dueDate.length() > 0)
	        	{
	        		task.Due_Date__c = date.parse( dueDate );
	        	}
				task.Functional_Roles__c = functionalRole;
				task.Project_Numbers__c = projectNumber;
				taks.add( task );
        	}
        	
        	
        	if (i == Integer.valueof( upcomingTasks.Description ) + 90)
            {
                upcomingTasks.Description = String.valueOf( i + 1 );
                break;
            }
            else if (i == lines.size() - 2)
            {
                upcomingTasks.Description = String.valueOf( i + 1 );
                break;
            }
        }
        
        insert( taks );
        update upcomingTasks;
    }
    
    
    public void processProjectTasks()
    {
    	String[] lines = projectTasks.Body.toString().split('\n', -1);
    	
    	List<Project_Tasks__c> taks = new List<Project_Tasks__c>();
    	
    	for (Integer i = Integer.valueof( projectTasks.Description ); i < lines.size() - 1; i++)
        {
        	String[] inputs = lines[i].split(',', -1);
        	System.debug( i );
        	String id = inputs[0].replaceAll( '"', '' );
        	String name = inputs[2].replaceAll( '"', '' );
        	String projectNumber = inputs[9].replaceAll( '"', '' );
        	String startDate = inputs[10].replaceAll( '"', '' );
        	String dueDate = inputs[11].replaceAll( '"', '' );
        	String percentage = inputs[12].replaceAll( '"', '' );
        	String hours = inputs[13].replaceAll( '"', '' );
        	String reportID = inputs[14].replaceAll( '"', '' );
        	
        	CMS_Weekly_Status_Report__c myReport;
			try
			{
	        	myReport = [SELECT id FROM CMS_Weekly_Status_Report__c WHERE Migrated_ID__c = :reportID];
			}
			catch (Exception e)
			{
				
			}
			
			if (myReport != null)
			{
	        	Project_Tasks__c task = new Project_Tasks__c();
	        	task.name = name;
	        	task.Child__c = myReport.id;
	        	
	        	if (startDate.length() > 0)
	        	{
	        		task.Start_Date__c = Date.parse( startDate );
	        	}
	        	
	        	if (dueDate.length() > 0)
	        	{
	        		task.Due_Date__c = Date.parse( dueDate );
	        	}
	        	
	        	if (percentage.length() > 0)
	        	{
	        		task.Percentage_Complete__c = Decimal.valueOf( percentage ); 
	        	}
	        	
	        	if (hours.length() > 0)
	        	{
	        		task.Hours__c = Decimal.valueOf( hours );
	        	}
	        	task.Project_Numbers__c = projectNumber;
				taks.add( task );
			}
        	
        	if (i == Integer.valueof( projectTasks.Description ) + 90)
            {
                projectTasks.Description = String.valueOf( i + 1 );
                break;
            }
            else if (i == lines.size() - 2)
            {
                projectTasks.Description = String.valueOf( i + 1 );
                break;
            }
        }
        
        insert( taks );
        update projectTasks;
    }
    
        
    public void processUpcomingLeaveTask()
    {
    	String[] lines = upcomingLeaveTasks.Body.toString().split('\n', -1);
    	
    	List<Upcoming_Leave__c> taks = new List<Upcoming_Leave__c>();
    	
    	for (Integer i = Integer.valueof( upcomingLeaveTasks.Description ); i < lines.size() - 1; i++)
        {
        	String[] inputs = lines[i].split(',', -1);
        	
        	String id = inputs[0];
        	String name = inputs[2];
        	String reportID = inputs[9];
        	String startDate = inputs[10];
        	String endDate = inputs[11];
        	String leaveType = inputs[13];
        	
        	CMS_Weekly_Status_Report__c myReport;
        	
        	try
        	{
	        	myReport = [SELECT id FROM CMS_Weekly_Status_Report__c WHERE Migrated_ID__c = :reportID];
			}
        	catch (Exception e)
        	{

        	}
        	
        	if (myReport != null)
        	{
	        	Upcoming_Leave__c task = new Upcoming_Leave__c();
	        	task.Child__c = myReport.id;
	        	
	        	if (startDate.length() > 0)
	        	{
	        		task.Start_Date__c = date.parse( startDate );
	        	}
	        	
	        	if (endDate.length() > 0)
	        	{
	        		task.End_Date__c = date.parse( endDate );
	        	}
				taks.add( task );
        	}
        	
        	if (i == Integer.valueof( upcomingLeaveTasks.Description ) + 90)
            {
                upcomingLeaveTasks.Description = String.valueOf( i + 1 );
                break;
            }
            else if (i == lines.size() - 2)
            {
                
                upcomingLeaveTasks.Description = String.valueOf( i + 1 );
                break;
            }
        }
        
        insert( taks );
        update upcomingLeaveTasks;
    }
    
    
    public void processMiscTasks()
    {
    	String[] lines = miscTasks.Body.toString().split('\n', -1);
    	
    	List<Miscellaneous_Tasks__c> tasks = new List<Miscellaneous_Tasks__c>();
    	
    	for (Integer i = Integer.valueof( miscTasks.Description ); i < lines.size() - 1; i++)
        {
        	String[] inputs = lines[i].split(',', -1);
        	System.debug( i );
        	String id = inputs[0];
        	String name = inputs[2];
        	String reportID = inputs[9];
        	String functionalRole = inputs[10];
        	String status = inputs[11];
        	String hours = inputs[12];
        	String completeDate = inputs[13];
        	String comments = inputs[14];
        	String dueDate = inputs[15];

        	CMS_Weekly_Status_Report__c myReport;
			try
			{
	        	myReport = [SELECT id FROM CMS_Weekly_Status_Report__c WHERE Migrated_ID__c = :reportID];
			}
			catch (Exception e)
			{
				
			}
			
			if (myReport != null)
			{
	        	Miscellaneous_Tasks__c task = new Miscellaneous_Tasks__c();
	        	task.name = name;
	        	task.Child__c = myReport.id;
	        	
	        	if (completeDate.length() > 0)
	        	{
	        		task.Complete_Date__c = Date.parse( completeDate );
	        	}
	        	
	        	if (dueDate.length() > 0)
	        	{
	        		task.Due_Date__c = Date.parse( dueDate );
	        	}
	        	
	        	if (hours.length() > 0)
	        	{
	        		task.Hours__c = Decimal.valueOf( hours ); 
	        	}

	        	task.Functional_Roles__c = functionalRole;
	        	task.status__c = status;
	        	task.Comments__c = comments;
				tasks.add( task );
			}
        	
        	if (i == Integer.valueof( miscTasks.Description ) + 90)
            {
                miscTasks.Description = String.valueOf( i + 1 );
                break;
            }
            else if (i == lines.size() - 2)
            {
                miscTasks.Description = String.valueOf( i + 1 );
                break;
            }
        }
        
        insert( tasks );
        update miscTasks;
    }
    
    
    public String replaceComma( String str )
    {
        return str.replaceAll( 'COMMA', ',' ).trim(); 
    }
    
    
    public static testMethod void testCMS_DataImport()
    {
    	Blob user = Blob.valueOf( '"00530000005Bh4JAAS","Park","Ikjae","true"\n"00530000005Bh4JAAS","Park","Ikjae","true"\n"00530000005Bh4JAAS","Park","Ikjae","false"' );
    	Blob report = Blob.valueOf( 'test\na0jV0000001itNzIAI,00530000005Bh4JAAS,FALSE,A-00000249,2012-10-08T21:49:38.000Z,005V0000000nYGvIAM,2012-10-12T22:05:37.000Z,005V0000000nYGvIAM,2012-10-12T22:05:37.000Z,10/8/12,Peter Jarrell,Rhonda Urbanczyk,10/07/2012,10/13/2012,SAQMMA12C0082,"<a href=""https://cs12.salesforce.com/a0jV0000001itNz"" target=""_top"">10/7/2012</a>",Archived\na0jV0000001itNzIAI,00530000005Bh4JAAS,FALSE,A-00000249,2012-10-08T21:49:38.000Z,005V0000000nYGvIAM,2012-10-12T22:05:37.000Z,005V0000000nYGvIAM,2012-10-12T22:05:37.000Z,10/8/12,Peter Jarrell,Rhonda Urbanczyk,10/07/2012,10/13/2012,SAQMMA12C0082,"<a href=""https://cs12.salesforce.com/a0jV0000001itNz"" target=""_top"">10/7/2012</a>",Archived' );
    	Blob ongoingTask = Blob.valueOf( 'test\na0XV0000000A1SKMA0,FALSE,Complete the POA&M action for the CMS annual assessment,2012-10-05T16:39:39.000Z,00530000004j86oAAA,2012-10-05T16:39:39.000Z,00530000004j86oAAA,2012-10-05T16:39:39.000Z,,a0jV0000001itNzIAI,Security,"AfterI learned how to use the new State Dept POA&M tracking tool to document.",7\nna0XV0000000A1SKMA0,FALSE,Complete the POA&M action for the CMS annual assessment,2012-10-05T16:39:39.000Z,00530000004j86oAAA,2012-10-05T16:39:39.000Z,00530000004j86oAAA,2012-10-05T16:39:39.000Z,,a0jV0000001itNzIAI,Security,"After submitting the CMS annual assessment Control Selection Tool including test resultsCOMMA the single ""failed"" control dealt with multi-factor authentication f  I learned how to u,7' );
    	Blob projectTask = Blob.valueOf( 'test\na0RV000000070W0MAI,FALSE,Enhancement Webinar,2012-10-10T12:39:22.000Z,00530000004hRLPAA2,2012-10-10T19:13:40.000Z,00530000004hRLPAA2,2012-10-10T19:13:40.000Z,,EMB:WG:ENH - SP2012,2012-10-10,10/10/2012,100,2,a0jV0000001itNzIAI,"AM Session: 17 Attendees PM Session:"' );
    	Blob upcomingLeaveTask = Blob.valueOf( 'test\na0lV0000000InIZIA0,FALSE,Leave,2012-10-10T19:56:36.000Z,00530000004hRLPAA2,2012-10-10T19:56:36.000Z,00530000004hRLPAA2,2012-10-10T19:56:36.000Z,,a0jV0000001itNzIAI,10/19/2012,10/19/2012,,Personal\na0lV0000000InIZIA0,FALSE,Leave,2012-10-10T19:56:36.000Z,00530000004hRLPAA2,2012-10-10T19:56:36.000Z,00530000004hRLPAA2,2012-10-10T19:56:36.000Z,,a0jV0000001itNzIAI,10/19/2012,10/19/2012,,Personal' );
    	Blob keyTask = Blob.valueOf( 'test\na0QV0000004zTReMAM,FALSE,CMS POAM action item,2012-10-05T16:42:34.000Z,00530000004j86oAAA,2012-10-05T16:42:34.000Z,00530000004j86oAAA,2012-10-05T16:42:34.000Z,,a0jV0000001itNzIAI,,Security,SF:CA,10/10/2012,Interview the CMS subsystem custodians to clarify the feasibility of establishing 2-factor authentication on CMS administrator user accounts.\na0QV0000004zTReMAM,FALSE,CMS POAM action item,2012-10-05T16:42:34.000Z,00530000004j86oAAA,2012-10-05T16:42:34.000Z,00530000004j86oAAA,2012-10-05T16:42:34.000Z,,a0jV0000001itNzIAI,,Security,SF:CA,10/10/2012,Interview the CMS subsystem custodians to clarify the feasibility of establishing 2-factor authentication on CMS administrator user accounts.' );
    	Blob miscTask = Blob.valueOf( 'test\na0SV0000000jvdXMAQ,FALSE,Salesforce Environment Setup,2012-10-10T13:25:05.000Z,005V0000000lNtEIAU,2012-10-10T15:44:09.000Z,005V0000000lNtEIAU,2012-10-10T15:44:09.000Z,,a0jV0000001itNzIAI,System Administration,In Progress,12,,Working with others to brainstorm. Working with Ikjae to create test and destroy new Development Sandboxes.,10/12/2012\na0SV0000000jvdXMAQ,FALSE,Salesforce Environment Setup,2012-10-10T13:25:05.000Z,005V0000000lNtEIAU,2012-10-10T15:44:09.000Z,005V0000000lNtEIAU,2012-10-10T15:44:09.000Z,,a0jV0000001itNzIAI,System Administration,In Progress,12,,Working with others to brainstorm. Working with Ikjae to create test and destroy new Development Sandboxes.,10/12/2012' );
    	
    	Folder newFolder = [Select Id From Folder WHERE name = 'Shared Documents' limit 1];
    	Document newDoc1 = new Document( name='Weekly Report', description='1', body=report, folderId=newFolder.id );
    	insert newDoc1;
    	
    	Document newDoc2 = new Document( name='Users', description='1', body=user, folderId=newFolder.id );
    	insert newDoc2;
    	
    	Document newDoc3 = new Document( name='Ongoing Tasks', description='1', body=ongoingTask, folderId=newFolder.id );
    	insert newDoc3;
    	
    	Document newDoc4 = new Document( name='Project Tasks', description='1', body=projectTask, folderId=newFolder.id );
    	insert newDoc4;
    	
    	Document newDoc5 = new Document( name='Upcoming Tasks', description='1', body=keyTask, folderId=newFolder.id );
    	insert newDoc5;
    	
    	Document newDoc6 = new Document( name='Upcoming Leave Tasks', description='1', body=upcomingLeaveTask, folderId=newFolder.id );
    	insert newDoc6;
    	
    	Document newDoc7 = new Document( name='Misc Tasks', description='1', body=miscTask, folderId=newFolder.id );
    	insert newDoc7;
    	
    	
    	CMS_DataImport a = new CMS_DataImport();
    	a.processDataRestoreForWeeklyReport();
		a.processOngoingTasks(); //WORKS
		a.processUpcomingLeaveTask(); //WORKS
		a.processProjectTasks(); //WORKS
		a.processKeyTasks(); //WORKS
		a.processMiscTasks();
    }
    
}
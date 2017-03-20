global class CMS_CreateReportForUsers implements Schedulable
{
	global void execute (SchedulableContext sc)
	{
		createReport();
	}
	
	
	global static void createReport()
	{
		Date todayObj = date.today();
		Date startDate = todayObj.toStartOfWeek();
    	Date endDate = startDate.addDays( 6 );
		
		Map<String, Id> listOfUsers = getPermissionsetUsers( 'CMS_Weekly_Status_Report__c' );
		System.debug(listOfUsers );
        
        //Stephanie (3/19/15) - Need to retrieve only active users.  This fixes the exception 'INACTIVE_OWNER_OR_USER'
        if(listOfUsers != null && !listOfUsers.isEmpty()) {
      		List<String> usersList = listOfUsers.values();
            
            //Query active users only and put them back to the users map
            List<User> activeUsers = [SELECT id, name, isActive FROM User WHERE id in :usersList AND isActive = true];
            if(activeUsers != null) {
                //Reset listOfUsers map
                listOfUsers = new Map<String, Id>();
                for(User user : activeUsers) {
                    listOfUsers.put(user.Name,user.Id);
                }
            }
        }

        Map<Id, List<Project_Tasks__c>> userTasks = new Map<Id, List<Project_Tasks__c>>(); 
		
		for (CMS_Milestone_Task__c task : [SELECT Id, Name, Assigned_Users__c, Functional_Roles__c, Completed_Date__c, Due_Date__c, Start_Date__c, CMS_Milestone__r.CMS_Projects__r.name, CMS_Milestone__r.name, CMS_Milestone__r.CMS_Projects__r.Project_Number__c 
		                                     FROM CMS_Milestone_Task__c 
		                                    WHERE Due_Date__c >= :startDate 
		                                      AND Start_Date__c <= :endDate
		                                      AND Percentage__c != 100])
		{
			String[] users = task.Assigned_Users__c.split( ',' );

			for (String user : users)
			{
				if (listOfUsers.containsKey( user ))
				{
					Project_Tasks__c newTask = new Project_Tasks__c();
					newTask.Name = task.Name;
					newTask.Due_Date__c = task.Due_Date__c;
					newTask.Start_Date__c = task.Start_Date__c;
					newTask.Active__c = true;
					
					if (task.CMS_Milestone__r.CMS_Projects__r.Project_Number__c.startsWith( 'OM' ))
					{
						newTask.O_M__c = true;	
					}
					
				    newTask.Project_Numbers__c = task.CMS_Milestone__r.CMS_Projects__r.name;
					newTask.Functional_Roles__c = task.Functional_Roles__c;
			
					if (!userTasks.containsKey( listOfUsers.get( user ) ))
					{
						userTasks.put( listOfUsers.get( user ), new List<Project_Tasks__c>());
					}
					
					userTasks.get( listOfUsers.get( user ) ).add( newTask );
				}
			}
		}
/*		
		// Each projects...
    	for (CMS_Projects__c project : [SELECT Name, Due_Date__c, Start_Date__c, Project_Lead__r.name
    	 								  FROM CMS_Projects__c
    	 								 WHERE Due_Date__c >= :startDate 
		                                   AND Start_Date__c <= :endDate])
    	{
    		if (listOfUsers.containsKey( project.Project_Lead__r.name ))
			{
				Project_Tasks__c newTask = new Project_Tasks__c();
				
				if (project.Project_Number__c.startsWith( 'OM' ))
				{
					newTask.O_M__c = true;	
				}
				
				newTask.Name = 'Project Maintainance - ' + project.Name;
				newTask.Due_Date__c = Project.Due_Date__c;
				newTask.Start_Date__c = Project.Start_Date__c;
				newTask.Active__c = true;
			    newTask.Project_Numbers__c = project.name;
				newTask.Functional_Roles__c = 'Management';
		
				if (!userTasks.containsKey( listOfUsers.get( project.Project_Lead__r.name ) ))
				{
					userTasks.put( listOfUsers.get( project.Project_Lead__r.name ), new List<Project_Tasks__c>());
				}
				
				userTasks.get( listOfUsers.get( project.Project_Lead__r.name ) ).add( newTask );
			}
    	}
    	
    	
    	// Each milestones...
    	for (CMS_Milestone__c milestone : [SELECT Name, Due_Date__c, Start_Date__c, CMS_Projects__r.name, Lead__r.name
    	 								     FROM CMS_Milestone__c
    	 								    WHERE Due_Date__c >= :startDate 
		                                      AND Start_Date__c <= :endDate])
    	{
    		if (listOfUsers.containsKey( milestone.Lead__r.name ))
			{
				Project_Tasks__c newTask = new Project_Tasks__c();
				newTask.Name = milestone.Name;
				newTask.Due_Date__c = milestone.Due_Date__c;
				newTask.Start_Date__c = milestone.Start_Date__c;
				newTask.Active__c = true;
				
				if (milestone.CMS_Projects__r.name.startsWith( 'OM' ))
				{
					newTask.O_M__c = true;	
				}
				
			    newTask.Project_Numbers__c = milestone.CMS_Projects__r.name;
				newTask.Functional_Roles__c = 'Management';
		
				if (!userTasks.containsKey( listOfUsers.get( milestone.Lead__r.name ) ))
				{
					userTasks.put( listOfUsers.get( milestone.Lead__r.name ), new List<Project_Tasks__c>());
				}
				
				userTasks.get( listOfUsers.get( milestone.Lead__r.name ) ).add( newTask );
			}
    	}
*/		
		
		List<CMS_Weekly_Status_Report__c> newReports = new List<CMS_Weekly_Status_Report__c>();
		
		for (String user : listOfUsers.values())
		{
			CMS_Weekly_Status_Report__c previousReport = getPreviousReport( user );

			CMS_Weekly_Status_Report__c cmsReport = new CMS_Weekly_Status_Report__c();
			cmsReport.Report_Start_Date__c = startDate; 
			cmsReport.Report_End_Date__c = endDate;
			cmsReport.Status__c = 'Open';
			cmsReport.OwnerId = user;

			if (previousReport != null)
			{
				cmsReport.Supervisor__c = previousReport.Supervisor__c;
				cmsReport.Project_Manager__c = previousReport.Project_Manager__c;
			}

			newReports.add( cmsReport );
		}

		insert newReports;
		
		List<Project_Tasks__c> newTasks = new List<Project_Tasks__c>();
		
		for (CMS_Weekly_Status_Report__c report : newReports)
		{
			System.debug( report.OwnerId + '   ' + JSON.serialize( report ));
			
			if (userTasks.containsKey( report.OwnerId ))
			{
				for (Project_Tasks__c task : userTasks.get( report.OwnerId ))
				{
					task.Child__c = report.id;
					newTasks.add( task );
				}
			}
		}
		
		insert newTasks;
	}
	
	public static Map<String, ID> getPermissionsetUsers( String objectName )
    {
        Map<String, ID> users = new Map<String, Id>();
        
        for (PermissionSetAssignment psa : [SELECT AssigneeId, Assignee.Name
                                              FROM PermissionSetAssignment
                                             WHERE PermissionSet.IsOwnedByProfile = FALSE
                                               AND PermissionSetId
                                                IN (SELECT ParentId FROM ObjectPermissions WHERE SObjectType = :objectName)])
        {
        	users.put( psa.Assignee.Name, psa.AssigneeId );
        }
        
        return users;
    }
	
	
	global static CMS_Weekly_Status_Report__c getPreviousReport( Id userId )
	{
		CMS_Weekly_Status_Report__c previousStatus;
		
		try
		{
			previousStatus = [SELECT Supervisor__c, Project_Manager__c  FROM CMS_Weekly_Status_Report__c WHERE ownerId = :userId ORDER BY id desc LIMIT 1];
		}
		catch (Exception e)
		{
			previousStatus = null;
		}
		
		return previousStatus;
	}

	
	public static testMethod void testCMS_CreateReportForUsers()
    {
        Test.startTest();
        
    	// Testing Project Manager
    	User u3 = [SELECT Id, Name FROM User WHERE name like 'Integrator Functional%' LIMIT 1];
    	PermissionSet ps = [SELECT ID From PermissionSet WHERE Label = 'CMS Project Manager'];
    	
        PermissionSetAssignment PSAssignment;
        List<PermissionSetAssignment> psaList = [SELECT Id,PermissionSetId FROM PermissionSetAssignment WHERE PermissionSetId = :ps.ID AND AssigneeId = :u3.id];
        if(psaList != null && psaList.size() > 0)
        {
        	PSAssignment = psaList.get(0);    
        }
        else
        {   
        	PSAssignment = new PermissionSetAssignment(AssigneeId = u3.id, PermissionSetId = ps.ID );
            insert( PSAssignment );   
        }
        
        System.RunAs(u3)
        {
                                     
            CMS_Weekly_Status_Report__c a = new CMS_Weekly_Status_Report__c();
            
            Date todayObj = date.today();
            Date startDate = todayObj.toStartOfWeek();
            Date endDate = startDate.addDays( 7 );
            a.Project_Manager__c = 'Ikjae Park';
            a.Report_Start_Date__c = startDate;
            a.Report_End_Date__c = endDate;
            a.Supervisor__c = 'Rhonda Urbanczyk';
            a.OwnerId = u3.Id;
            insert a;   
            
            CMS_Projects__c testRecord2 = new CMS_Projects__c();
            testRecord2.Name = 'OM:test';
            testRecord2.Anticipated_Hours__c = 5;
            testRecord2.Project_Number__c = 'test';
            testRecord2.Project_Manager__c = 'test';
            testRecord2.Due_Date__c = Date.today();
            testRecord2.Start_Date__c = Date.today();
            insert testRecord2;
            
            CMS_Milestone__c milestoneRecord = new CMS_Milestone__c();
            milestoneRecord.Name = 'test';
            milestoneRecord.CMS_Projects__c = testRecord2.id;
            milestoneRecord.Anticipated_Hours__c = 4;
            milestoneRecord.Start_Date__c = Date.today();
            milestoneRecord.Due_Date__c = Date.today();
            insert milestoneRecord;
            
            CMS_Milestone_Task__c taskRecord = new CMS_Milestone_Task__c();
            taskRecord.Name = 'test';
            taskRecord.CMS_Milestone__c = milestoneRecord.id;
            taskRecord.Start_Date__c = Date.today();
            taskRecord.Due_Date__c = Date.today();
            taskRecord.Assigned_Users__c = UserInfo.getName();
            taskRecord.Functional_Roles__c = 'test';
            insert taskRecord;
            
            CMS_CreateReportForUsers.createReport();	
        }
        
        Test.stopTest();
    }
}
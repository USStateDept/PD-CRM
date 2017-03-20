global class CMS_Library
{
	global static void processTask( User userObj, String projectName, String projectNumber, String functionalRole, String taskName, Date projStartDate, Date dueDate, boolean bEmail )
    {         
        Date todayObj = date.today();
		Date startDate = todayObj.toStartOfWeek();
		Date endDate = startDate.addDays( 6 );

		if (projStartDate < endDate && dueDate > startDate)
		{
			CMS_Weekly_Status_Report__c statusReport;
			try
			{
				statusReport = [SELECT id FROM CMS_Weekly_Status_Report__c WHERE Report_Start_Date__c = :startDate AND Report_End_Date__c = :endDate AND ownerId =:userObj.ID];
			}
			catch (Exception e)
			{
				statusReport = null;
			}
			
			if (statusReport == null)
			{
				statusReport = new CMS_Weekly_Status_Report__c();
				statusReport.ownerID = userObj.ID;
				statusReport.Report_Start_Date__c = startDate;
				statusReport.Report_End_Date__c = endDate;
				
				CMS_Weekly_Status_Report__c prevReport = CMS_CreateReportForUsers.getPreviousReport( userObj.ID );
				if (prevReport != null)
				{
					statusReport.Supervisor__c = prevReport.Supervisor__c;
					statusReport.Project_Manager__c = prevReport.Project_Manager__c;
				}

				insert statusReport;
			}
			
			Project_Tasks__c task;
			
			try
			{
				task = [SELECT Name, Due_Date__c, Start_Date__c, Project_Numbers__c, Functional_Roles__c, Active__c, Child__c
				          FROM Project_Tasks__c
				         WHERE Child__c = :statusReport.id
				           AND Name = :taskName
				           AND Project_Numbers__c = :projectName
				           AND Functional_Roles__c = :functionalRole
				         LIMIT 1];
			}
			catch (Exception e)
			{
				// record does not exist...
				task = new Project_Tasks__c();
			}
			
			task.Name = taskName;
			task.Due_Date__c = dueDate;
			task.Start_Date__c = projStartDate;
			
			if (task.child__c == null)
			{
				task.Child__c = statusReport.id;
			}

			if (projectNumber.startsWith( 'OM' ))
			{
				task.O_M__c = true;	
			}
			
			task.Project_Numbers__c = projectName;
			task.Functional_Roles__c = functionalRole;
			task.Active__c = true;
			upsert task;

			if (bEmail)
			{
				GLOBAL_Library.sendEmail( userObj.email, 'HTML Email Queue', 'Project ' + projectName + 
			    	                  ' has been assigned to you', 'A task has been assigned to you.<br>Please log into the system to check your task, ' + taskName );
			}
		}
    }
    

    global static void deactivateTask( User userObj, String projectName, String functionalRole, String taskName, Date projStartDate, Date dueDate )
    {
    	try
    	{
	        Date todayObj = date.today();
			Date startDate = todayObj.toStartOfWeek();
			Date endDate = startDate.addDays( 6 );
	
			if (dueDate > startDate && projStartDate < endDate && projStartDate > startDate)
			{
				CMS_Weekly_Status_Report__c statusReport;
				try
				{
					statusReport = [SELECT id FROM CMS_Weekly_Status_Report__c WHERE Report_Start_Date__c = :startDate AND Report_End_Date__c = :endDate AND ownerId =:userObj.ID];
				}
				catch (Exception e)
				{
					statusReport = null;
				}
				
				if (statusReport != null)
				{
					Project_Tasks__c oldTask = [SELECT id, active__c 
					                              FROM Project_Tasks__c
					                             WHERE Child__c = :statusReport.id 
					                               AND name = :taskName 
					                               AND Project_Numbers__c = :projectName
					                               AND Functional_Roles__c = :functionalRole];
					oldTask.active__c = false;
					
					update oldTask;
				}		
			}
    	}
    	catch (Exception e)
    	{
    		ApexPages.addMessage(new ApexPages.Message( ApexPages.Severity.ERROR, e.getMessage() ));
    	}
    }
    
    
    public static String getPermissionset( String userName )
	{
		String permissionName;
        try
        {
	        permissionName = [SELECT PermissionSet.Label
	    	                    FROM PermissionSetAssignment
	                           WHERE PermissionSet.IsOwnedByProfile = FALSE
	                             AND PermissionSetId
	                	          IN (SELECT ParentId FROM ObjectPermissions WHERE SObjectType = 'CMS_Projects__c')
	                             AND Assignee.Name = :userName LIMIT 1].PermissionSet.Label;
        }
        catch (Exception e)
        {
        	permissionName = '';
        }
        
        return permissionName;
	}
}
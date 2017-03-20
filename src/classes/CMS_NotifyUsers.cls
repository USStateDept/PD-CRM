global class CMS_NotifyUsers implements Schedulable
{
	global void execute (SchedulableContext sc)
	{
		notifyUsers();
	}
	
	global static void notifyUsers()
	{
		Date todayObj = date.today();
		Date startDate = todayObj.toStartOfWeek();
    	Date endDate = startDate.addDays( 6 );
		String timePeriod = startDate.format() + ' - ' + endDate.format();

		Map<String, User> userMapping = new Map<String, User>();
		Map<User, List<String>> supervisorList = new Map<User, List<String>>();
		Map<User, List<String>> pmList = new Map<User, List<String>>();

		for (CMS_Weekly_Status_Report__c cmsReport : [SELECT id, OwnerId, Owner.email, Owner.Name, Status__c, Supervisor__c, Project_Manager__c 
		                                                FROM CMS_Weekly_Status_Report__c
		                                               WHERE Report_Start_Date__c = :startDate 
		                                                 AND Report_End_Date__c = :endDate
		                                                 AND Status__c = 'Open'])
		{
				if (userMapping.containsKey( cmsReport.Supervisor__c ))
				{
					if (supervisorList.containsKey( userMapping.get( cmsReport.Supervisor__c ) ))
					{
						supervisorList.get( userMapping.get( cmsReport.Supervisor__c ) ).add( cmsReport.Owner.Name );
					}
					else
					{
						try
						{
							User u = [SELECT id, email FROM User WHERE name = :cmsReport.Supervisor__c];
							userMapping.put( cmsReport.Supervisor__c, u );
							
							List<String> users = New List<String>();
							users.add( cmsReport.Owner.Name );
							supervisorList.put( u, users );
						}
						catch (Exception e)
						{
							
						}
					}
				}
				else
				{
					try
					{
						User u = [SELECT id, email FROM User WHERE name = :cmsReport.Supervisor__c];
						userMapping.put( cmsReport.Supervisor__c, u );
						
						List<String> users = New List<String>();
						users.add( cmsReport.Owner.Name );
						supervisorList.put( u, users );
					}
					catch (Exception e)
					{
						
					}
				}
				
				if (userMapping.containsKey( cmsReport.Project_Manager__c ))
				{
					if (pmList.containsKey( userMapping.get( cmsReport.Supervisor__c ) ))
					{
						pmList.get( userMapping.get( cmsReport.Project_Manager__c ) ).add( cmsReport.Owner.Name );
					}
					else
					{
						try
						{
							User u = [SELECT id, email FROM User WHERE name = :cmsReport.Project_Manager__c];
							userMapping.put( cmsReport.Project_Manager__c, u );
							
							List<String> users = New List<String>();
							users.add( cmsReport.Owner.Name );
							pmList.put( u, users );
						}
						catch (Exception e)
						{
							
						}
					}
				}
				else
				{
					try
					{
						User u = [SELECT id, email FROM User WHERE name = :cmsReport.Project_Manager__c];
						userMapping.put( cmsReport.Project_Manager__c, u );
						
						List<String> users = New List<String>();
						users.add( cmsReport.Owner.Name );
						pmList.put( u, users );
					}
					catch (Exception e)
					{
						
					}
				}

				//GLOBAL_Library.sendEmail( cmsReport.Owner.Email, 'HTML Email Queue', 'CMS Status Report for ' + timePeriod, 'Greetings ' + cmsReport.Owner.Name +',<br/><br/> Please complete and submit this week\'s status report.<br/><br/>Thank you.' );
		}
		
		
		for (User user : supervisorList.keySet())
		{
			String userNames = '';
			
			for (String userName : supervisorList.get( user ))
			{
				userNames += userName + '<br/>';
			}
			
			GLOBAL_Library.sendEmail( user.Email, 'HTML Email Queue', 'CMS Status Report for ' + timePeriod, 'Greetngs,<br/><br/>The following users have not completed the status report -<br/>' + userNames + '<br/><br/>Thank you.' );
		}
		
		for (User user : pmList.keySet())
		{
			String userNames = '';
			
			for (String userName : pmList.get( user ))
			{
				userNames += userName + '<br/>';
			}
			
			GLOBAL_Library.sendEmail( user.Email, 'HTML Email Queue', 'CMS Status Report for ' + timePeriod, 'The following users have not completed the status report -<br/>' + userNames + '<br/><br/>Thank you.' );
		}
		
		
	}
	
	public static testMethod void testCMS_NotifyUsers()
    {
    	Date todayObj = date.today();
    	Date startDate = todayObj.toStartOfWeek();
    	Date endDate = startDate.addDays( 6 );
    	
    	CMS_Weekly_Status_Report__c a = new CMS_Weekly_Status_Report__c();
    	
		a.Project_Manager__c = 'Ikjae Park';
		a.Report_Start_Date__c = startDate;
		a.Report_End_Date__c = endDate;
		a.Supervisor__c = 'Rhonda Urbanczyk';
		a.OwnerId = UserInfo.getUserId();
        insert a;
        
        CMS_Weekly_Status_Report__c b = new CMS_Weekly_Status_Report__c();

		b.Project_Manager__c = 'Rhonda Urbanczyk';
		b.Report_Start_Date__c = startDate;
		b.Report_End_Date__c = endDate;
		b.Supervisor__c = 'Rhonda Urbanczyk';
		b.OwnerId = UserInfo.getUserId();
        insert b;
        
        CMS_Weekly_Status_Report__c c = new CMS_Weekly_Status_Report__c();

		c.Project_Manager__c = 'Rhonda Urbanczyk';
		c.Report_Start_Date__c = startDate;
		c.Report_End_Date__c = endDate;
		c.Supervisor__c = 'Rhonda Urbanczyk';
		c.OwnerId = UserInfo.getUserId();
        insert c;
        
    	CMS_NotifyUsers.notifyUsers();	
    }
}
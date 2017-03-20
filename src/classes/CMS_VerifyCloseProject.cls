global class CMS_VerifyCloseProject implements Schedulable
{
	global void execute (SchedulableContext sc)
	{
		closeProjects();
	}

	global static void closeProjects()
    {
    	List<CMS_Projects__c> closedProjects = new List<CMS_Projects__c>();
        
        for (CMS_Projects__c myProject : [SELECT name, status__c, Due_Date__c FROM CMS_Projects__c WHERE status__c != 'Completed' AND status__c != 'On Hold'])
        {
        	Map<String, Data> milestoneData = new Map<String, Data>();
    		Map<String, Map<String, List<AggregateResult>>> mileStoneFunctionalInfo = new Map<String, Map<String, List<AggregateResult>>>();
        	
	        for (CMS_Milestone__c milestone : [SELECT Due_Date__c, Name, Start_Date__c 
	                                             FROM CMS_Milestone__c 
	                                            WHERE CMS_Projects__r.Name = :myProject.name])
	        {
	            Data newData = new Data();
	            newData.type = milestone.name;
	            newData.dueDate = milestone.Due_Date__c.format();
	            newData.startDate = milestone.Start_Date__c.format();
	            milestoneData.put( milestone.name, newData );
	        }

	        CMS_Projects__c project = [SELECT Due_Date__c, Start_Date__c 
	                                     FROM CMS_Projects__c 
	                                    WHERE name = :myProject.name];
	        
	        for (CMS_Milestone_Task__c task : [SELECT CMS_Milestone__r.Name, Functional_Roles__c
	                                             FROM CMS_Milestone_Task__c
	                                            WHERE CMS_Milestone__r.CMS_Projects__r.name = :myProject.name])
	        {
	        	if (mileStoneFunctionalInfo.containsKey( task.CMS_Milestone__r.Name ))
	        	{
	        		Map<String, List<AggregateResult>> functionalInfo = mileStoneFunctionalInfo.get( task.CMS_Milestone__r.Name );
	        		
	        		if (!functionalInfo.containsKey( task.Functional_Roles__c ))
	        		{
	        			functionalInfo.put( task.Functional_Roles__c, new List<AggregateResult>() );
	        		}
	        	}
	        	else
	        	{
	        		mileStoneFunctionalInfo.put( task.CMS_Milestone__r.Name, new Map<String, List<AggregateResult>>() );
	        		mileStoneFunctionalInfo.get( task.CMS_Milestone__r.Name ).put( task.Functional_Roles__c, new List<AggregateResult>() );
	        	}
	        }
			
			String projectNameStr = myProject.name;
			
	        String soqlStr = 'SELECT Functional_Roles__c, Child__r.owner.name, max(Completed_Date__c) completedDate, max(Percentage_Complete__c) percentage ' +
	        				   'FROM Project_Tasks__c ' +
	        				  'WHERE Project_Numbers__c = :projectNameStr ' +
	        			   'GROUP BY Child__r.owner.name, Functional_Roles__c';
	        
	        System.debug( soqlStr );
	        
	        for (AggregateResult aggregatedData : Database.query( soqlStr ))
	        {
	        	String functionalRole = (String) aggregatedData.get( 'Functional_Roles__c' );
	        	
	        	for (String milestone : mileStoneFunctionalInfo.keySet())
	        	{
	        		Map<String, List<AggregateResult>> functionalInfo = mileStoneFunctionalInfo.get( milestone );
	        		
	        		if (functionalInfo.containsKey( functionalRole ))
	        		{
	        			functionalInfo.get( functionalRole ).add( aggregatedData );
	        		}
	        	}
	        }
			
			for (String milestone : mileStoneFunctionalInfo.keySet())
	    	{
	    		Map<String, List<AggregateResult>> functionalInfo = mileStoneFunctionalInfo.get( milestone );
	    		
	    		for (String function : functionalInfo.keySet())
	    		{
	    			for (AggregateResult aggregatedData : functionalInfo.get( function ))	
	    			{
	    				String functionalRole = (String) aggregatedData.get( 'Functional_Roles__c' );
			        	Integer percentage = Integer.valueOf( (Decimal) aggregatedData.get( 'percentage' ));
			        	Date completedDate = (Date) aggregatedData.get( 'completedDate' );
			    		
			    		if (milestoneData.containsKey( milestone ))
			        	{
			        		Data modifyData = milestoneData.get( milestone );
			        		modifyData.countOfRecords++;
			        		
			        		if (percentage != null)
			    			{
			    				if (modifyData.percentage == null)
			    				{
			    					modifyData.percentage = 0;
			    				}
			    				
			    				modifyData.percentage += percentage;
			    			}
			    			else
			    			{
			    				if (modifyData.percentage == null)
			    				{
			    					modifyData.percentage = 0;
			    				}
			    				
			    				modifyData.percentage += 0;
			    			}
			
			        		if (completedDate != null)
			        		{
				        		if (modifyData.completedDate == null)
					        	{
									modifyData.completedDate = completedDate.format();
					        	}
					        	else
					        	{
					        		if (Date.parse( modifyData.completedDate ) < completedDate)
					        		{
					        			modifyData.completedDate = completedDate.format();
					        		}
					        	}
			        		}
			        	}
	    			}
	    		}
	    	}
	    	
	    	List<Data> sortedList = new List<Data>();
	        Date todayObj = date.today();
	        
	        Boolean canBeClosed = true;
	        
	        for (Data d : milestoneData.values())
	        {
	        	if (d.percentage != null)
	        	{
	        		d.percentage = d.percentage / d.countOfRecords;
	        	}
	
	        	if (d.percentage == 100)
				{

				}
				else
				{
					canBeClosed = false;
				}
			}
			
			if (canBeClosed)
			{
				System.debug( myProject.Due_Date__c.daysBetween( todayObj ) );
				
				if (myProject.Due_Date__c.daysBetween( todayObj ) >= 7)
				{
					myProject.status__c = 'Completed';
					closedProjects.add( myProject );
				}
			}
        }
        
        update closedProjects;
    }
    
    // Wrapper class
    public class Data implements Comparable{
        public String type{ get; set; }
        public String dueDate{ get; set; }
        public String startDate{get; set; }
        public Integer percentage{ get; set; }
        public Integer delayDate{ get; set; }
        public String completedDate{ get; set; }
        public String status{get; set;}
        public Integer countOfRecords{get; set;}
        public String style{ get; set; }
        public String alt{ get; set; }
        public String sortExpression{ get; set; }
        public String sortDirection{ get; set; }
        
        public Data()
        {
        	countOfRecords = 0;
        }
        
        public Integer compareTo( Object obj )
        {
        	Data other = (Data) obj;
        	Integer retVal = 0;
            
            if (sortExpression != null && sortExpression.length() > 0 && 
                sortDirection != null && sortDirection.length() > 0)
            {
            	if (sortExpression.equals( 'Start Date' ))
            	{
            		if (this.startDate == other.startDate) retVal = 0;
            		else if (this.startDate > other.startDate) retVal = 1;
            		else retVal = -1;
            	}
            	else if (sortExpression.equals( 'Due Date' ))
            	{
            		if (this.dueDate == other.dueDate) retVal = 0;
            		else if (this.dueDate > other.dueDate) retVal = 1;
            		else retVal = -1;
            	}
            	else if (sortExpression.equals( 'Completed Date' ))
            	{
            		if (this.completedDate == other.completedDate) retVal = 0;
            		else if (this.completedDate > other.completedDate) retVal = 1;
            		else retVal = -1;
            	}
            }
            
            if (sortDirection == 'asc')
            {
            	retVal = retVal * -1;
            }
            
            return retVal;
        }
    }
    
    
    public static testMethod void testCMS_CreateReportForUsers()
    {
    	Date todayObj = date.today();
        Date startDate = todayObj.toStartOfWeek();
        Date endDate = startDate.addDays( 6 );
    	
    	// Testing Project Manager
    	User u3 = [SELECT Id FROM User WHERE name like 'Integrator Functional%' LIMIT 1];
    	PermissionSet ps = [SELECT ID From PermissionSet WHERE Label = 'CMS Project Manager'];
    	//PermissionSetAssignment PSAssignment = new PermissionSetAssignment(AssigneeId = u3.id, PermissionSetId = ps.ID );
        //insert( PSAssignment );
    	
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
        
        System.RunAs( u3 )
       	{
            CMS_Projects__c testRecord2 = new CMS_Projects__c();
            testRecord2.Name = 'test';
            testRecord2.Anticipated_Hours__c = 5;
            testRecord2.Project_Number__c = 'test';
            testRecord2.Project_Manager__c = 'test';
            testRecord2.Due_Date__c = Date.today();
            testRecord2.Start_Date__c = Date.today().addDays( -7 );
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
            taskRecord.Assigned_Users__c = 'Functional Integrator';
            taskRecord.Functional_Roles__c = 'test';
            insert taskRecord;
            
            CMS_Milestone_Task__c taskRecord2 = new CMS_Milestone_Task__c();
            taskRecord2.Name = 'test';
            taskRecord2.CMS_Milestone__c = milestoneRecord.id;
            taskRecord2.Start_Date__c = Date.today();
            taskRecord2.Due_Date__c = Date.today();
            taskRecord2.Assigned_Users__c = 'Functional Integrator';
            taskRecord2.Functional_Roles__c = 'test2';
            insert taskRecord2;
            
            CMS_Weekly_Status_Report__c b = new CMS_Weekly_Status_Report__c();
            todayObj = date.today().addDays( -7 );
            startDate = todayObj.toStartOfWeek();
            endDate = startDate.addDays( 6 );
            b.Project_Manager__c = 'Ikjae Park';
            b.Report_Start_Date__c = startDate;
            b.Report_End_Date__c = endDate;
            b.Supervisor__c = 'Rhonda Urbanczyk';
            b.OwnerId = UserInfo.getUserId();
            insert b;
            
            Project_Tasks__c ptc = new Project_Tasks__c();
            ptc.Child__c = b.id;
            ptc.Hours__c = 8;
            ptc.Due_Date__c = todayObj;
            ptc.Completed_Date__c = todayObj;
            ptc.Start_Date__c = todayObj;
            ptc.Name = 'test';
            ptc.Project_Number__c = 'test';
            ptc.Functional_Roles__c = 'test';
            ptc.Percentage_Complete__c = 100;
            insert ptc;
            
            Project_Tasks__c ptc2 = new Project_Tasks__c();
            ptc2.Child__c = b.id;
            ptc2.Hours__c = 8;
            ptc2.Due_Date__c = todayObj;
            ptc2.Completed_Date__c = todayObj;
            ptc2.Start_Date__c = todayObj;
            ptc2.Name = 'test';
            ptc2.Project_Number__c = 'test';
            ptc2.Functional_Roles__c = 'test2';
            ptc2.Percentage_Complete__c = 100;
            insert ptc2;
            
            CMS_VerifyCloseProject.closeProjects();	
        }
    }

}
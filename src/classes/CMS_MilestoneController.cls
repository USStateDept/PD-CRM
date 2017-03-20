public class CMS_MilestoneController
{
    private ApexPages.StandardController std;
    public CMS_Milestone__c milestone{ get; set; }
    public List<TaskObj> tasks{ get; set; }
    public List<TaskObj> archivedTasks{ get; set; }
    public String myPermissionset{ set; get; }
    
    public Integer taskNumber{ get; set; }
    public String taskID{ get; set; }
    
    public Boolean om{ get; set; }
    
    public CMS_MilestoneController( ApexPages.StandardController stdCtrl )
    {
        std = stdCtrl;
        milestone = (CMS_Milestone__c) std.getRecord();
        
        tasks = new List<TaskObj>();
        archivedTasks = new List<TaskObj>();
        
        om = false;
        
        if (milestone.CMS_Projects__r.Project_Type__c == 'O&M')
        {
        	om = true;
        }
        
        if (milestone.id != null)
        {
        	if (om)
        	{
	            for (CMS_Milestone_Task__c task : [SELECT CMS_Milestone__c, Due_Date__c, Start_Date__c, Completed_Date__c, Id, Hours_Spent__c, Name, 
	                                                      Assigned_Users__c, Anticipated_Hours__c, Functional_Roles__c, percentage__c, 
	                                                      Override_Percentage__c, Override_Completed_Date__c, Override__c
	                                                 FROM CMS_Milestone_Task__c 
	                                                WHERE CMS_Milestone__c = :milestone.id 
	                                                  AND Archived__c = false
	                                             ORDER BY createdDate Desc])
	            {
	                TaskObj obj= new TaskObj();
	                obj.task = task;
	                obj.assignedUsers = task.Assigned_Users__c;
	                
	                tasks.add( obj );
	            }
	            
	            for (CMS_Milestone_Task__c task : [SELECT CMS_Milestone__c, Due_Date__c, Start_Date__c, Completed_Date__c, Id, Hours_Spent__c, Name, 
	                                                      Assigned_Users__c, Anticipated_Hours__c, Functional_Roles__c, percentage__c, 
	                                                      Override_Percentage__c, Override_Completed_Date__c, Override__c
	                                                 FROM CMS_Milestone_Task__c 
	                                                WHERE CMS_Milestone__c = :milestone.id
	                                                  AND Archived__c = true
	                                             ORDER BY createdDate Desc])
	            {
	                TaskObj obj= new TaskObj();
	                obj.task = task;
	                obj.assignedUsers = task.Assigned_Users__c;
	                
	                archivedTasks.add( obj );
	            }
        	}
        	else
        	{
        		for (CMS_Milestone_Task__c task : [SELECT CMS_Milestone__c, Due_Date__c, Start_Date__c, Completed_Date__c, Id, Hours_Spent__c, Name, 
	                                                      Assigned_Users__c, Anticipated_Hours__c, Functional_Roles__c, percentage__c, 
	                                                      Override_Percentage__c, Override_Completed_Date__c, Override__c 
	                                                 FROM CMS_Milestone_Task__c 
	                                                WHERE CMS_Milestone__c = :milestone.id
	                                             ORDER BY createdDate Desc])
	            {
	                TaskObj obj= new TaskObj();
	                obj.task = task;
	                obj.assignedUsers = task.Assigned_Users__c;
	                
	                tasks.add( obj );
	            }
        	}
        }
    }
    
    
    public void newTask()
    {
        TaskObj taskObj = new TaskObj();
        taskObj.task = new CMS_Milestone_Task__c();
        taskObj.task.CMS_Milestone__c = milestone.id;
        
        if (tasks.size() > 0)
        {
            tasks.add( 0, taskObj );
        }
        else
        {
            tasks.add( taskObj );
        }
    }
    
    
    public PageReference archiveTask()
    {
    	if (null != taskID)
        {
        	CMS_Milestone_Task__c myTask = [SELECT Archived__c FROM CMS_Milestone_Task__c WHERE id = :taskID];
        	myTask.Archived__c = true;
        	ApexPages.addMessage(new ApexPages.Message( ApexPages.Severity.ERROR, '' + myTask ));
        	update myTask;
        }
        
        return new PageReference( '/' + milestone.id );
    }
    
    
    public PageReference unarchiveTask()
    {
    	if (null != taskID)
        {
        	CMS_Milestone_Task__c myTask = [SELECT Archived__c FROM CMS_Milestone_Task__c WHERE id = :taskID];
        	myTask.Archived__c = false;
        	ApexPages.addMessage(new ApexPages.Message( ApexPages.Severity.ERROR, '' + myTask ));
        	update myTask;
        }
        
        return new PageReference( '/' + milestone.id );
    }
    
    public void deleteTask()
    {
		
        if (null != taskNumber)
        {
            TaskObj taskObj = tasks.get( taskNumber - 1 );
            
            if ( taskObj.task.id != null )
            {
                tasks.remove( taskNumber - 1 );
                
                String users = taskObj.task.Assigned_Users__c;
                
                String[] listOfUsers = users.split( ',' );
                
                for (String user : listOfUsers)
                {
                    try
                    {
                        User prevUser = [SELECT id, email FROM User WHERE name = :user];
                        CMS_Library.deactivateTask( prevUser, milestone.CMS_Projects__r.name, taskObj.task.Functional_Roles__c, taskObj.task.Name, taskObj.task.Start_Date__c, taskObj.task.Due_Date__c );
                    }
                    catch (Exception e)
                    {
                        // User doesn't exist...
                    }
                }
                
                delete taskObj.task;
            }
            else
            {
                tasks.remove( taskNumber - 1 );
            }

            taskNumber = null;
        }
    }
    
    
    public PageReference save()
    {
        std.save();
        
        List<CMS_Milestone_Task__c> newTasks = new List<CMS_Milestone_Task__c>();
        Date todayObj = date.today();
        Date startDate = todayObj.toStartOfWeek();
        Date endDate = startDate.addDays( 6 );
        Map<String, User> userInfos = new Map<String, User>();
        
        for (TaskObj taskObj : tasks)
        {
            if ((taskObj.task.Due_Date__c != null && taskObj.task.Due_Date__c >= startDate) || 
                (milestone.CMS_Projects__r != null && !milestone.CMS_Projects__r.Project_Number__c.contains( 'OM' )))
            {
                String prevUsers = taskObj.task.Assigned_Users__c;
                
                String[] listOfNewUsers = taskObj.assignedUsers.split( ',' );

                for (String user : listOfNewUsers)
                {
                    try
                    {
                        User newUser;
                        
                        if (userInfos.containsKey( user ))
                        {
                            newUser = userInfos.get( user );
                        }
                        else
                        {
                            newUser = [SELECT id, email FROM User WHERE name = :user];
                            userInfos.put( user, newUser );
                        }
                        CMS_Library.processTask( newUser, milestone.CMS_Projects__r.name, milestone.CMS_Projects__r.Project_Number__c, taskObj.task.Functional_Roles__c, taskObj.task.Name, taskObj.task.Start_Date__c, taskObj.task.Due_Date__c, true );
                    }
                    catch (Exception e)
                    {
                        // User doesn't exist...
                    }
                }
                
                taskObj.task.Assigned_Users__c = taskObj.assignedUsers;

                if (prevUsers != null)
                {
                    String[] listOfOldUsers = prevUsers.split( ',' );
                    
                    Set<String> newUsers = New Set<String>();
                    newUsers.addAll( listOfNewUsers );
                    
                    Set<String> oldUsers = New Set<String>();
                    oldUsers.addAll( listOfOldUsers );
                    
                    oldUsers.removeAll( newUsers );
                    
                    for (String user : oldUsers)
                    {
                        try
                        {
                            User prevUser = [SELECT id, email FROM User WHERE name = :user];
    
                            CMS_Library.deactivateTask( prevUser, milestone.CMS_Projects__r.name, taskObj.task.Functional_Roles__c, taskObj.task.Name, taskObj.task.Start_Date__c, taskObj.task.Due_Date__c );
                        }
                        catch (Exception e)
                        {
                            // User doesn't exist
                        }
                    }
                }
            }
            
            newTasks.add( taskObj.task );
        }
        
        upsert newTasks;
        return new PageReference( '/' + milestone.id );
    }
    

    public List<String> getListOfUsers()
    {
    	List<String> users = new List<String>();
    	users.addAll( GLOBAL_Library.getPermissionsetUsers( 'CMS Basic', 'CMS_Weekly_Status_Report__c' ).split( ';' ));
    	users.addAll( GLOBAL_Library.getPermissionsetUsers( 'CMS Supervisor', 'CMS_Weekly_Status_Report__c' ).split( ';' ));
    	users.addAll( GLOBAL_Library.getPermissionsetUsers( 'CMS Project Manager', 'CMS_Weekly_Status_Report__c' ).split( ';' ));
    	
        return users;
    }
    
    
    public boolean getIsEditable()
    {
        if (myPermissionset == null)
        {
            myPermissionset = CMS_Library.getPermissionset( UserInfo.getName() );
        }
        
        if (myPermissionset.equals( 'CMS Project Manager' ) || myPermissionset.equals( 'CMS Supervisor' ))
        {
            return true;
        }
        
        return false;
    }
    
    
    public class TaskObj implements Comparable
    {
        public CMS_Milestone_Task__c task{ get; set; }
        public String assignedUsers{ get; set; }
        
        public TaskObj()
        {
            task = new CMS_Milestone_Task__c();
            assignedUsers = '';
        }
        
        public Integer compareTo( Object other )
        {
            TaskObj mo = (TaskObj) other;
            
            if (this.task.Start_Date__c > mo.task.Start_Date__c)
            {
                return 1;
            }
            else if (this.task.Start_Date__c == mo.task.Start_Date__c)
            {
                return 0;
            }
            else
            {
                return -1;
            }
        }
    }
    
    
    public static testMethod void testCMS_MilestoneController()
    {
        Test.startTest();
        
        ApexPages.currentPage().getParameters().put( 'projectName', 'SF:test' );
        User u3 = [SELECT Id FROM User WHERE name like 'Integrator Functional%' LIMIT 1];
        CMS_ReportController rc = new CMS_ReportController();
        
        CMS_Projects__c testObject = new CMS_Projects__c();
        testObject.Name = 'Test Project';
        testObject.Project_Number__c = 'O&M: Test Project';
        testObject.Completed_Date__c = date.today();
        testObject.Due_Date__c = date.today();
        testObject.Project_Manager__c = 'Rebecca Jenkins';
        testObject.Project_Number__c = 'Test123';
        testObject.Project_Lead__c = u3.id;
        insert testObject;
        
        CMS_Milestone__c testChildObject = new CMS_Milestone__c();
        testChildObject.Name = 'Test Task';
        testChildObject.Start_Date__c = date.today();
        testChildObject.Lead__c = u3.id;
        testChildObject.Due_Date__c = date.today();
        testChildObject.CMS_Projects__c = testObject.id;
        insert testChildObject;
        
        CMS_Milestone_Task__c taskRecord = new CMS_Milestone_Task__c();
        taskRecord.Name = 'test';
        taskRecord.CMS_Milestone__c = testChildObject.id;
        taskRecord.Start_Date__c = Date.today();
        taskRecord.Due_Date__c = Date.today();
        taskRecord.Assigned_Users__c = 'Integrator Functional,test';
        taskRecord.Functional_Roles__c = 'test';
        insert taskRecord;
        
        CMS_Milestone_Task__c taskRecord2 = new CMS_Milestone_Task__c();
        taskRecord2.Name = 'test';
        taskRecord2.CMS_Milestone__c = testChildObject.id;
        taskRecord2.Start_Date__c = Date.today();
        taskRecord2.Due_Date__c = Date.today();
        taskRecord2.Assigned_Users__c = 'Integrator Functional,test';
        taskRecord2.Functional_Roles__c = 'test2';
        
        CMS_Milestone_Task__c taskRecord3 = new CMS_Milestone_Task__c();
        taskRecord3.Name = 'test2';
        taskRecord3.CMS_Milestone__c = testChildObject.id;
        taskRecord3.Start_Date__c = Date.today();
        taskRecord3.Due_Date__c = Date.today();
        taskRecord3.Assigned_Users__c = 'Integrator Functional,test';
        taskRecord3.Functional_Roles__c = 'test2';
        
        ApexPages.StandardController sc = new ApexPages.StandardController( testChildObject );
            
        CMS_MilestoneController testCaseOne = new CMS_MilestoneController( sc );
        
        // Testing Project Manager
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
            System.RunAs( u3 )
        	{
            	insert( PSAssignment );   
            }
        }
        
        System.RunAs( u3 )
        {
            testCaseOne.newTask();
            testCaseOne.newTask();
            testCaseOne.taskNumber = 1;
            testCaseOne.deleteTask();
            testCaseOne.save();
            
            testCaseOne.newTask();
            for (TaskObj taskObj : testCaseOne.tasks)
            {
                taskObj.assignedUsers = 'test,Integrator Functional,test';
            }
            
            testCaseOne.save();
            testCaseOne.getListOfUsers();
            testCaseOne.getIsEditable();
            testCaseOne.taskNumber = 1;
            //testCaseOne.deleteTask();
            
            TaskObj a1 = new TaskObj();
            a1.task = taskRecord;
            a1.assignedUsers = 'test';
            
            TaskObj a2 = new TaskObj();
            a2.task = taskRecord2;
            a2.assignedUsers = 'test';
            
            a1.compareTo( a2 );
                    
        	delete PSAssignment;
        }
        testCaseOne.getIsEditable();
    }
}
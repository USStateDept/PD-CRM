public class CMS_WeeklyStatusReportController
{
    private ApexPages.StandardController std;
    
    public CMS_Weekly_Status_Report__c statusReport{ get; set; }
    public CMS_Weekly_Status_Report__c filter{ get; set; }
    public String supervisor{ get; set; }
    public String projectManager{ get; set; }
    public String contractNumber{ get; set; }
    public boolean editable{ get; set; }
    public boolean completed{ get; set; }
    public String myPermissionset{ set; get; }
    public String timePeriod{ get; set; }
    
    // Utilizing the project object to sperate out the tasks...
    public List<Project_Tasks__c> onGoingTasks{ get; set; }
    public List<Project_Tasks__c> projectTasks{ get; set; }
    public List<Project_Tasks__c> keyTasks{ get; set;}
    public List<Upcoming_Leave__c> upcomingLeaves{ get; set;}
    
    public String clickStr{ get; set; }
    
    public Date todayObj = date.today();
    public Date startDate = todayObj.toStartOfWeek();
    public Date endDate = startDate.addDays( 6 );
    public String userID = UserInfo.getUserId();
    
    //key=project type, value=list of project names
    public Map<String,List<String>> milestoneTasksMap {get; set;}
    public List<String> projectNames {get; set;}
    //list of milestoneTaskMap
    public List<Map<String,Date>> projectTaskDuedateMapsList {get; set;}
    
    public String columnName{ get; set; }
    public String ascOrDesc{ get; set; }
    public String owner{ get; set; }
    
    public Integer onGoingNumber{ get; set; }
    public Integer projectTaskNumber{ get; set; }
    public Integer miscTaskNumber{ get; set; }
    public Integer keyTasksNumber{ get; set; }
    public Integer upcomingNumber{ get; set; }
            
    // Ikjae: Controller for the Listview page... Fetches the current status report and permissionset from the database. If it does not exist, it will generate one for the user.
    public CMS_WeeklyStatusReportController()
    {
        
        // Ikjae: The filter is only for the supervisor and project manager
        if (filter == null)
        {
            filter = new CMS_Weekly_Status_Report__c();
        }

        timePeriod = startDate.format() + ' - ' + endDate.format();
        myPermissionset = GLOBAL_Library.getPermissionset( UserInfo.getName(), 'CMS_Weekly_Status_Report__c' );
        
        try
        {   
            statusReport = [SELECT id, Status__c, ownerId, Report_Start_Date__c, Report_End_Date__c, Project_Manager__c, Supervisor__c FROM CMS_Weekly_Status_Report__c WHERE Report_Start_Date__c = :startDate AND Report_End_Date__c = :endDate AND ownerId = :userID];
        }
        catch (Exception e)
        {
            statusReport = new CMS_Weekly_Status_Report__c();
            statusReport.OwnerId = userID;
            statusReport.Status__c = 'Open';
            statusReport.Report_Start_Date__c = startDate;
            statusReport.Report_End_Date__c = endDate;
        }

        if (statusREport.Status__c == 'Open')
        {
            completed = false;
        }
        else
        {
            completed = true;
        }
    }
    
    
    // Ikjae: Controller for edit and view page... Fetches the current status report and permissionset from the database
    public CMS_WeeklyStatusReportController( ApexPages.StandardController stdCtrl )
    {
        milestoneTasksMap = new Map<String,List<String>>();
        projectNames = new List<String>();
        //key=project type, value=project task maps list
        Map<String,List<Map<String,Date>>> projectsTasksMap = new Map<String,List<Map<String,Date>>>();
        //key=project name+task name, value=due date
        Map<String,Date> projectTaskDuedateMap = new Map<String,Date>();
        //list of milestoneTaskMap
        projectTaskDuedateMapsList = new List<Map<String,Date>>();
        User found = null;
        Project_Tasks__c onGoingTask = null;
        Project_Tasks__c projectTask = null;
        Date dueDate = null;
        std = stdCtrl;
        
        if (std != null)
        {
            editable = true;
            statusReport = (CMS_Weekly_Status_Report__c) std.getRecord();
            myPermissionset = GLOBAL_Library.getPermissionset( UserInfo.getName(), 'CMS_Weekly_Status_Report__c' );
                
            try {
                found = [SELECT Id,Name FROM User WHERE Id = :UserInfo.getUserId()];             
            } catch(Exception e) {
                System.debug('Exception is caught: '+e.getMessage());
            }
            
            List<CMS_Milestone_Task__c> milestoneTasks = 
                [SELECT Archived__c,Assigned_Users__c,CMS_Milestone__c,
                 CMS_Milestone_Task__c.CMS_Milestone__r.CMS_Projects__r.Status__c,
                 CMS_Milestone_Task__c.CMS_Milestone__r.CMS_Projects__r.Project_Type__c,
                 CMS_Milestone_Task__c.CMS_Milestone__r.CMS_Projects__r.Name,
                 Completed_Date__c,Due_Date__c,Hours_Spent__c,Id,
                 Name,Override_Completed_Date__c,Override_Percentage__c,Override__c,Percentage__c,Project_Name__c,
                 Start_Date__c 
                 FROM CMS_Milestone_Task__c
                 WHERE ((Completed_Date__c = null or (Percentage__c = null or Percentage__c < 100.0)) and 
                        (Override_Completed_Date__c = null or
                         (Override_Percentage__c = null or Override_Percentage__c < 100.0)))
                 AND CMS_Milestone_Task__c.CMS_Milestone__r.CMS_Projects__r.Status__c != 'Completed'
                 AND Assigned_Users__c LIKE :found.Name + '%'
                 AND Archived__c = false];

            if(milestoneTasks != null && milestoneTasks.size() > 0) {
                for(CMS_Milestone_Task__c milestoneTask : milestoneTasks) {
                    String projectType = milestoneTask.CMS_Milestone__r.CMS_Projects__r.Project_Type__c;
                    String projectName = milestoneTask.CMS_Milestone__r.CMS_Projects__r.Name;
                    String taskName = milestoneTask.Name;
                    String projectTaskName = projectName+'-'+taskName;
                    
                    projectTaskDuedateMap = new Map<String,Date>();
                    projectTaskDuedateMap.put(projectTaskName,milestoneTask.Due_Date__c);
                    projectNames.add(projectName);
                    
                    if(!projectsTasksMap.containsKey(projectType)) {
                        projectTaskDuedateMapsList = new List<Map<String,Date>>();                        
                    } else {
                        projectTaskDuedateMapsList = projectsTasksMap.get(projectType);
                    }
                    
                    projectTaskDuedateMapsList.add(projectTaskDuedateMap);
                    projectsTasksMap.put(projectType, projectTaskDuedateMapsList);
                }
            }

            if (statusReport.id == null)
            {
                statusReport.Report_Start_Date__c = startDate;
                statusReport.Report_End_Date__c = endDate;
                statusReport.OwnerId = userID;
                
                //When the new week is started, carry over any incompleted task from
                //previous report.

                if(!projectsTasksMap.isEmpty()) {
                    if(projectsTasksMap.containsKey('O&M')) {
                        projectTaskDuedateMapsList = projectsTasksMap.get('O&M');
                        
                        List<Project_Tasks__c> prevOnGoingTasks = getPrevOnGoingTasks(statusReport.id, projectNames, projectTaskDuedateMapsList);
                        if(onGoingTasks == null)
                            onGoingTasks = new List<Project_Tasks__c>();
                        onGoingTasks.addAll(prevOnGoingTasks);
                                
                    }//end of O&M

                    if(projectsTasksMap.containsKey('Project') || projectsTasksMap.containsKey('Service Request')) {
                        if(projectsTasksMap.containsKey('Project'))
                            projectTaskDuedateMapsList = projectsTasksMap.get('Project');
                        if(projectsTasksMap.containsKey('Service Request'))
                            projectTaskDuedateMapsList = projectsTasksMap.get('Service Request');
                    
                        List<Project_Tasks__c> prevProjectTasks = getPrevProjectTasks(statusReport.id, projectNames, projectTaskDuedateMapsList);
                        if(projectTasks == null)
                            projectTasks = new List<Project_Tasks__c>();
                        if(prevProjectTasks != null || prevProjectTasks.size() > 0)     
                            projectTasks.addAll(prevProjectTasks);  
                                    
                    }//end of Project & Service Request

                }        
            }//end of statusReport id is null
            else
            {
                if (statusReport.OwnerId != UserInfo.getUserId())
                {
                    if (myPermissionset == 'CMS Basic')
                    {
                        editable = false;
                    }
                }
                else
                {
                    if (statusReport.Status__c != 'Open')
                    {
                        editable = false;
                    }
	            }
                
            }
            timePeriod = statusReport.Report_Start_Date__c.format() + ' - ' + statusReport.Report_End_Date__c.format();
        }
    }
    
    //Retrieve previous ongoing tasks that were not completed
    public List<Project_Tasks__c> getPrevOnGoingTasks(String statusReportId, List<String> projectNames, List<Map<String,Date>> projectTaskMapsList) {
        List<Project_Tasks__c> prevOnGoingTasks = new List<Project_Tasks__c>();
        List<Project_Tasks__c> projectTasks = new List<Project_Tasks__c>();
        Set<String> projectTaskNamesSet;
        Project_Tasks__c onGoingTask;
        Project_Tasks__c prevOnGoingTask;
        Date dueDate;
        String projectName;
        String taskName;
        String projectTaskName;
        //Go back 1 week
        Date prevStartDate = startDate.addDays(-7);
        Date prevEndDate = prevStartDate.addDays(6);
        
        //Retrieve ongoing tasks that were not completed from previous report
        if(statusReportId == null) {
            projectTasks = [SELECT Percentage_Complete__c, Completed_Date__c, Functional_Roles__c, 
                Comments__c, Project_Numbers__c, Hours__c, Id, Name, Due_Date__c, Start_Date__c, 
                Child__c, Active__c, O_M__c
            FROM Project_Tasks__c
            WHERE O_M__c = true
            AND Project_Numbers__c IN :(projectNames)
            AND Project_Tasks__c.Child__r.OwnerId = :UserInfo.getUserId()
            AND ((Percentage_Complete__c = null or Percentage_Complete__c < 100.0) or
                (Completed_Date__c = null))
            AND Active__c = true
            AND (Child__r.Report_Start_Date__c = :prevStartDate
            AND Child__r.Report_End_Date__c = :prevEndDate)
            LIMIT 1000];
        }
   
        if(projectTasks != null && projectTasks.size() > 0) {
            for(Integer i=0; i<projectTasks.size(); i++) {
                prevOnGoingTask = projectTasks.get(i);
                projectTaskName = prevOnGoingTask.Project_Numbers__c+'-'+prevOnGoingTask.Name;
                if(projectTaskMapsList != null) {
                    //Iterate thru the maps list and
                    //retrieve a due date by project type for each map
                    for(Map<String,Date> projectTaskMap : projectTaskMapsList) {
                        if(projectTaskMap.containsKey(projectTaskName)) {
                            dueDate = projectTaskMap.get(projectTaskName);
                            break;
                        }
                    }
                }//end of projectTaskMapsList not empty
                
                //Since this is a new status report, should clone the previous task to carry
                //all information over.
                if(statusReportId == null) {
                    onGoingTask = prevOnGoingTask.clone(false,true);
                    onGoingTask.Child__c = null;
                    //Task's due date should be matched with the one from milestones details
                    onGoingTask.Due_Date__c = dueDate;                    
                }
                
                prevOnGoingTasks.add(onGoingTask);                      
            }
        }
        
        projectTasks = null;
        return prevOnGoingTasks;
    }
    
    //Retrieve previous project tasks that were not completed
    public List<Project_Tasks__c> getPrevProjectTasks(String statusReportId, List<String> projectNames, List<Map<String,Date>> projectTaskMapsList) {
        List<Project_Tasks__c> prevProjectTasks = new List<Project_Tasks__c>();
        List<Project_Tasks__c> projectTasks;
        Project_Tasks__c projectTask;
        Date dueDate;
        String projectTaskName;
        //Go back 1 week
        Date prevStartDate = startDate.addDays(-7);
        Date prevEndDate = prevStartDate.addDays(6);
       
        //Retrieve projects and service requests that were not completed from previous report
        if(statusReportId == null) {
            projectTasks = [SELECT Percentage_Complete__c, Completed_Date__c, Functional_Roles__c, 
                Comments__c, Project_Numbers__c, Hours__c, Id, Name, Due_Date__c, Start_Date__c, 
                Child__c, Active__c, O_M__c
            FROM Project_Tasks__c
            WHERE O_M__c = false
            AND Project_Numbers__c IN :(projectNames)
            AND Project_Tasks__c.Child__r.OwnerId = :UserInfo.getUserId()
            AND ((Percentage_Complete__c = null or Percentage_Complete__c < 100.0) or
                (Completed_Date__c = null))
            AND Active__c = true
            AND (Child__r.Report_Start_Date__c = :prevStartDate
            AND Child__r.Report_End_Date__c = :prevEndDate)
            LIMIT 1000];
        }

        if(projectTasks != null && projectTasks.size() > 0) {
            for(Project_Tasks__c prevProjectTask : projectTasks) {
                projectTaskName = prevProjectTask.Project_Numbers__c+'-'+prevProjectTask.Name;
                if(projectTaskMapsList != null) {
                    //Iterate thru the maps list and
                    //retrieve a due date by project type for each map
                    for(Map<String,Date> projectTaskMap : projectTaskMapsList) {
                        if(projectTaskMap.containsKey(projectTaskName)) {
                            dueDate = projectTaskMap.get(projectTaskName);
                            break;
                        }
                    }
                }//end of if projectTaskMapsList is not empty
                
                //Since this is a new status report, should clone the previous task to carry
                //all information over.
                if(statusReportId == null) {
                    projectTask = prevProjectTask.clone(false,true);
                    projectTask.Child__c = null;
                    //Task's due date should be matched with the one from milestones details
                    projectTask.Due_Date__c = dueDate;
                }
                
                prevProjectTasks.add(projectTask);                      
            }
        }
        
        projectTasks = null;
        return prevProjectTasks;
    }
    
    // Ikjae: Fetches all of the active status report
    public List<CMS_Weekly_Status_Report__c> getActiveReports()
    {
        String soql = 'SELECT id, Report_Start_Date__c, OwnerId, Report_End_Date__c, Project_Manager__c, Supervisor__c FROM CMS_Weekly_Status_Report__c WHERE Report_Start_Date__c != :startDate AND Report_End_Date__c != :endDate AND Status__c = \'Open\' AND ownerID = :userID';
        return Database.query( soql );
    }
    
    
    public List<CMS_Weekly_Status_Report__c> getCurrentWeeksReports()
    {
        String soql = 'SELECT id, Report_Start_Date__c, OwnerId, Status__c, Report_End_Date__c, Project_Manager__c, Supervisor__c FROM CMS_Weekly_Status_Report__c WHERE Report_Start_Date__c = :startDate AND Report_End_Date__c = :endDate';
        
        if (filter.Supervisor__c != null && filter.Supervisor__c.length() > 0)
        {
            String supervisor = filter.Supervisor__c;
            soql += ' AND Supervisor__c = :supervisor';
        }
        
        if (filter.Project_Manager__c != null && filter.Project_Manager__c.length() > 0)
        {
            String projManager = filter.Project_Manager__c;
            soql += ' AND Project_Manager__c = :projManager';
        }
        
        if (owner != null && owner.length() > 0 && owner.length() > 0)
        {
            Id userId = [SELECT id FROM User WHERE name = :owner].Id;
            soql += ' AND ownerId = :userId';
        }
        
        soql += ' LIMIT 1000';
        
        return Database.query( soql );
    }
    
    
    public List<CMS_Weekly_Status_Report__c> getCompletedReports()
    {
        String soql = 'SELECT id, Report_Start_Date__c, Report_End_Date__c, Project_Manager__c, Supervisor__c, ownerId FROM CMS_Weekly_Status_Report__c WHERE Status__c = \'Submitted\'';

        if (filter.Supervisor__c != null && filter.Supervisor__c.length() > 0)
        {
            String supervisor = filter.Supervisor__c;
            soql += ' AND Supervisor__c = :supervisor';
        }
        
        if (filter.Project_Manager__c != null && filter.Project_Manager__c.length() > 0)
        {
            String projManager = filter.Project_Manager__c;
            soql += ' AND Project_Manager__c = :projManager';
        }
        
        if (owner != null && owner.length() > 0)
        {
            Id userId = [SELECT id FROM User WHERE name = :owner].Id;
            soql += ' AND ownerId = :userId';
        }
        
        if (myPermissionset == 'CMS Basic')
        {
            soql += ' AND ownerId = :userID';
        }
        
        soql += ' LIMIT 1000';
        
        return Database.query( soql );
    }


    public List<CMS_Weekly_Status_Report__c> getArchivedReports()
    {
        String soql = 'SELECT id, Report_Start_Date__c, Report_End_Date__c, Project_Manager__c, Supervisor__c, ownerId FROM CMS_Weekly_Status_Report__c WHERE Status__c = \'Archived\'';
        
        
        if (filter.Supervisor__c != null && filter.Supervisor__c.length() > 0)
        {
            String supervisor = filter.Supervisor__c;
            soql += ' AND Supervisor__c = :supervisor';
        }
        
        if (filter.Project_Manager__c != null && filter.Project_Manager__c.length() > 0)
        {
            String projManager = filter.Project_Manager__c;
            soql += ' AND Project_Manager__c = :projManager';
        }
        
        if (owner != null && owner.length() > 0)
        {
            Id userId = [SELECT id FROM User WHERE name = :owner].Id;
            soql += ' AND ownerId = :userId';
        }
        
        if (myPermissionset == 'CMS Basic')
        {
            String usrID = userID + '';
            soql += ' AND ownerId = :usrID';
        }
        
        soql += ' ORDER BY Report_Start_Date__c LIMIT 1000';
        
        return Database.query( soql );
    }

    
    public List<Project_Tasks__c> getOnGoingTaskList()
    {        
        if (onGoingTasks == null)
        {
            onGoingTasks = [SELECT Percentage_Complete__c, Completed_Date__c, Functional_Roles__c, Comments__c, Project_Numbers__c, Hours__c, Id, Name, Due_Date__c, Start_Date__c,
                                Child__c 
                              FROM Project_Tasks__c
                             WHERE Child__c = :statusReport.id
                               AND O_M__c = true
                               AND active__c = true];
        }
        
        return onGoingTasks;
    }
    
    
    public List<Project_Tasks__c> getProjectTaskList()
    {
        if (projectTasks == null)
        {
            projectTasks = [SELECT Percentage_Complete__c, Completed_Date__c, Functional_Roles__c, Comments__c, Project_Numbers__c, Hours__c, Id, Name, Due_Date__c, Start_Date__c 
                              FROM Project_Tasks__c
                             WHERE Child__c = :statusReport.id
                               AND O_M__c = false
                               AND active__c = true];
        }
        
        return projectTasks;
    }
  
  
  public List<Project_Tasks__c> getKeyTaskList()
    {
        if (keyTasks == null)
        {
          keyTasks = new List<Project_Tasks__c>();
          
        Date futureStartDate = startDate.addDays( 7 );
      
      // Each projects...
          for (CMS_Projects__c project : [SELECT Name, Due_Date__c, Start_Date__c
                             FROM CMS_Projects__c
                            WHERE Due_Date__c >= :futureStartDate
                              AND  Project_Lead__c = :statusReport.ownerId])
          {
            Project_Tasks__c newTask = new Project_Tasks__c();
            newTask.name = 'Project Maintainance - ' + project.name;
            newTask.Project_Numbers__c = project.name;
            newTask.Due_Date__c = project.Due_Date__c;
            newTask.Functional_Roles__c = 'Management';
            
            keyTasks.add( newTask );
          }
          
          
          // Each milestones...
          for (CMS_Milestone__c milestone : [SELECT Name, Due_Date__c, Start_Date__c, CMS_Projects__r.name
                                FROM CMS_Milestone__c
                               WHERE Due_Date__c >= :futureStartDate
                                 AND Lead__c = :statusReport.ownerId])
          {
            Project_Tasks__c newTask = new Project_Tasks__c();
            newTask.name = milestone.name;
            newTask.Project_Numbers__c = milestone.CMS_Projects__r.name;
            newTask.Due_Date__c = milestone.Due_Date__c;
            newTask.Functional_Roles__c = 'Management';
            
            keyTasks.add( newTask );
          }
          
          //String userName = '%' + statusReport.owner.name + '%';
            String userName = '';
            
            if(String.isNotEmpty(statusReport.OwnerId)) {
                User u = null;
                
                try {
                    u = [SELECT name FROM User
                         WHERE id = :statusReport.OwnerId];
                    userName = '%' + u.Name + '%';
                } catch(Exception e) {
                    //user is not found, do nothing...
                    System.debug('getKeyTaskList - Exception is caught ' + e.getMessage());
                }
            }
            
      // Each tasks
          for (CMS_Milestone_Task__c task : [SELECT Id, Name, Assigned_Users__c, Completed_Date__c, Due_Date__c, Start_Date__c, CMS_Milestone__r.CMS_Projects__r.name, CMS_Milestone__r.name 
                                               FROM CMS_Milestone_Task__c
                                              WHERE Due_Date__c >= :futureStartDate
                                 AND Assigned_Users__c like :userName])
          {
            Project_Tasks__c newTask = new Project_Tasks__c();
            newTask.name = task.Name;
            newTask.Project_Numbers__c = task.CMS_Milestone__r.CMS_Projects__r.name;
            newTask.Due_Date__c = task.Due_Date__c;
            newTask.Functional_Roles__c = task.CMS_Milestone__r.name;
            
            keyTasks.add( newTask );
          }
        }
        
        return keyTasks;
    }

    
    public List<Upcoming_Leave__c> getUpcomingLeavesList()
    {
        if (upcomingLeaves == null)
        {
            upcomingLeaves = [SELECT Types_of_Leave__c, Start_Date__c, End_Date__c, Id, Name FROM Upcoming_Leave__c WHERE Child__c = :statusReport.id];
        }
        
        return upcomingLeaves;
    }
    
    
    public void newUpComingLeave()
    {
        cleanUpList();
        Upcoming_Leave__c newTask = new Upcoming_Leave__c();
        newTask.Child__c = statusReport.id;
        upcomingLeaves.add( newTask );
        clickStr = 'upcomingLeave';
    }
    
    
    public String getListOfSupervisors()
    {
        return 'Dominique Sullivan;Peter Jarrell;Chris Palamara;Rhonda Urbanczyk';
    }
    
    
    public String getListOfProjectManagers()
    {
        return 'Dominique Sullivan;Peter Jarrell';
    }
    
    public String getListOfUsers()
    {
        return GLOBAL_Library.getPermissionsetUsers( 'CMS Basic', 'CMS_Weekly_Status_Report__c' ) + getListOfProjectManagers() + getListOfSupervisors();
    }
    
    
    public String getListOfContracts()
    {
        return 'FTE;CITI;SAQMMA12C0082';
    }
    
    
    public String getFunctionalRoles()
    {
        String retVal = '';
        
        for (CMS_Admin_Property__c capc : [SELECT Value__c FROM CMS_Admin_Property__c WHERE Type__c = 'Functional Roles'])
        {
            retVal += capc.value__c + ';';
        }
        
        return retVal;
    }
    
    
    public String getProjectNumbers()
    {
        String retVal = '';
        
        for (CMS_Admin_Property__c capc : [SELECT Value__c FROM CMS_Admin_Property__c WHERE Type__c = 'Project Number'])
        {
            retVal += capc.value__c + ';';
        }
        
        return retVal;
    }
    
    
    Public PageReference edit()
    {
        return new PageReference( '/apex/CMS_WeeklyStatusReportEdit?id=' + statusReport.id );
    }


    public PageReference cancel()
    {
        return new PageReference( '/apex/CMS_WeeklyStatusReportListView' ); 
    }
    
    
    public PageReference save()
    {
        Boolean error = false;
        Boolean isNewReport = false;
        List<Upcoming_Leave__c> updatedUpcomingLeaves =  new List<Upcoming_Leave__c>();
        List<Project_Tasks__c> updatedOnGoingTasks = new List<Project_Tasks__c>();
        List<Project_Tasks__c> updatedProjectTasks = new List<Project_Tasks__c>();
        
        if (statusReport.Supervisor__c == null)
        {
            ApexPages.addMessage(new ApexPages.Message( ApexPages.Severity.ERROR, 'Supervisor is required field.' ));
            error = true;
        }
        if (statusReport.Project_Manager__c == null)
        {
            ApexPages.addMessage(new ApexPages.Message( ApexPages.Severity.ERROR, 'Project Manager is required field.' ));
            error = true;
        }
        
        if (error)
        {
            return null;
        }
        cleanUpList();
        
        if(statusReport.Id == null)
            isNewReport = true;
        
        std.save();
                
        //Retrieve statusReport again after saved to get id
        statusReport = (CMS_Weekly_Status_Report__c) std.getRecord();
        System.debug('@@@3. onGoingTasks...'+onGoingTasks);
        if(isNewReport) {
            for(Project_Tasks__c onGoingTask : onGoingTasks) {
                if(onGoingTask.Child__c == null)
                    onGoingTask.Child__c = statusReport.Id;
                updatedOnGoingTasks.add(onGoingTask);
            }
            
            for(Project_Tasks__c projectTask : projectTasks) {
                if(projectTask.Child__c == null)
                    projectTask.Child__c = statusReport.Id;
                updatedProjectTasks.add(projectTask);
            }   
        }
        else {
            updatedOnGoingTasks.addAll(onGoingTasks);
            updatedProjectTasks.addAll(projectTasks);
        }

        upsert updatedOnGoingTasks;
        upsert updatedProjectTasks;
        
        //upsert onGoingTasks;
        //upsert projectTasks;

        //Stephanie P. (9/9/14) - Check whether the current report is a new report,
        //and report id is not assigned to upcoming leaves yet,
        //then assign id to each of them.
        //Cannot save upcomingLeaves without status report id
        if(isNewReport) {
            for(Upcoming_Leave__c upcomingLeave : upcomingLeaves) {
                upcomingLeave.Child__c = statusReport.Id;
                updatedUpcomingLeaves.add(upcomingLeave);
            }
        }     
        else
            updatedUpcomingLeaves.addAll(upcomingLeaves);
        
        upsert updatedUpcomingLeaves;
        
        //clean up
        updatedOnGoingTasks = null;
        updatedUpcomingLeaves = null;
        updatedUpcomingLeaves = null;
        
        return new PageReference( '/' + statusReport.id );
    }
    
    
    public void calculatePercentage( List<Project_Tasks__c> taskList )
    {
      List<String> projectNumbers = new List<String>();
      List<String> taskNames = new List<String>();
      
      for (Project_Tasks__c myTask : taskList)
      {
        projectNumbers.add( myTask.Project_Numbers__c );
        taskNames.add( myTask.Name );
      }
      
      List<CMS_Milestone_Task__c> updateTasks = new List<CMS_Milestone_Task__C>();
      System.debug( updateTasks );
      
      String soqlStr = 'SELECT Child__r.owner.name userName, name, Project_Numbers__c, SUM(hours__c) hours, max(Completed_Date__c) completedDate, max(Percentage_Complete__c) percentage ' +
                   'FROM Project_Tasks__c ' +
                  'WHERE Project_Numbers__c in :projectNumbers ' +
                     'AND Name in :taskNames ' +
                     'AND Child__r.status__c != \'Open\' ' +
                 'GROUP BY Child__r.owner.name, name, Project_Numbers__c';
       
       Map<String, List<Integer>> percentageByProject = new Map<String, List<Integer>>();
       Map<String, Date> compDateByProject = new Map<String, Date>();
       Map<String, Integer> hoursByProject = new Map<String, Integer>();
       
       for (AggregateResult aggregatedData : Database.query( soqlStr ))
        {
          String taskName = (String) aggregatedData.get( 'name' );
          String projectNumber = (String) aggregatedData.get( 'Project_Numbers__c' );
          Integer percentage = Integer.valueOf( (Decimal) aggregatedData.get( 'percentage' ));
        Date completedDate = (Date) aggregatedData.get( 'completedDate' );
        Integer hour = Integer.valueOf( (Decimal) aggregatedData.get( 'hours' ));
        
        String key = taskName + projectNumber;
        
          if (percentageByProject.containsKey( key ))
          {
            percentageByProject.get( key ).add( percentage );
            
            //Stephanie P. (09/03/14) - Fixed error 'Attempt to de-reference a null object' when sumitted
            //a report
            if(hoursByProject.containsKey(key)) {
                hoursByProject.put( key, hoursByProject.get( key ) + hour );                  
            }
              
            if (compDateByProject.containsKey(key) && 
                (compDateByProject.get( key ) < completedDate))
            {
              compDateByProject.put( key, completedDate );  
            }            
          }
          else
          {
            percentageByProject.put( key, new List<Integer>() );
            percentageByProject.get( key ).add( percentage );
            
            compDateByProject.put( key, completedDate );
            hoursByProject.put( key, hour );
          }
        }
        
        if (percentageByProject.size() > 0)
        {
          System.debug( percentageByProject );
          
          for (CMS_Milestone_Task__c myTask : [SELECT name, Completed_Date__c, Percentage__c, Project_Name__c, Hours_Spent__c
                                                     FROM CMS_Milestone_Task__c
                                                    WHERE name in :taskNames
                                                      AND CMS_Milestone__r.CMS_Projects__r.name in :projectNumbers])
          {
            System.debug( myTask );
            
            Integer percentage = 0;
            String projectName = myTask.name + myTask.Project_Name__c;
            
            if (percentageByProject.get( projectName ) != null)
            {
              for (Integer perf : percentageByProject.get( projectName ))
              {
                if (perf != null)
                {
                  percentage += perf;
                }
              }
              
              percentage = percentage / percentageByProject.get( projectName ).size();
              myTask.Percentage__c = percentage;
              myTask.Hours_Spent__c = hoursByProject.get( projectName );
              if (percentage == 100)
              {
                myTask.Completed_Date__c = compDateByProject.get( projectName );
              }
              
              updateTasks.add( myTask );
            }
          }
          
          System.debug( updateTasks );
          
          update updateTasks;
          
        }
    }
    
    public void refresh() {}  
    
    public PageReference resetFilter()
    {
        filter = new CMS_Weekly_Status_Report__c();
        owner = '';
        
        return null;
    }
    
    public PageReference submit()
    {
        statusReport.Status__c = 'Submitted';
        
        User projectManager = [SELECT email FROM User WHERE name = :statusReport.Project_Manager__c];
        User supervisor = [SELECT email FROM User WHERE name = :statusReport.Supervisor__c];
        String emailBody = '';
        String serverURL = System.URL.getSalesforceBaseURL().getHost();
        timePeriod = statusReport.Report_Start_Date__c.format() + ' - ' + statusReport.Report_End_Date__c.format();
        
        emailBody += 'Hello,<br/><br/>';
        emailBody += 'A new report has been submitted by:<br/>' + UserInfo.getName() + '<br/><br/>';
        emailBody += 'This report is located at:<br/><a href=\'' + serverURL + '/' + statusReport.id + '\'>View Report</a><br/><br/>';
        emailBody += 'This report is for the following dates:<br/>' + timePeriod + '<br/><br/>';
        emailBody += 'The project manager for this report is:<br/>' + statusReport.Project_Manager__c + '<br/><br/>';
        emailBody += 'The supervisor for this report is:<br/>' + statusReport.Supervisor__c + '<br/><br/>';
        emailBody += 'Thank you,<br/><br/>' + UserInfo.getName();
        
        //Ikjae: Rhonda requested to turn the email function off
        //GLOBAL_Library.sendEmail(projectManager.email, 'HTML Email Queue', 'CMS Weekly Status Reports', emailBody );
        //GLOBAL_Library.sendEmail(supervisor.email, 'HTML Email Queue', 'CMS Weekly Status Reports', emailBody );
        
        if (std != null)
        {
            std.save();
                          
            calculatePercentage( onGoingTasks );    
            calculatePercentage( projectTasks );
        }
        else
        {
            upsert statusReport;
        }
        
        return new PageReference( '/apex/CMS_WeeklyStatusReportListView' );
    }
    
    
    public List<sObject> clone( List<sObject> prevList, String newRefFieldName, Id newRefID )
    {
        List<sObject> newList = new List<sObject>();
        
        for (sObject prevObj : prevList)
        {
            sObject newObj = prevObj.clone( false );
            
            if (newRefID != null)
            {
                newObj.put( newRefFieldName, newRefID );
            }
            newList.add( newObj );
        }
        
        return newList;
    }
    
    
    public void cleanUpList()
    {
        clean( onGoingTasks );
        clean( projectTasks );
        //clean( upcomingLeaves );
    }
    
    
    public void deleteUpcomingLeave()
    {
        if (null != upcomingNumber)
        {
            Upcoming_Leave__c obj = upcomingLeaves.get( upcomingNumber - 1 );
            upcomingLeaves.remove( upcomingNumber - 1 );
            if ( obj.id != null )
            {
                delete obj;
            }

            upcomingNumber = null;
        }
    }
            
    
    public void clean( List<sObject> listOfObjs )
    {

        for (Integer i = 0; i < listOfObjs.size(); i++)
        {
            String name = (String) listOfObjs[i].get( 'Name' );
            
            if (name == null || name.length() == 0)
            {
                listOfObjs.remove( i );
            }
        }
    }
    
    //Stephanie P.(09/04/14) - moved to Test_CMS_WeeklyStatusReportController
   /* 
    public static testMethod void testCMS_WeeklyStatusReportController()
    {             
        Test.startTest();
        
        CMS_Weekly_Status_Report__c a = new CMS_Weekly_Status_Report__c();
        
        Date todayObj = date.today();
        Date startDate = todayObj.toStartOfWeek();
        Date endDate = startDate.addDays( 6 );
        a.Project_Manager__c = 'Ikjae Park';
        a.Report_Start_Date__c = startDate;
        a.Report_End_Date__c = endDate;
        a.Supervisor__c = 'Rhonda Urbanczyk';
        a.OwnerId = UserInfo.getUserId();
        insert a;
        
        CMS_Weekly_Status_Report__c b = new CMS_Weekly_Status_Report__c();
        
        todayObj = date.today().addDays( -7 );
        startDate = todayObj.toStartOfWeek();
        endDate = startDate.addDays( 6 );
        b.Project_Manager__c = 'Ikjae Park';
        b.Report_Start_Date__c = startDate;
        b.Report_End_Date__c = endDate;
        b.Supervisor__c = 'Rhonda Urbanczyk';
        b.OwnerId = UserInfo.getUserId();
        
        Ongoing_Tasks__c otc = new Ongoing_Tasks__c();
        otc.Child__c = a.id;
        otc.Hours__c = 8;
        otc.Name = 'test';
        insert otc;
        
        Project_Tasks__c ptc = new Project_Tasks__c();
        ptc.Child__c = a.id;
        ptc.Hours__c = 8;
        ptc.Name = 'test';
        insert ptc;
        
        Miscellaneous_Tasks__c mtc = new Miscellaneous_Tasks__c();
        mtc.Child__c = a.id;
        mtc.Hours__c = 8;
        mtc.Name = 'test';
        insert mtc;
        
        Key_Task_Planned_for_Next_Period2__c ktpnp = new Key_Task_Planned_for_Next_Period2__c();
        ktpnp.Child__c = a.id;
        ktpnp.Name = 'test';
        insert ktpnp;
        
        Upcoming_Leave__c ulc = new Upcoming_Leave__c();
        ulc.Child__c = a.id;
        insert ulc;
		
        ApexPages.StandardController sc = new ApexPages.StandardController( a );
        
        CMS_WeeklyStatusReportController csrc1 = new CMS_WeeklyStatusReportController();
        CMS_WeeklyStatusReportController csrc2 = new CMS_WeeklyStatusReportController( sc );
        
        User u3 = [SELECT Id, name FROM User WHERE name like 'Integrator Functional%' LIMIT 1];
        
        // Testing Project Manager
      PermissionSet ps = [SELECT ID From PermissionSet WHERE Label = 'CMS Project Manager'];
      PermissionSetAssignment PSAssignment = new PermissionSetAssignment(AssigneeId = u3.id, PermissionSetId = ps.ID );
        insert( PSAssignment );
        
        
        System.RunAs( u3 )
      {
          csrc1.filter.Project_Manager__c ='Ikjae Park';
          csrc1.filter.Supervisor__c = 'Rhonda Urbanczyk';
          csrc1.Owner = UserInfo.getName();
          
          csrc2.getActiveReports();
          csrc1.getCurrentWeeksReports();
          csrc1.getCompletedReports();
          csrc1.getArchivedReports();
          csrc1.getListOfContracts();
          csrc1.getListOfProjectManagers();
          csrc1.getListOfSupervisors();
          csrc1.getListOfUsers();
          
          csrc2.getUpcomingLeavesList();
          csrc2.getOnGoingTaskList();
          csrc2.getProjectTaskList();
          
          csrc2.save();
          csrc2.submit();
          
          csrc2.getUpcomingLeavesList();
          csrc2.getOnGoingTaskList();
          csrc2.getProjectTaskList();
          
          csrc2.edit();
          csrc2.refresh();
          
          csrc1.resetFilter();
          csrc1.getFunctionalRoles();
      }
    }
*/
}
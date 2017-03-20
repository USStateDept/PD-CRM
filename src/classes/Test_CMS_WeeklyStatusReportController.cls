@isTest
public class Test_CMS_WeeklyStatusReportController {

    public static testMethod void testCMS_WeeklyStatusReportController()
    {             
        Test.startTest();
        
        CMS_Weekly_Status_Report__c a = new CMS_Weekly_Status_Report__c();
        
        Date todayObj = date.today();
        Date startDate = todayObj.toStartOfWeek();
        Date endDate = startDate.addDays( 7 );
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
        
        //Set up a project with miletones details
        CMS_Projects__c project = new CMS_Projects__c();
        startDate = todayObj.toStartOfWeek();
        Date dueDate = startDate.addDays(14);
        project.Name = 'Test Project';
        project.Project_Number__c = 'OM999';
        project.Project_Type__c = 'O&M';
        project.Start_Date__c = startDate;
        project.Due_Date__c = dueDate;
        project.Project_Manager__c = 'Rebecca Jenkins';
        project.Project_Lead__c = '00530000004k5mPAAQ';
        project.Priority__c = 'Medium';
        project.Status__c = 'Active';
        insert project;

        CMS_Milestone__c milestoneDetails = new CMS_Milestone__c();
        dueDate = startDate.addDays(14);
        milestoneDetails.Name = 'Test Support';
        milestoneDetails.Start_Date__c = startDate;
        milestoneDetails.Due_Date__c = dueDate;
        milestoneDetails.Anticipated_Hours__c = 30;
        milestoneDetails.Lead__c = '00530000003mSKFAA2';
        milestoneDetails.CMS_Projects__c = project.Id;
        insert milestoneDetails;
        
        CMS_Milestone_Task__c milestoneTask = new CMS_Milestone_Task__c();
        Date milestoneTaskDueDate = startDate.addDays(7);
        milestoneTask.Name = 'test task1';
        milestoneTask.Functional_Roles__c = 'Support';
        milestoneTask.Start_Date__c = startDate;
        milestoneTask.Due_Date__c = milestoneTaskDueDate;
        milestoneTask.Anticipated_Hours__c = 30;
        milestoneTask.Assigned_Users__c = UserInfo.getName();
        milestoneTask.CMS_Milestone__c = milestoneDetails.Id;
        insert milestoneTask;
        
        Project_Tasks__c ptc = new Project_Tasks__c();
        ptc.Child__c = a.id;
        ptc.Hours__c = 8;
        ptc.Name = 'test task1';
        ptc.Project_Numbers__c = 'Test Project';
        ptc.Functional_Roles__c = 'Support';
        ptc.Start_Date__c = startDate;
        ptc.Due_Date__c = milestoneTaskDueDate;
        ptc.Hours__c = 10;
        ptc.Percentage_Complete__c = 25;
        ptc.O_M__c = true;
        ptc.Active__c = true;
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

        ApexPages.StandardController sc2 = new ApexPages.StandardController( a );
        
        CMS_WeeklyStatusReportController csrc1 = new CMS_WeeklyStatusReportController();
        CMS_WeeklyStatusReportController csrc2 = new CMS_WeeklyStatusReportController( sc2 );
        
        User u3 = [SELECT Id, name FROM User WHERE name like 'Integrator Functional%' LIMIT 1];
        
        // Testing Project Manager
        PermissionSet ps = [SELECT ID From PermissionSet WHERE Label = 'CMS Project Manager'];
        
        /*PermissionSetAssignment PSAssignment = new PermissionSetAssignment(AssigneeId = u3.id, PermissionSetId = ps.ID );
        System.runAs(u3)
        {
            insert( PSAssignment );
        }
        */
        PermissionSetAssignment PSAssignment;
        List<PermissionSetAssignment> psaList = [SELECT Id,PermissionSetId FROM PermissionSetAssignment WHERE PermissionSetId = :ps.ID AND AssigneeId = :u3.id];
        if(psaList != null && psaList.size() > 0)
        {
          PSAssignment = psaList.get(0);    
        }
        else
        {   
            PSAssignment = new PermissionSetAssignment(AssigneeId = u3.id, PermissionSetId = ps.ID );
            System.runAs(u3)
            {
                insert( PSAssignment );
            }  
        }
        
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
        Test.stopTest();
    }
    
    public static testMethod void testCMSBasic_GetCompletedReports() {
        Test.startTest();

        CMS_Weekly_Status_Report__c a = new CMS_Weekly_Status_Report__c();
        
        Date dateObj = Date.today();
        Date startDate = dateObj.toStartOfWeek();
        Date endDate = startDate.addDays( 5 );
        a.Project_Manager__c = 'Peter Jarrell';
        a.Report_Start_Date__c = startDate;
        a.Report_End_Date__c = endDate;
        a.Supervisor__c = 'Chris Palamara';
        a.OwnerId = UserInfo.getUserId();
        a.Status__c = 'Submitted';
        insert a;
        
        CMS_Projects__c project = new CMS_Projects__c();
        Date dueDate = startDate.addDays(8);
        project.Name = 'Test';
        project.Project_Number__c = 'TestOM123';
        project.Project_Type__c = 'O&M';
        project.Start_Date__c = startDate;
        project.Due_Date__c = dueDate;
        project.Project_Lead__c = userInfo.getUserId();
        project.Status__c = 'Completed';
        insert project;
        
        Project_Tasks__c ptc = new Project_Tasks__c();
        ptc.Child__c = a.id;
        ptc.Hours__c = 35;
        ptc.Name = 'Test OM';
        ptc.Project_Numbers__c = 'Test';
        ptc.Completed_Date__c = dueDate;
        ptc.Percentage_Complete__c = 100;
        insert ptc;
        
        CMS_Milestone__c milestone1 = new CMS_Milestone__c();
        milestone1.Name = 'test om task1';
        milestone1.Start_Date__c = startDate;
        milestone1.Due_Date__c = startDate.addDays(5);
        milestone1.Lead__c = userInfo.getUserId();
        milestone1.CMS_Projects__c = project.Id;
        insert milestone1;
        
        ApexPages.StandardController sc = new ApexPages.StandardController( a );
        
        CMS_WeeklyStatusReportController csrc1 = new CMS_WeeklyStatusReportController(sc);
        
        csrc1.filter = a;
        
        csrc1.userID = UserInfo.getUserId();
        
        List<CMS_Weekly_Status_Report__c> completedReports = csrc1.getCompletedReports();
        System.assertEquals(1, completedReports.size());
        csrc1.resetFilter();
        
        Test.stopTest();
    }
    
    public static testMethod void testCMSBasic_GetArchiveReports() {
        Test.startTest();

        CMS_Weekly_Status_Report__c a = new CMS_Weekly_Status_Report__c();
        
        Date dateObj = Date.today();
        Date startDate = dateObj.toStartOfWeek();
        Date endDate = startDate.addDays( 5 );
        a.Project_Manager__c = 'Peter Jarrell';
        a.Report_Start_Date__c = startDate;
        a.Report_End_Date__c = endDate;
        a.Supervisor__c = 'Chris Palamara';
        a.OwnerId = UserInfo.getUserId();
        a.Status__c = 'Archived';
        insert a;
        
        CMS_Projects__c project = new CMS_Projects__c();
        Date dueDate = startDate.addDays(8);
        project.Name = 'Test';
        project.Project_Number__c = 'Test123';
        project.Project_Type__c = 'Project';
        project.Start_Date__c = startDate;
        project.Due_Date__c = dueDate;
        project.Project_Lead__c = '00530000004k5mPAAQ';
        insert project;
        
        Project_Tasks__c ptc = new Project_Tasks__c();
        ptc.Child__c = a.id;
        ptc.Hours__c = 40;
        ptc.Name = 'test project';
        ptc.Project_Numbers__c = 'Test';
        insert ptc;
        
        CMS_Milestone__c milestone1 = new CMS_Milestone__c();
        milestone1.Name = 'test project task1';
        milestone1.Start_Date__c = startDate;
        milestone1.Due_Date__c = startDate.addDays(5);
        milestone1.Lead__c = '00530000004k5mPAAQ';
        milestone1.CMS_Projects__c = project.Id;
        insert milestone1;
        
        CMS_WeeklyStatusReportController csrc1 = new CMS_WeeklyStatusReportController();
        
        csrc1.filter.Project_Manager__c = 'Peter Jarrell';
        csrc1.filter.Supervisor__c = 'Chris Palamara';
        
        csrc1.userID = UserInfo.getUserId();
        csrc1.myPermissionset = 'CMS Basic';
        List<CMS_Weekly_Status_Report__c> archivedReports = csrc1.getArchivedReports();
        System.assertEquals(1, archivedReports.size());
        csrc1.resetFilter();
        
        Test.stopTest();
    }
    
    public static testMethod void testGetKeyTaskList() {
        test.startTest();
        CMS_Weekly_Status_Report__c a = new CMS_Weekly_Status_Report__c();
        
        Date dateObj = Date.today();
        Date startDate = dateObj.toStartOfWeek();
        Date endDate = startDate.addDays( 5 );
        a.Project_Manager__c = 'Peter Jarrell';
        a.Report_Start_Date__c = startDate;
        a.Report_End_Date__c = endDate;
        a.Supervisor__c = 'Chris Palamara';
        a.OwnerId = UserInfo.getUserId();
        a.Status__c = 'Archived';
        insert a;
        
        CMS_Projects__c project = new CMS_Projects__c();
        Date dueDate = startDate.addDays(8);
        project.Name = 'Test';
        project.Project_Number__c = 'Test123';
        project.Project_Type__c = 'Project';
        project.Start_Date__c = startDate;
        project.Due_Date__c = dueDate;
        project.Project_Lead__c = userInfo.getUserId();
        insert project;
        
        Project_Tasks__c ptc = new Project_Tasks__c();
        ptc.Child__c = a.id;
        ptc.Hours__c = 40;
        ptc.Name = 'Test Project';
        ptc.Project_Numbers__c = 'Test';
        insert ptc;
        
        CMS_Milestone__c milestone1 = new CMS_Milestone__c();
        milestone1.Name = 'Milestone1';
        milestone1.Start_Date__c = startDate;
        milestone1.Due_Date__c = startDate.addDays(2);
        milestone1.Lead__c = userInfo.getUserId();
        milestone1.CMS_Projects__c = project.Id;
        insert milestone1;
        
        CMS_Milestone__c milestone2 = new CMS_Milestone__c();
        milestone2.Name = 'Milestone2';
        milestone2.Start_Date__c = startDate.addDays(3);
        milestone2.Due_Date__c = startDate.addDays(9);
        milestone2.Lead__c = userInfo.getUserId();
        milestone2.CMS_Projects__c = project.Id;
        insert milestone2;
            
        CMS_WeeklyStatusReportController csrc1 = new CMS_WeeklyStatusReportController();
        csrc1.statusReport = a;
        List<Project_Tasks__c> tasks = csrc1.getKeyTaskList();
        
        test.stopTest();
    }
    
    public static testMethod void testNewUpcomingLeave() {
        Test.startTest();
        
        CMS_Weekly_Status_Report__c a = new CMS_Weekly_Status_Report__c();
        
        Date todayObj = date.today();
        Date startDate = todayObj.toStartOfWeek();
        Date endDate = startDate.addDays( 6 );
        a.Project_Manager__c = 'Peter Jarrell';
        a.Report_Start_Date__c = startDate;
        a.Report_End_Date__c = endDate;
        a.Supervisor__c = 'Chris Palamara';
        a.OwnerId = UserInfo.getUserId();
        insert a;
        
        CMS_Projects__c project = new CMS_Projects__c();
        project.Name = 'Test Project';
        project.Project_Number__c = 'project999';
        project.Project_Type__c = 'Project';
        project.Start_Date__c = startDate;
        project.Due_Date__c = endDate;
        project.Project_Lead__c = userInfo.getUserId();
        insert project;
        
        CMS_Projects__c ongoingProject = new CMS_Projects__c();
        ongoingProject.Name = 'Test Ongoing';
        ongoingProject.Project_Number__c = 'OM999';
        ongoingProject.Project_Type__c = 'O&M';
        ongoingProject.Start_Date__c = startDate;
        project.Due_Date__c = endDate;
        ongoingProject.Project_Lead__c = userInfo.getUserId();
        insert ongoingProject;
        
        Project_Tasks__c ptc = new Project_Tasks__c();
        ptc.Child__c = a.id;
        ptc.Hours__c = 8;
        ptc.Name = 'Test_Project_Task1';
        ptc.Project_Numbers__c = 'Test Project';
        insert ptc;

        Project_Tasks__c ongoing = new Project_Tasks__c();
        ongoing.Child__c = a.id;
        ongoing.Hours__c = 8;
        ongoing.Name = 'Test_O&M_Task1';
        ongoing.Project_Numbers__c = 'Test Ongoing'; 
        insert ongoing;
        
        CMS_Milestone__c milestone1 = new CMS_Milestone__c();
        milestone1.Name = 'Task_1';
        milestone1.Start_Date__c = startDate;
        milestone1.Due_Date__c = endDate;
        milestone1.Lead__c = userInfo.getUserId();
        milestone1.CMS_Projects__c = project.Id;
        insert milestone1;
        
        CMS_Milestone__c milestone2 = new CMS_Milestone__c();
        milestone2.Name = 'Task_2';
        milestone2.Start_Date__c = startDate;
        milestone2.Due_Date__c = endDate;
        milestone2.Lead__c = userInfo.getUserId();
        milestone2.CMS_Projects__c = ongoingProject.Id;
        insert milestone2;
        
        List<Project_Tasks__c> projectTasks = new List<Project_Tasks__c>();
        projectTasks.add(ptc);
        List<Project_Tasks__c> ongoingTasks = new List<Project_Tasks__c>();
        ongoingTasks.add(ongoing);
        
        CMS_WeeklyStatusReportController csrc1 = new CMS_WeeklyStatusReportController();
        csrc1.projectTasks = projectTasks;
        csrc1.onGoingTasks = onGoingTasks;
        csrc1.upcomingLeaves = new List<Upcoming_Leave__c>();
        
        csrc1.newUpComingLeave();   
        
        Test.stopTest();
    }
    
    public static testMethod void testDeleteUpcomingLeave() {
        Test.startTest();
        
        CMS_Weekly_Status_Report__c a = new CMS_Weekly_Status_Report__c();
        
        Date dateObj = Date.today();
        Date startDate = dateObj.toStartOfWeek();
        Date endDate = startDate.addDays( 5 );
        a.Project_Manager__c = 'Peter Jarrell';
        a.Report_Start_Date__c = startDate;
        a.Report_End_Date__c = endDate;
        a.Supervisor__c = 'Chris Palamara';
        a.OwnerId = UserInfo.getUserId();
        a.Status__c = 'Archived';
        insert a;
        
        Upcoming_Leave__c leave = new Upcoming_Leave__c();
        leave.Start_Date__c = dateObj.addDays(7);
        leave.End_Date__c = dateObj.addDays(7);
        leave.Types_of_Leave__c = 'Personal';
        leave.Child__c = a.Id;
        insert leave;
        
        List<Upcoming_Leave__c> leavesList = new List<Upcoming_Leave__c>();
        leavesList.add(leave);
        
        ApexPages.StandardController sc = new ApexPages.StandardController( a );
        
        CMS_WeeklyStatusReportController csrc1 = new CMS_WeeklyStatusReportController(sc);
        csrc1.upcomingNumber = 1;
        csrc1.upcomingLeaves = leavesList;
        csrc1.statusReport = a;
        
        csrc1.deleteUpcomingLeave();
        
        List<Upcoming_Leave__c> upcomingLeave = csrc1.getUpcomingLeavesList();
        System.assertEquals(0, 0);
        Test.stopTest();
    }
    
    public static testMethod void testCalculatePercentage() {
        Test.startTest();
        
        CMS_Weekly_Status_Report__c a = new CMS_Weekly_Status_Report__c();
        
        Date startDate1 = Date.newInstance(2014, 8, 25);
        Date endDate1 = Date.newInstance(2014, 8, 27);
        a.Project_Manager__c = 'Peter Jarrell';
        a.Report_Start_Date__c = startDate1;
        a.Report_End_Date__c = endDate1;
        a.Supervisor__c = 'Chris Palamara';
        a.Status__c = 'Submitted';
        a.OwnerId = UserInfo.getUserId();
        insert a;
        
        CMS_Weekly_Status_Report__c b = new CMS_Weekly_Status_Report__c();
        
        Date startDate2 = Date.newInstance(2014, 8, 28);
        Date endDate2 = Date.newInstance(2014, 8, 29);
        b.Project_Manager__c = 'Peter Jarrell';
        b.Report_Start_Date__c = startDate2;
        b.Report_End_Date__c = endDate2;
        b.Supervisor__c = 'Chris Palamara';
        b.Status__c = 'Submitted';
        b.OwnerId = UserInfo.getUserId();
        insert b;

        CMS_Projects__c project = new CMS_Projects__c();
        project.Name = 'Customer Service Support';
        project.Project_Number__c = 'OM999';
        project.Project_Type__c = 'O&M';
        project.Start_Date__c = startDate1;
        project.Due_Date__c = endDate2;
        project.Completed_Date__c = endDate2;
        project.Status__c = 'Completed';
        project.Project_Lead__c = userInfo.getUserId();
        insert project;
        
        Project_Tasks__c task1 = new Project_Tasks__c();
        task1.Project_Numbers__c = 'Customer Service Support';
        task1.Completed_Date__c = endDate1;
        task1.Child__c = a.id;
        task1.Hours__c = 40;
        task1.Percentage_Complete__c = 100;
        task1.Name = 'Task_1';
        insert task1;
        
        Project_Tasks__c task2 = new Project_Tasks__c();
        task2.Project_Numbers__c = 'Customer Service Support';
        task2.Completed_Date__c = endDate2;
        task2.Child__c = b.id;
        task2.Hours__c = 24;
        task2.Percentage_Complete__c = 100;
        task2.Name = 'Task_2';
        insert task2;        
        
        CMS_Milestone__c milestone1 = new CMS_Milestone__c();
        milestone1.Name = 'Task_1';
        milestone1.Start_Date__c = startDate1;
        milestone1.Due_Date__c = endDate1;
        milestone1.Lead__c = userInfo.getUserId();
        milestone1.CMS_Projects__c = project.Id;
        insert milestone1;
        
        CMS_Milestone__c milestone2 = new CMS_Milestone__c();
        milestone2.Name = 'Task_2';
        milestone2.Start_Date__c = startDate2;
        milestone2.Due_Date__c = endDate2;
        milestone2.Lead__c = userInfo.getUserId();
        milestone2.CMS_Projects__c = project.Id;
        insert milestone2;
        
        List<Project_Tasks__c> tasksList = new List<Project_Tasks__c>();
        tasksList.add(task1);
        tasksList.add(task2);
        
        ApexPages.StandardController sc = new ApexPages.StandardController( a );
        
        CMS_WeeklyStatusReportController csrc1 = new CMS_WeeklyStatusReportController(sc);
        csrc1.filter = a;
            
        csrc1.Owner = UserInfo.getName();
        
        List<CMS_Weekly_Status_Report__c> reports = csrc1.getCompletedReports();
        System.assertEquals(2, reports.size());
        
        csrc1.calculatePercentage(tasksList);   
        
        csrc1.resetFilter();
        
        Test.stopTest();
    }
    
    public static testMethod void testGetProjectNumbers() {
        Test.startTest();
        
        CMS_WeeklyStatusReportController csrc1 = new CMS_WeeklyStatusReportController();
        csrc1.getProjectNumbers();
        
        Test.stopTest();
    }
    
    public static testMethod void testGetPrevOnGoingTasks() {
        Test.startTest();
        
        CMS_Weekly_Status_Report__c a = new CMS_Weekly_Status_Report__c();
        
        Date todayObj = Date.today();
        Date startDate = todayObj.toStartOfWeek();
        startDate = startDate.addDays(-7);
        Date endDate = startDate.addDays(6);
        a.Project_Manager__c = 'Peter Jarrell';
        a.Report_Start_Date__c = startDate;
        a.Report_End_Date__c = endDate;
        a.Supervisor__c = 'Chris Palamara';
        a.Status__c = 'Submitted';
        a.OwnerId = UserInfo.getUserId();
        insert a;

        CMS_Weekly_Status_Report__c b = new CMS_Weekly_Status_Report__c();
        
        Date currentDate = date.today();
        Date currentStartDate = currentDate.toStartOfWeek();
        Date currentEndDate = currentStartDate.addDays( 6 );
        b.Project_Manager__c = 'Peter Jarrell';
        b.Report_Start_Date__c = currentStartDate;
        b.Report_End_Date__c = currentEndDate;
        b.Supervisor__c = 'Chris Palamara';
        b.Status__c = 'Open';
        b.OwnerId = UserInfo.getUserId();
        
        //Set up a project with miletones details
        CMS_Projects__c project = new CMS_Projects__c();
        Date dueDate = startDate.addDays(14);
        project.Name = 'Test AMS Enhancement';
        project.Project_Number__c = 'P999';
        project.Project_Type__c = 'Project';
        project.Start_Date__c = startDate;
        project.Due_Date__c = dueDate;
        project.Project_Manager__c = 'Rebecca Jenkins';
        project.Project_Lead__c = '00530000004k5mPAAQ';
        project.Priority__c = 'Medium';
        project.Status__c = 'Active';
        insert project;

        CMS_Milestone__c milestone = new CMS_Milestone__c();
        dueDate = startDate.addDays(14);
        milestone.Name = 'Test Development';
        milestone.Start_Date__c = startDate;
        milestone.Due_Date__c = dueDate;
        milestone.Anticipated_Hours__c = 30;
        milestone.Lead__c = '00530000003mSKFAA2';
        milestone.CMS_Projects__c = project.Id;
        insert milestone;
        
        CMS_Milestone_Task__c milestoneTask = new CMS_Milestone_Task__c();
        Date milestoneTaskDueDate = startDate.addDays(7);
        milestoneTask.Name = 'test task1';
        milestoneTask.Functional_Roles__c = 'Development';
        milestoneTask.Start_Date__c = startDate;
        milestoneTask.Due_Date__c = milestoneTaskDueDate;
        milestoneTask.Anticipated_Hours__c = 30;
        milestoneTask.Assigned_Users__c = UserInfo.getName();
        milestoneTask.CMS_Milestone__c = milestone.Id;
        insert milestoneTask;

        Project_Tasks__c ptc = new Project_Tasks__c();
        ptc.Child__c = a.id;
        ptc.Hours__c = 8;
        ptc.Name = 'test task1';
        ptc.Project_Numbers__c = 'Test AMS Enhancement';
        ptc.Functional_Roles__c = 'Development';
        ptc.Start_Date__c = startDate;
        ptc.Due_Date__c = milestoneTaskDueDate;
        ptc.Hours__c = 10;
        ptc.Percentage_Complete__c = 25;
        ptc.O_M__c = false;
        ptc.Active__c = true;
        insert ptc;
        
        //Set up ongoing project
        CMS_Projects__c ongoingProject = new CMS_Projects__c();
        dueDate = startDate.addDays(14);
        ongoingProject.Name = 'Test Support';
        ongoingProject.Project_Number__c = 'OM:999';
        ongoingProject.Project_Type__c = 'O&M';
        ongoingProject.Start_Date__c = startDate;
        ongoingProject.Due_Date__c = dueDate;
        ongoingProject.Project_Manager__c = 'Rebecca Jenkins';
        ongoingProject.Project_Lead__c = '00530000004k5mPAAQ';
        ongoingProject.Priority__c = 'Low';
        ongoingProject.Status__c = 'Active';
        insert ongoingProject;

        CMS_Milestone__c onGoingMilestoneDetails = new CMS_Milestone__c();
        dueDate = startDate.addDays(14);
        onGoingMilestoneDetails.Name = 'Test Customer Support';
        onGoingMilestoneDetails.Start_Date__c = startDate;
        onGoingMilestoneDetails.Due_Date__c = dueDate;
        onGoingMilestoneDetails.Anticipated_Hours__c = 30;
        onGoingMilestoneDetails.Lead__c = '00530000003mSKFAA2';
        onGoingMilestoneDetails.CMS_Projects__c = ongoingProject.Id;
        insert onGoingMilestoneDetails;
        
        CMS_Milestone_Task__c onGoingMilestoneTask = new CMS_Milestone_Task__c();
        milestoneTaskDueDate = startDate.addDays(5);
        onGoingMilestoneTask.Name = 'test task2';
        onGoingMilestoneTask.Functional_Roles__c = 'Support';
        onGoingMilestoneTask.Start_Date__c = startDate;
        onGoingMilestoneTask.Due_Date__c = milestoneTaskDueDate;
        onGoingMilestoneTask.Anticipated_Hours__c = 20;
        onGoingMilestoneTask.Assigned_Users__c = UserInfo.getName();
        onGoingMilestoneTask.CMS_Milestone__c = onGoingMilestoneDetails.Id;
        insert onGoingMilestoneTask;      
        
        onGoingMilestoneTask = new CMS_Milestone_Task__c();
        milestoneTaskDueDate = startDate.addDays(6);
        onGoingMilestoneTask.Name = 'test task3';
        onGoingMilestoneTask.Functional_Roles__c = 'Reporting';
        onGoingMilestoneTask.Start_Date__c = startDate;
        onGoingMilestoneTask.Due_Date__c = milestoneTaskDueDate;
        onGoingMilestoneTask.Anticipated_Hours__c = 20;
        onGoingMilestoneTask.Assigned_Users__c = UserInfo.getName();
        onGoingMilestoneTask.CMS_Milestone__c = onGoingMilestoneDetails.Id;
        insert onGoingMilestoneTask;  
        
        Project_Tasks__c ongoingPtc = new Project_Tasks__c();
        ongoingPtc.Child__c = a.id;
        ongoingPtc.Hours__c = 8;
        ongoingPtc.Name = 'test task2';
        ongoingPtc.Project_Numbers__c = 'Test Support';
        ongoingPtc.Functional_Roles__c = 'Support';
        ongoingPtc.Start_Date__c = startDate.addDays(5);
        ongoingPtc.Due_Date__c = milestoneTaskDueDate;
        ongoingPtc.Hours__c = 20;
        ongoingPtc.Percentage_Complete__c = 50;
        ongoingPtc.O_M__c = true;
        ongoingPtc.Active__c = true;
        insert ongoingPtc;
                     
        ongoingPtc = new Project_Tasks__c();
        ongoingPtc.Child__c = a.id;
        ongoingPtc.Hours__c = 8;
        ongoingPtc.Name = 'test task3';
        ongoingPtc.Project_Numbers__c = 'Test Support';
        ongoingPtc.Functional_Roles__c = 'Reporting';
        ongoingPtc.Start_Date__c = startDate.addDays(6);
        ongoingPtc.Due_Date__c = milestoneTaskDueDate;
        ongoingPtc.Hours__c = 10;
        ongoingPtc.Percentage_Complete__c = 50;
        ongoingPtc.O_M__c = true;
        ongoingPtc.Active__c = true;
        insert ongoingPtc;
        
        ApexPages.StandardController sc = new ApexPages.StandardController( b );
        CMS_WeeklyStatusReportController csrc1 = new CMS_WeeklyStatusReportController(sc);
        csrc1.filter = b;
        csrc1.Owner = UserInfo.getName();

        List<String> projectNames = csrc1.projectNames;
        List<Map<String,Date>> projectTaskMapsList = csrc1.projectTaskDuedateMapsList;

        List<Project_Tasks__c> prevOnGoingTasks = csrc1.getPrevOnGoingTasks(null, projectNames, projectTaskMapsList);
        System.assertEquals(2, prevOnGoingTasks.size());
        
        Test.stopTest();
    }
    
    public static testMethod void testGetPrevProjectTasks() {
        Test.startTest();
        
        CMS_Weekly_Status_Report__c a = new CMS_Weekly_Status_Report__c();
        
        Date todayObj = Date.today();
        Date startDate = todayObj.toStartOfWeek();
        startDate = startDate.addDays(-7);
        Date endDate = startDate.addDays(6);
        a.Project_Manager__c = 'Peter Jarrell';
        a.Report_Start_Date__c = startDate;
        a.Report_End_Date__c = endDate;
        a.Supervisor__c = 'Chris Palamara';
        a.Status__c = 'Submitted';
        a.OwnerId = UserInfo.getUserId();
        insert a;

        CMS_Weekly_Status_Report__c b = new CMS_Weekly_Status_Report__c();
        
        Date currentDate = date.today();
        Date currentStartDate = currentDate.toStartOfWeek();
        Date currentEndDate = currentStartDate.addDays( 6 );
        b.Project_Manager__c = 'Peter Jarrell';
        b.Report_Start_Date__c = currentStartDate;
        b.Report_End_Date__c = currentEndDate;
        b.Supervisor__c = 'Chris Palamara';
        b.Status__c = 'Open';
        b.OwnerId = UserInfo.getUserId();
        
        //Set up a project with miletones details
        CMS_Projects__c project = new CMS_Projects__c();
        Date dueDate = startDate.addDays(14);
        project.Name = 'Test AMS Enhancement';
        project.Project_Number__c = 'P999';
        project.Project_Type__c = 'Project';
        project.Start_Date__c = startDate;
        project.Due_Date__c = dueDate;
        project.Project_Manager__c = 'Rebecca Jenkins';
        project.Project_Lead__c = '00530000004k5mPAAQ';
        project.Priority__c = 'Medium';
        project.Status__c = 'Active';
        insert project;

        CMS_Milestone__c milestone = new CMS_Milestone__c();
        dueDate = startDate.addDays(14);
        milestone.Name = 'Test Development';
        milestone.Start_Date__c = startDate;
        milestone.Due_Date__c = dueDate;
        milestone.Anticipated_Hours__c = 30;
        milestone.Lead__c = '00530000003mSKFAA2';
        milestone.CMS_Projects__c = project.Id;
        insert milestone;
        
        CMS_Milestone_Task__c milestoneTask = new CMS_Milestone_Task__c();
        Date milestoneTaskDueDate = startDate.addDays(7);
        milestoneTask.Name = 'test task1';
        milestoneTask.Functional_Roles__c = 'Development';
        milestoneTask.Start_Date__c = startDate;
        milestoneTask.Due_Date__c = milestoneTaskDueDate;
        milestoneTask.Anticipated_Hours__c = 30;
        milestoneTask.Assigned_Users__c = UserInfo.getName();
        milestoneTask.CMS_Milestone__c = milestone.Id;
        insert milestoneTask;

        Project_Tasks__c ptc = new Project_Tasks__c();
        ptc.Child__c = a.id;
        ptc.Hours__c = 8;
        ptc.Name = 'test task1';
        ptc.Project_Numbers__c = 'Test AMS Enhancement';
        ptc.Functional_Roles__c = 'Development';
        ptc.Start_Date__c = startDate;
        ptc.Due_Date__c = milestoneTaskDueDate;
        ptc.Hours__c = 10;
        ptc.Percentage_Complete__c = 25;
        ptc.O_M__c = false;
        ptc.Active__c = true;
        insert ptc;
        
        //Set up service request project
        CMS_Projects__c serviceReqProject = new CMS_Projects__c();
        dueDate = startDate.addDays(10);
        serviceReqProject.Name = 'Test Risk Management';
        serviceReqProject.Project_Number__c = 'SR999';
        serviceReqProject.Project_Type__c = 'Service Request';
        serviceReqProject.Start_Date__c = startDate;
        serviceReqProject.Due_Date__c = dueDate;
        serviceReqProject.Project_Manager__c = 'Rebecca Jenkins';
        serviceReqProject.Project_Lead__c = '00530000004k5mPAAQ';
        serviceReqProject.Priority__c = 'Medium';
        serviceReqProject.Status__c = 'Active';
        insert serviceReqProject;

        CMS_Milestone__c serviceReqMilestoneDetails = new CMS_Milestone__c();
        dueDate = startDate.addDays(3);
        serviceReqMilestoneDetails.Name = 'Form Development';
        serviceReqMilestoneDetails.Start_Date__c = startDate;
        serviceReqMilestoneDetails.Due_Date__c = dueDate;
        serviceReqMilestoneDetails.Anticipated_Hours__c = 24;
        serviceReqMilestoneDetails.Lead__c = '00530000003mSKFAA2';
        serviceReqMilestoneDetails.CMS_Projects__c = serviceReqProject.Id;
        insert serviceReqMilestoneDetails;
        
        CMS_Milestone_Task__c serviceReqMilestoneTask = new CMS_Milestone_Task__c();
        milestoneTaskDueDate = startDate.addDays(3);
        serviceReqMilestoneTask.Name = 'test task2';
        serviceReqMilestoneTask.Functional_Roles__c = 'Development';
        serviceReqMilestoneTask.Start_Date__c = startDate;
        serviceReqMilestoneTask.Due_Date__c = milestoneTaskDueDate;
        serviceReqMilestoneTask.Anticipated_Hours__c = 24;
        serviceReqMilestoneTask.Assigned_Users__c = UserInfo.getName();
        serviceReqMilestoneTask.CMS_Milestone__c = serviceReqMilestoneDetails.Id;
        insert serviceReqMilestoneTask;        

        Project_Tasks__c serviceReqPtc = new Project_Tasks__c();
        serviceReqPtc.Child__c = a.id;
        serviceReqPtc.Hours__c = 8;
        serviceReqPtc.Name = 'test task2';
        serviceReqPtc.Project_Numbers__c = 'Test Risk Management';
        serviceReqPtc.Functional_Roles__c = 'Development';
        serviceReqPtc.Start_Date__c = startDate;
        serviceReqPtc.Due_Date__c = milestoneTaskDueDate;
        serviceReqPtc.Hours__c = 20;
        serviceReqPtc.Percentage_Complete__c = 0;
        serviceReqPtc.O_M__c = false;
        serviceReqPtc.Active__c = true;
        insert serviceReqPtc;
                     
        ApexPages.StandardController sc = new ApexPages.StandardController( b );
        CMS_WeeklyStatusReportController csrc1 = new CMS_WeeklyStatusReportController(sc);
        csrc1.filter = b;
        csrc1.Owner = UserInfo.getName();

        List<String> projectNames = csrc1.projectNames;
        List<Map<String,Date>> projectTaskMapsList = csrc1.projectTaskDuedateMapsList;

        List<Project_Tasks__c> prevProjectTasks = csrc1.getPrevProjectTasks(null, projectNames, projectTaskMapsList);
        System.assertEquals(2, prevProjectTasks.size());
        
        Test.stopTest();
    }
}
public class CMS_ProjectController
{
    private ApexPages.StandardController std;
    
    public List<CMS_Projects__c> listOfActiveProjects{ get; set; }
    public List<CMS_Projects__c> listOfHoldProjects{ get; set; }
    public List<CMS_Projects__c> listOfInactiveProjects{ get; set; }
    public List<CMS_Projects__c> listOfOMProjects{ get; set; }
    public List<CMS_Milestone_Task__c> myTasks{ get; set; }
    public List<MilestoneObj> mileStones{ get; set; }
    
    public CMS_Projects__c project{ get; set; }
    public boolean displayTasks{ get; set; }
    public String projectLead{ get; set; }
	public String myPermissionset{ set; get; }
	
	public Integer milestoneNumber{ get; set; }
	
    public CMS_ProjectController()
    {
        if (listOfActiveProjects == null)
        {
            listOfActiveProjects = [SELECT Name, Id, Completed_Date__c, Due_Date__c, Start_Date__c, Project_Manager__c, Project_Number__c, Project_Lead__c, Project_Type__c, Project_Lead__r.name
                                	  FROM CMS_Projects__c
                                	 WHERE status__c != 'Completed' 
                                	   AND status__c != 'On Hold'
                                	   AND (not Project_Number__c like 'OM%')
                            	  ORDER BY start_date__c];
        }
        if (listOfOMProjects == null)
        {
            listOfOMProjects = [SELECT Name, Id, Completed_Date__c, Due_Date__c, Start_Date__c, Project_Manager__c, Project_Number__c, Project_Lead__c, Project_Type__c, Project_Lead__r.name
                                  FROM CMS_Projects__c
                                 WHERE status__c != 'Completed' 
                                   AND status__c != 'On Hold'
                              	   AND Project_Number__c like 'OM%'
                              ORDER BY start_date__c];
        }
        
        
        
        if (listOfInactiveProjects == null)
        {
            listOfInactiveProjects = [SELECT Name, Id, Completed_Date__c, Due_Date__c, Start_Date__c, Project_Manager__c, Project_Number__c, Project_Lead__c, Project_Type__c, Project_Lead__r.name
                                	    FROM CMS_Projects__c 
                                	   WHERE status__c = 'Completed'
                            	    ORDER BY start_date__c];
        }
        
        if (listOfHoldProjects == null)
        {
        	listOfHoldProjects = [SELECT Name, Id, Completed_Date__c, Due_Date__c, Start_Date__c, Project_Manager__c, Project_Number__c, Project_Lead__c, Project_Type__c, Project_Lead__r.name
                                    FROM CMS_Projects__c 
                                   WHERE status__c = 'On Hold'
                            	ORDER BY start_date__c];
        }
        
        if (myTasks == null)
    	{
    		String myName = '%' + UserInfo.getFirstName() + ' ' + UserInfo.getLastName() + '%';
    		myTasks = [SELECT CMS_Milestone__c, Due_Date__c, Start_Date__c, Name, Anticipated_Hours__c, Functional_Roles__c, Assigned_Users__c
                         FROM CMS_Milestone_Task__c 
                        WHERE Assigned_Users__c like :myName];
    	}
    }
    public CMS_ProjectController( ApexPages.StandardController stdCtrl )
    {
        std = stdCtrl;
        
        if (std != null)
        {
            mileStones = new List<MilestoneObj>();
            project = (CMS_Projects__c) std.getRecord();
            
            if (project.id == null)
            {
                displayTasks= false;
            }
            else
            {
                displayTasks= true;
                
                projectLead = project.Project_Lead__r.name;

                for(CMS_Milestone__c milestone : [SELECT Due_Date__c, Name, Id, Start_Date__c, Lead__c, Lead__r.name, Anticipated_Hours__c FROM CMS_Milestone__c WHERE CMS_Projects__c = :project.id])
                {
                    MilestoneObj obj= new MilestoneObj();
                    obj.milestone = milestone;
                    obj.lead = milestone.Lead__r.name;

                    mileStones.add( obj );
                }
            }
        }
    }
    
    
    public PageReference remove()
    {
        delete project;
        return new PageReference( '/apex/CMS_ManageProjects' );
    }
    
    
    public void deleteMilestone()
    {

        if (null != milestoneNumber)
        {
            MilestoneObj mileStoneObj = mileStones.get( milestoneNumber - 1 );
            
            if ( mileStoneObj.milestone.id != null )
            {
            	mileStones.remove( milestoneNumber - 1 );
            	delete mileStoneObj.milestone;
            }
            else
            {
                mileStones.remove( milestoneNumber - 1 );
            }

            milestoneNumber = null;
        }
    }
    
    
    public PageReference save()
    {
        if (project.Due_Date__c < project.Start_Date__c)
        {
            ApexPages.addMessage(new ApexPages.Message( ApexPages.Severity.ERROR, 'Due date must be greater than Start date.' ));
        }
        else
        {
            try
            {
                User myUser = [SELECT id, email FROM User WHERE name = :projectLead];
                
                if (project.Project_Lead__c != myUser.ID)
                {
                	Id prevOwnerID = project.Project_Lead__c;
                	
	            	project.Project_Lead__c = myUser.ID;
	                displayTasks = true;
	                std.save();
	                
	                project = (CMS_Projects__c) std.getRecord();
	                
	                if (prevOwnerID != null)
	                {
	                	User prevUser = [SELECT id, email FROM User WHERE id = :prevOwnerID];
	            
	                	//CMS_Library.deactivateTask( prevUser, project.name, 'Management', 'Project Maintainance - ' + project.name, project.Start_Date__c, project.Due_Date__c );
	                }
                }
				GLOBAL_Library.sendEmail( myUser.email, 'HTML Email Queue', 'Project ' + project.name + 
			    	                  ' has been assigned to you', 'A task has been assigned to you.<br>Please log into the system.' );
                //CMS_Library.processTask( myUser, project.name, 'Management', 'Project Maintainance - ' + project.name, project.Start_Date__c, project.Due_Date__c, false );
            }
            catch (Exception e)
            {
                ApexPages.addMessage(new ApexPages.Message( ApexPages.Severity.ERROR, 'Project Lead does not exist in the database.' ));
            }
        }
        return null;
    }
    
    
    public PageReference saveAll()
    {   
        List<CMS_Milestone__c> objs = new List<CMS_Milestone__c>();
        try
        {
        	User myUser = [SELECT id, email FROM User WHERE name = :projectLead];
        	
            if (project.Project_Lead__c != myUser.ID)
            {
            	Id prevOwnerID = project.Project_Lead__c;
            	
            	project.Project_Lead__c = myUser.ID;
                
                if (prevOwnerID != null)
                {
                	User prevUser = [SELECT id, email FROM User WHERE id = :prevOwnerID];
                	//CMS_Library.deactivateTask( prevUser, project.name, 'Management', 'Project Maintainance - ' + project.name, project.Start_Date__c, project.Due_Date__c );
                }
            }
            GLOBAL_Library.sendEmail( myUser.email, 'HTML Email Queue', 'Project ' + project.name + 
			    	                  ' has been assigned to you', 'A task has been assigned to you.<br>Please log into the system.' );
            //CMS_Library.processTask( myUser, project.name, 'Management', 'Project Maintainance - ' + project.name, project.Start_Date__c, project.Due_Date__c, false );
        }
        catch (Exception e)
        {
            ApexPages.addMessage(new ApexPages.Message( ApexPages.Severity.ERROR, 'Project Lead does not exist in the database.' ));
        }
        for (MilestoneObj obj : mileStones)
        {
            try
            {
                User myUser = [SELECT id, email FROM User WHERE name = :obj.lead];
                
                if (obj.milestone.Lead__C != myUser.ID)
                {
                	Id prevOwnerID = obj.milestone.Lead__c;
                	
	                obj.milestone.Lead__c = myUser.ID;

	                if (prevOwnerID != null)
	                {
	                	User prevUser = [SELECT id, email FROM User WHERE id = :prevOwnerID];
	                	//CMS_Library.deactivateTask( prevUser, project.Name, 'Management', obj.milestone.name, obj.milestone.Start_Date__c, obj.milestone.Due_Date__c );
	                }
                }
                GLOBAL_Library.sendEmail( myUser.email, 'HTML Email Queue', 'Project ' + project.name + 
			    	                  ' has been assigned to you', 'A task has been assigned to you.<br>Please log into the system.' );
                //CMS_Library.processTask( myUser, project.Name, 'Management', obj.milestone.name, obj.milestone.Start_Date__c, obj.milestone.Due_Date__c, true );
            }
            catch (Exception e)
            {
                ApexPages.addMessage(new ApexPages.Message( ApexPages.Severity.ERROR, 'Lead for ' + obj.milestone.name + ' does not exist in the database.'));
                return null;
            }
        
            objs.add( obj.milestone );
        }
        
        std.save();
        upsert objs;

        return new PageReference( '/' + project.id );
    }
   

    public PageReference cancel()
    {
        return new PageReference( '/apex/CMS_ManageProjects' );   
    }
    
    
    public PageReference onHoldAction()
	{
		project.Status__c = 'On Hold';
		std.save();
		return new PageReference( '/apex/CMS_ManageProjects' );   
	}
    
    public PageReference reactivivateAction()
	{
		project.Status__c = 'Active';
		std.save();
		return new PageReference( '/apex/CMS_ManageProjects' );   
	}
    
    public void newMilestone()
    {
        CMS_Milestone__c milestone = new CMS_Milestone__c();
        milestone.CMS_Projects__c = project.id;
        MilestoneObj newObj = new MilestoneObj();
        newObj.milestone = milestone;
        
        if (mileStones.size() > 0)
        {
            mileStones.add( 0, newObj );
        }
        else
        {
            mileStones.add( newObj );
        }
    }
    

    public String getListOfLeads()
    {
/* Service Request 1/16/2014
        return GLOBAL_Library.getPermissionsetUsers( 'CMS Supervisor', 'CMS_Projects__c' ) + ';' + 
               GLOBAL_Library.getPermissionsetUsers( 'CMS Project Manager', 'CMS_Projects__c' ) + ';' +
               GLOBAL_Library.getPermissionsetUsers( 'CMS Lead', 'CMS_Projects__c' )  + ';' +
               GLOBAL_Library.getPermissionsetUsers( 'CMS Basic', 'CMS_Projects__c' );
*/
		return 'Marc Duverneuil;Shannon Knott;John Lancaster;Laura Lynch;Chris Palamara;Rhonda Urbanczyk;James Dickey';
    }
    
    
    public String getProjectManager()
    {
    	return 'Peter Jarrell;Laura Lynch;Chris Palamara;Rhonda Urbanczyk';
    }
    
    public class MilestoneObj
    {
        public CMS_Milestone__c milestone{ get; set; }
        public String lead{ get; set; }
        
        public MilestoneObj()
        {
            milestone = new CMS_Milestone__c();
            lead = '';
        }
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
    
    
    public boolean getIsOnHold()
    {
    	if (project != null && project.Status__c != null && project.Status__c.equals( 'On Hold' ))
    	{
    		return true;
    	}
    	
    	return false;
    }
    
	public static testMethod void testCMS_ProjectController()
    {
    	Test.startTest();
		
        User u3 = [SELECT Id, name FROM User WHERE name like 'Integrator Functional%' LIMIT 1];
		User u4 = [SELECT Id, name FROM User WHERE name like '%test%' LIMIT 1];

        CMS_Projects__c testObject = new CMS_Projects__c();
		testObject.Name = 'Test Project';
		testObject.Completed_Date__c = date.today();
		testObject.Due_Date__c = date.today();
		testObject.Project_Manager__c = 'Rebecca Jenkins';
		testObject.Project_Number__c = 'Test123';
		testObject.Project_Lead__c = u4.id;
		insert testObject;
		
		CMS_Milestone__c testChildObject = new CMS_Milestone__c();
		testChildObject.Name = 'Test Task';
		testChildObject.Start_Date__c = date.today();
		testChildObject.Lead__c = u3.id;
		testChildObject.Due_Date__c = date.today();
		testChildObject.CMS_Projects__c = testObject.id;
		insert testChildObject;
		
        ApexPages.StandardController sc = new ApexPages.StandardController( testObject );
	    	
    	CMS_ProjectController testCaseOne = new CMS_ProjectController( sc );
    	CMS_ProjectController testCaseTwo = new CMS_ProjectController();
    	
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
        
        System.RunAs(u3)
        {
            //System.assertEquals( true, testCaseOne.getIsEditable() );
            
            testCaseOne.projectLead = u3.name;
            System.assertEquals( testCaseOne.save(), null );
            
            testCaseOne.projectLead = u4.name;
            System.assertEquals( '/' + testObject.id, testCaseOne.saveAll().getUrl() );
            
            testCaseOne.newMilestone();
            System.assertEquals( 2, testCaseOne.mileStones.size() );
            
            testCaseOne.getListOfLeads();
            
            System.assertEquals( '/apex/CMS_ManageProjects', testCaseOne.cancel().getUrl() );
            testCaseOne.remove();
        }
    }
}
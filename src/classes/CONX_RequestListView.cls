public class CONX_RequestListView
{
    private List<ProgramRequest> programRequests;

    public CONX_Program_Request__c filter{ get; set; }
    public String myPermissionset{ set; get; }

    public String queue{ get; set; }
    public String assignedTo{ get; set; }
    public String columnName{ get; set; }
    public String ascOrDesc{ get; set; }
    public String producer{ get; set; }
    public Id selectedID{ get; set; }
    public String producersInHTML{ get; set; }
    public String status{ get; set; }
    
    public CONX_RequestListView()
    {
    	if (status == null)
    	{
    		status = 'Active';
    	}
    	
        myPermissionset = CONX_Access.getPermissionset( UserInfo.getName() );
        
        if (filter == null)
        {
            filter = new CONX_Program_Request__c();
        }
        
        if (columnName == null)
        {
            columnName = '';
        }
    }
    
    
    public String getListOfProducers()
    {
        if (producersInHTML == null)
        {
            producersInHTML = '';
    
            for (PermissionSetAssignment psa : [SELECT Assignee.Name
                                                  FROM PermissionSetAssignment
                                                 WHERE PermissionSet.IsOwnedByProfile = FALSE
                                                   AND PermissionSetId
                                                    IN (SELECT ParentId FROM ObjectPermissions WHERE SObjectType = 'CONX_Program_Request__c')
                                                   AND PermissionSet.Label = 'CONX Producer'])
            {
                producersInHTML += psa.Assignee.Name + ';';
            }
        }
        
        return producersInHTML;
    }
    
    
    public PageReference create()
    {
        PageReference returningPage = new PageReference( '/apex/CONX_RequestEdit' );
        returningPage.setRedirect(true);
        return returningPage;
    }
    
    
    public String getRegions()
    {
        String listStr = '';
        
        for (SelectOption so : GLOBAL_Library.getPicklistValues( new CONX_Program_Request__c(), 'Request_Region__c' ))
        {
            listStr += so.getLabel() + ';';
        }
        
        return listStr;
    }
    
    
    public PageReference assignProgram()
    {
        List<CONX_Program_Request__c> conxRequests = new List<CONX_Program_Request__c>();
		List<String> requestors = new List<String>();
		
		String emailBody = '';
        emailBody += 'Greetings,<br/><br/>A CO.NX request has been assigned to you for review -<br/><br/>';
		String serverURL = System.URL.getSalesforceBaseURL().getHost();
		
        for (ProgramRequest pr : programRequests)
        {
            if (pr.checked)
            {
                CONX_Program_Request__c cprc = pr.programRequest;
                cprc.Assigned_User__c = producer;
                
                Group owner = [SELECT id FROM Group WHERE type = 'Queue' and name = 'CONX Producer'];
            	cprc.OwnerId = owner.id;
                cprc.status__c = 'In progress';
				pr.checked = false;
                
                conxRequests.add( cprc );
                
                emailBody += 'Title of Program:' + cprc.Program_Titles__c + '<br/>';
				if (cprc.Date_of_Program__c != null)
				{
					emailBody += 'Date of Program:' + cprc.Date_of_Program__c.format() + '<br/>';
				}
				else
				{
					emailBody += 'Date of Program:<br/>';
				}
			    emailBody += 'Program Type:' + cprc.Program_Type__c + '<br/>';
			    emailBody += 'URL: <a href=\"http://' + serverURL + '/apex/CONX_RequestView?id=' + cprc.id + '\">view</a><br/>';
			    emailBody += '<br/>';
			    
			    requestors.add( cprc.Requestor_Email_Work__c );
            }
        }
        
        if (requestors.size() > 25)
    	{
    		ApexPages.addMessage(new ApexPages.Message( ApexPages.Severity.ERROR, 'Please reduce the selected program requests to 25.' ));
    		return null;
    	}
    	
        update( conxRequests );
        
    	if (conxRequests != null && conxRequests.size() > 0)
    	{
    		try
	        {
	        	User producer = [SELECT id, Email FROM User WHERE name = :producer];
	       		emailBody += 'Please login to CO.NX Request  <a href ="http://' + serverURL + '/home/home.jsp">Link</a> to proceed.<br/><br/>Thank you.';
	        	GLOBAL_Library.sendEmail( producer.Email, 'HTML Email Queue', 'CONX - New Program Request', emailBody );
	        }
        	catch( Exception e ){}
        	
        	for(String requestor : requestors)
    		{
    			emailBody = 'Greeting,<br/><br/>The CO.NX team has received your request for help or a new program. A CO.NX team member will initiate contact within two business days.<br/><br/>Thank you.';
                GLOBAL_Library.sendEmail( requestor, 'HTML Email Queue', 'CONX - Your request has been assigned.', emailBody );
    		}
    	}
        
        producer = '';
        
        return null;
    }
    
    
    public PageReference refresh()
    {
        return null;
    }
	
    
    public void updateStatus() {}
    
    public List<programRequest> getProgramRequests()
    {
    	//(select location__c from CONX_Speakers__r), 
        String soql = 'SELECT id, Program_Titles__c, Requestor_Email_Work__c, Washington_Date_of_Program__c , Speaker_1_Location__c, Date_of_Request__c, Program_Type__c, Assigned_User__c, Studio_Location__c, Washington_End_Time__c, ownerId, CreatedById, Date_of_Program__c, Name, Request_Region__c, Washington_Start_Time__c, Status__c FROM CONX_Program_Request__c WHERE name != \'-1\'';
        
        if (filter.Washington_Date_of_Program__c != null)
        {
            Date programDate = filter.Washington_Date_of_Program__c;
            soql += ' AND Washington_Date_of_Program__c = :programDate';
        }
        if (filter.Program_Titles__c != null && filter.Program_Titles__c.length() > 0)
        {
            String programNameStr = filter.Program_Titles__c + '%';
            soql += ' AND Program_Titles__c like :programNameStr';
        }
        if (filter.Washington_Start_Time__c != null && filter.Washington_Start_Time__c.length() > 0)
        {
            String startStr = filter.Washington_Start_Time__c;
            soql += ' AND Washington_Start_Time__c = :startStr';
        }
        if (filter.Studio_Location__c != null && filter.Studio_Location__c.length() > 0)
        {
            String locationStr = filter.Studio_Location__c;
            soql += ' AND Studio_Location__c = :locationStr';
        }
        
        if (filter.Request_Region__c != null && filter.Request_Region__c.length() > 0)
        {
            String regionStr = '\''+ filter.Request_Region__c +'\'';
            soql += ' AND Request_Region__c includes (' + regionStr + ')';
        }
        
        // Ikjae: Change Request - Adding filter for Technical Director 
        if (filter.Technical_Director_First_Name__c != null && filter.Technical_Director_First_Name__c.length() > 0)
        {
        	String directorFirstName = '%' + filter.Technical_Director_First_Name__c + '%';
        	soql += ' AND Technical_Director_First_Name__c like :directorFirstName';
        }
        if (filter.Technical_Director_Last_Name__c != null && filter.Technical_Director_Last_Name__c.length() > 0)
        {
        	String directorLastName = '%' + filter.Technical_Director_Last_Name__c + '%';
        	soql += ' AND Technical_Director_Last_Name__c like :directorLastName';
        }
        
        if (status.equals( 'Active' ))
        {
        	if (filter.Status__c != null  && filter.Status__c.length() > 0)
	        {
	            String statusStr = filter.Status__c;
	            soql += ' AND Status__c = :statusStr';
	        }
	        else
	        {
        		soql += ' AND Status__c in (\'In Progress\', \'New\')';
	        }
        }
        else if (status.equals( 'Archive' ))
        {
        	soql += ' AND Status__c = \'Archive\'';
        }
        else
        {
        	soql += ' AND Status__c = \'Not Approved\'';
        }
        
        if (queue != null && queue.length() > 0)
        {
            try
            {
                Id queueId = [SELECT id FROM Group WHERE type = 'Queue' and name = :queue].Id;
                soql += ' AND OwnerId = :queueId';
            }
            catch (Exception e)
            {
                // none...
            }
        }
        if (assignedTo != null && assignedTo.length() > 0)
        {
            soql += ' AND Assigned_User__c = :assignedTo ';
        }
        
        if (myPermissionset.equalsIgnoreCase( 'CONX View Only' ))
        {
        	List<GroupMember> myGroups = [SELECT group.name FROM GroupMember WHERE UserOrGroupId = :UserInfo.getUserId() AND group.name like 'Regions%']; 
			
			String myRegion = '';
			
			for (GroupMember myGroup : myGroups)
        	{
				myRegion += '\'' + myGroup.group.name.remove( 'Regions - ' ) + '\',';
        	}
        	
        	if (myRegion.length() > 0)
        	{
        		myRegion = myRegion.substring( 0, myRegion.length() - 1 );
        	}
        	else
        	{
        		myRegion = '\'-1\'';
        	}

        	soql += ' AND Request_Region__c includes ( ' + myRegion + ' )';
        }
        
        if (columnName != null && columnName.length() > 0)
        {
            soql += ' ORDER BY ' + columnName + ascOrDesc + ' NULLS LAST';
        }
        else
        {
        	soql += ' ORDER BY CreatedDate desc';
        }

		soql += ' limit 1000';

        programRequests = new List<ProgramRequest>();
        
        Map<Id, String> queueInformation = new Map<Id, String>();
        
        for (Group gp : [SELECT id, name FROM Group WHERE type = 'Queue' and name like 'CONX%'])
        {
            queueInformation.put( gp.id, gp.name ); 
        }

        for (CONX_Program_Request__c program : Database.query( soql ))
        {
        	// Ikjae: CONX.Phase II 1.1 - Modifying the list view to display 12:00 instead of 00:00
        	if (program.Washington_Start_Time__c != null && program.Washington_Start_Time__c.substring( 0, 2 ).equals( '00' ))
        	{
        		program.Washington_Start_Time__c = '12' + program.Washington_Start_Time__c.substring( 2, program.Washington_Start_Time__c.length() );
        	}
        	if (program.Washington_End_Time__c != null && program.Washington_End_Time__c.substring( 0, 2 ).equals( '00' ))
        	{
        		program.Washington_End_Time__c = '12' + program.Washington_End_Time__c.substring( 2, program.Washington_End_Time__c.length() );
        	}
        	
            if (filter.Date_of_Program__c != null)
            {
                if (program.Date_of_Program__c == filter.Date_of_Program__c)
                {
                    ProgramRequest pr = new ProgramRequest();
                    pr.programRequest = program;
                    try
                    {
                        pr.queue = queueInformation.get( program.ownerId );
                    }
                    catch (Exception e)
                    {
                        pr.queue = '';
                    }
                    
                    programRequests.add( pr );
                }
            }
            else
            {
                ProgramRequest pr = new ProgramRequest();
                pr.programRequest = program;
                try
                {
                    pr.queue = queueInformation.get( program.ownerId );
                }
                catch (Exception e)
                {
                    pr.queue = '';
                }
                
                programRequests.add( pr );
            }
        }

        return programRequests;
    }
    
    
    class ProgramRequest implements Comparable
    {
        public CONX_Program_Request__c programRequest{ get; set; }
        public Boolean checked{ get; set; } 
        public String queue{ get; set; }
        
        public programRequest()
        {
            programRequest = new CONX_Program_Request__c();
            checked = false;
            queue = '';
        }
        
        public Integer compareTo( Object other )
        {
            return this.queue.compareTo( ((ProgramRequest) other).queue );
        }
    }

   
    public static testMethod void testCONX_RequestLIstView()
    {             
        Test.startTest();
        
        List<CONX_Program_Request__c> testList = new List<CONX_Program_Request__c>();
        
        for (integer i=0; i < 15; i++)
        {
        	CONX_Program_Request__c cprc = new CONX_Program_Request__c(Program_Titles__c='test', status__c='Archive', Languages__c='English',Washington_Start_Time__c='test', Request_Country__c='United States',Washington_Date_of_Program__c=date.today(), Requestor_Last_Name__c='test',Requestor_First_Name__c='test', Requestor_Email_Work__c='test@test.com', Source_of_Request__c='test', Request_Region__c='AF', Studio_Location__c='test');
        	testList.add( cprc );
        }
        
        for (integer i=0; i < 15; i++)
        {
        	CONX_Program_Request__c cprc2 = new CONX_Program_Request__c(Program_Titles__c='test', status__c='Archive', Languages__c='English',Washington_Start_Time__c='test', Request_Country__c='United States', Requestor_Last_Name__c='test',Requestor_First_Name__c='test', Requestor_Email_Work__c='test@test.com', Source_of_Request__c='test', Request_Region__c='AF', Studio_Location__c='test');
        	testList.add( cprc2 );
        }
        
        insert testList;
        
        CONX_RequestListView aspc = new CONX_RequestListView();
        
        aspc.columnName = 'Request_Country__c';
        aspc.ascOrDesc = ' asc';
        
        aspc.producer = 'Integrator Functional';
        
        aspc.filter.Program_Titles__c = 'test';
        aspc.filter.Studio_Location__c = 'test';
        aspc.filter.Washington_Start_Time__c = 'test';
        aspc.filter.Request_Country__c = 'United States';
        aspc.filter.Languages__c = 'English';
        aspc.filter.Status__c = 'Archive';
        aspc.filter.Request_Region__c = 'AF';
        
        aspc.getListOfProducers();
        
        
        for (ProgramRequest pr : aspc.getProgramRequests())
        {
        	pr.checked = true;
        }
        
        System.assertEquals( aspc.assignProgram(), null );
        
        aspc.filter.Washington_Date_of_Program__c = date.today();
        
        for (ProgramRequest pr : aspc.getProgramRequests())
        {
        	pr.checked = true;
        }
        
        System.assertEquals( aspc.assignProgram(), null );

        aspc.filter = new CONX_Program_Request__c();
        
        aspc.filter.Date_of_Program__c = null;
        aspc.getProgramRequests();
		aspc.getRegions();
        
        ProgramRequest pr = new ProgramRequest();
        ProgramRequest pr2 = new ProgramRequest();
        
        System.assertEquals( pr.compareTo( pr2 ), 0 );
        System.assertEquals( aspc.refresh(), null );
        System.assertEquals( aspc.create().getUrl(), '/apex/CONX_RequestEdit' ); 
        
    }
}
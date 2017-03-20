public class CONX_HelpController
{
    private ApexPages.StandardController std;
    private CONX_Help_Request__c helpRequest;
    
    public List<HelpRequest> helpRequests;
    
    public String assignedTo{ set; get;}
    public String status{ set; get;}
    public String myPermissionset{ set; get; }
    public String columnName{ get; set; }
    public String ascOrDesc{ get; set; }
    public CONX_Help_Request__c filter{ get; set; }
    public String ticketNumber{ get; set; }
    public String owner{ get; set; }
    
    public CONX_HelpController()
    {
        if (filter == null)
        {
            filter = new CONX_Help_Request__c();
        }
        
        if (columnName == null)
        {
            columnName = '';
        }
        
        myPermissionset = CONX_Access.getPermissionset( UserInfo.getName() );
    }
    
    
    public CONX_HelpController( ApexPages.StandardController stdCtrl )
    {
        std = stdCtrl;
        
        if (std != null)
        {
            helpRequest = (CONX_Help_Request__c) std.getRecord();
            if (helpRequest.id == null)
            {
            	helpRequest.Date_of_Help_Request__c = date.today();
            }
        }
        
        myPermissionset = CONX_Access.getPermissionset( UserInfo.getName() );
    }
    
    
    public List<HelpRequest> getHelpRequest()
    {
        helpRequests = new List<HelpRequest>();
        
        String soql = 'SELECT id, Priority__c, Status__c, Owner.Name, Name, Requestor_First_Name__c, Requestor_Last_Name__c, Subject__c, Date_of_Help_Request__c FROM CONX_Help_Request__c WHERE name != \'-1\'';
		
		if (ticketNumber != null)
        {
            String ticketStr = ticketNumber + '%';
            soql += ' AND name like :ticketStr';
        }
        if (filter.Priority__c != null)
        {
            String priority = filter.Priority__c + '%';
            soql += ' AND Priority__c like :priority';
        }
        if (filter.Status__c != null)
        {
            String statusStr = filter.Status__c;
            soql += ' AND Status__c = :statusStr';
        }
        if (owner != null)
        {
        	String userIdStr = '%' + owner + '%';
            soql += ' AND Owner.name like :userIdStr';
        }
        if (filter.Requestor_Last_Name__c != null)
        {
            String requestorLast = '%' + filter.Requestor_Last_Name__c + '%';
            soql += ' AND Requestor_Last_Name__c like :requestorLast';
        }
        if (filter.Requestor_First_Name__c != null)
        {
            String requestorFirst = '%' + filter.Requestor_First_Name__c + '%';
            soql += ' AND Requestor_First_Name__c like :requestorFirst';
        }
        if (filter.Subject__c != null)
        {
            String subject = '%' + filter.Subject__c + '%';
            soql += ' AND Subject__c like :subject';
        }
        if (filter.Date_of_Help_Request__c != null)
        {
            Date requestDate = filter.Date_of_Help_Request__c;
            soql += ' AND Date_of_Help_Request__c = :requestDate';
        }

		
		if (columnName != null && columnName.length() > 0)
        {
            soql += ' ORDER BY ' + columnName + ascOrDesc;
        }
		
        Map<Id, String> queueInformation = new Map<Id, String>();
        
        for (Group gp : [SELECT id, name FROM Group WHERE type = 'Queue' and name like 'CONX%'])
        {
            queueInformation.put( gp.id, gp.name ); 
        }
        
        for (CONX_Help_Request__c help : Database.query( soql ))
        {
            HelpRequest hr = new HelpRequest();
            hr.helpRequest = help;
            hr.queue = queueInformation.get( help.ownerId );
            
            helpRequests.add( hr );
        }

        return helpRequests;
    }
    
    
    public String getConxUsers()
    {
        String conxUsersInHTML = '';
        
        for (PermissionSetAssignment psa : [SELECT Assignee.Name
                                              FROM PermissionSetAssignment
                                             WHERE PermissionSet.IsOwnedByProfile = FALSE
                                               AND PermissionSetId
                                                IN (SELECT ParentId FROM ObjectPermissions WHERE SObjectType = 'CONX_Program_Request__c')
                                               AND PermissionSet.Label like 'CONX%'])
        {
            conxUsersInHTML += psa.Assignee.Name + ';';
        }
        
        return conxUsersInHTML;
    }
    
    
    public String getListOfStatus()
    {
        String listOfStatus = '';
        
        for (SelectOption so : GLOBAL_Library.getPicklistValues( new CONX_Help_Request__c(), 'Status__c' ))
        {
            ListOfStatus += so.getLabel() + ';';
        }
        
        return listOfStatus;
    }
    
    
    public PageReference refresh()
    {
        return null;
    }
    
    
    public PageReference save()
    {
        std.save();
        helpRequest = (CONX_Help_Request__c) std.getRecord();
        
        String emailBody = '';
        String serverURL = System.URL.getSalesforceBaseURL().getHost();
        
        emailBody += 'Subject:' + helpRequest.Subject__c + '<br/>';
        emailBody += 'Requestor First Name:' + helpRequest.Requestor_First_Name__c + '<br/>';
        emailBody += 'Requestor Last Name:' + helpRequest.Requestor_Last_Name__c + '<br/>';
        emailBody += 'Requestor Email:' + helpRequest.Requestor_Email__c + '<br/>';
        emailBody += 'URL: <a href=\"http://' + serverURL + '/apex/CONX_HelpView?id=' + helpRequest.id + '\">view</a><br/>';
        emailBody += '<br/>';
    
        emailBody = 'Greetings,<br/><br/>A new CO.NX help request is awaiting review -<br/><br/>' + emailBody;
        String subject = 'CONX - New Help Request ' + DateTime.now().format();
          
        GLOBAL_Library.sendEmail( '', 'CONX Project Coordinator', subject, emailBody );
        GLOBAL_Library.sendEmail( '', 'CONX Producer', subject, emailBody );
        GLOBAL_Library.sendEmail( '', 'CONX General Queue', subject, emailBody );
        
        return new PageReference( '/' + helpRequest.id );
    }
    
    
    public PageReference cancel()
    {
    	PageReference returningPage;
    	
    	String prevPage = ApexPages.currentPage().getParameters().get( 'prevPage' );
    	
    	if (prevPage.equals( 'listView' ))
    	{
    		returningPage = new PageReference( '/apex/CONX_HelpListView' );
    	}
    	else
    	{
    		returningPage = new PageReference( '/apex/CONX_HelpView?id=' + helpRequest.id );
    	}
    	
    	return returningPage;
    }
    
    
    public PageReference edit()
    {
        PageReference returningPage = new PageReference( '/apex/CONX_HelpEdit?id=' +helpRequest.id + '&prevPage=view' );
        returningPage.setRedirect(true);
        return returningPage;
    }
    
    
    public PageReference deleteHelpRequest()
    {
        delete helpRequest;
        return new PageReference( '/apex/CONX_HelpListView' );
    }
    
    
    public PageReference create()
    {
        PageReference returningPage = new PageReference( '/apex/CONX_HelpEdit?prevPage=listView' );
        returningPage.setRedirect(true);
        return returningPage;
    }
    
    
    public PageReference close()
    {
        List<CONX_Help_Request__c> closeRequest = new List<CONX_Help_Request__c>();
        
        for (HelpRequest hr : helpRequests)
        {
            if (hr.checked)
            {
                hr.helpRequest.Status__c = 'Closed';
                closeRequest.add( hr.helpRequest );
            }
        }
        
        if (closeRequest.size() > 0)
        {
        	update closeRequest;
        }
        
        return null;
    }
    
    
    public PageReference changeStatus()
    {
        List<CONX_Help_Request__c> requests = new List<CONX_Help_Request__c>();
        
        for (HelpRequest hr : helpRequests)
        {
            if (hr.checked)
            {
                hr.helpRequest.Status__c = status;
                requests .add( hr.helpRequest );
            }
        }
        
        if (requests.size() > 0)
        {
        	update requests;
        }
        
        status = '';
        
        return null;
    }
    
    
    public PageReference changeOwner()
    {
        List<CONX_Help_Request__c> requests = new List<CONX_Help_Request__c>();
        
        Id userId;
        
        try
        {
            userId = [SELECT id FROM User WHERE name = :assignedTo limit 1].Id;
        }
        catch (Exception e)
        {
            ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, 'The user was not found in the database.' ));
            return null;
        }
        
        for (HelpRequest hr : helpRequests)
        {
            if (hr.checked)
            {
                hr.helpRequest.ownerID = userId;
                requests.add( hr.helpRequest );
            }
        }
        
         ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, 'size is ' + requests.size() ));
        
        if (requests.size() > 0)
        {
        	update requests;
        }
        
        assignedTo = '';
        
        return null;
    }
    
    
    public PageReference assignToMe()
    {
    	helpRequest.ownerId = UserInfo.getUserId();
    	update( helpRequest );
    	
    	return null;
    }
    
    
    public PageReference resolveTicket()
    {
    	helpRequest.Status__c = 'Closed';
    	update( helpRequest );
    	
    	return new PageReference( '/apex/CONX_HelpListView' );
    }
    
    
    public PageReference reopenTicket()
    {
    	helpRequest.Status__c = 'In Progress';
    	update( helpRequest );
    	
    	return null;
    }
    
    class HelpRequest implements Comparable
    {
        public CONX_Help_Request__c helpRequest{ get; set; }
        public Boolean checked{ get; set; } 
        public String queue{ get; set; }
        
        public HelpRequest()
        {
            helpRequest = new CONX_Help_Request__c();
            queue = '';
            checked = false;
        }
        
        
        public Integer compareTo( Object other )
        {
            return this.queue.compareTo( ((HelpRequest) other).queue );
        }
    }
    
   
    public static testMethod void testCONX_HelpController()
    {             
        Test.startTest();
        CONX_HelpController chc = new CONX_HelpController();
        
        CONX_Help_Request__c chr = new CONX_Help_Request__c( status__c='New', Body__c='test',Date_of_Help_Request__c=date.today(), Subject__c='test', Priority__c='Low',Requestor_Email__c='test@test.com', Requestor_First_Name__c='test', Requestor_Last_Name__c='test');
        insert chr;
        
        ApexPages.StandardController sc = new ApexPages.StandardController( chr );
        
	    CONX_HelpController chc2 = new CONX_HelpController( sc );
        
        
        chc.filter = new CONX_Help_Request__c();
        chc.owner = UserInfo.getName();
        System.assertEquals( chc.getHelpRequest().size(), 0 );
        
        chc.columnName = 'Status__c';
        chc.ascOrDesc = ' asc';

        chc.ticketNumber = '';
        chc.filter.Priority__c = 'Low';
        chc.filter.Status__c = 'New';
        chc.filter.Requestor_First_Name__c = 'test';
        chc.filter.Requestor_Last_Name__c = 'test';
        chc.filter.Subject__c = 'test';
        chc.filter.Date_of_Help_Request__c = date.today();
        System.assertEquals( chc.getHelpRequest().size(), 0 );
        
        chc.getConxUsers();
        chc.getListOfStatus();
        
        SYstem.assertEquals( chc.refresh(), null );
        
        ApexPages.currentPage().getParameters().put( 'prevPage', 'listView' );
        System.assertEquals( chc2.cancel().getUrl(), '/apex/CONX_HelpListView' );
        
        ApexPages.currentPage().getParameters().put( 'prevPage', 'view' );
        System.assertEquals( chc2.cancel().getUrl(), '/apex/CONX_HelpView?id=' + chr.id );
        
        System.assertEquals( chc2.edit().getUrl(), '/apex/CONX_HelpEdit?id=' + chr.id + '&prevPage=view' );
        System.assertEquals( chc2.create().getUrl(), '/apex/CONX_HelpEdit?prevPage=listView' );
        System.assertEquals( chc2.assignToMe(), null );
        System.assertEquals( chc2.resolveTicket().getUrl(), '/apex/CONX_HelpListView' );
        System.assertEquals( chc2.reopenTicket(), null );
        
        System.assertEquals( chc.close(), null );
        System.assertEquals( chc.changeOwner(), null );
        System.assertEquals( chc.changeStatus(), null );
    }
}
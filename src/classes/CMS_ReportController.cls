global class CMS_ReportController
{   
    public String projectName{ get; set; }
    public String tab{ get; set; }
    public String reportType{ get; set; }
    
    public String filterVal{ get; set; } 
    
    public String sortExpressionOM{ get; set; }
	public String sortDirectionOM{ get; set; }
	public String sortExpressionProj{ get; set; }
	public String sortDirectionProj{ get; set; }
	public String sortExpressionRes{ get; set; }
	public String sortDirectionRes{ get; set; }
	public String sortExpressionMile{ get; set; }
	public String sortDirectionMile{ get; set; }

    public CMS_ReportController()
    {
    	if (ApexPages.currentPage().getParameters().get( 'projectName' ) != null)
    	{
        	projectName = EncodingUtil.urlDecode( ApexPages.currentPage().getParameters().get( 'projectName' ), 'UTF-8' );
    	}
    	
    	sortExpressionProj = ApexPages.currentPage().getParameters().get( 'projExp' );
        sortDirectionProj = ApexPages.currentPage().getParameters().get( 'projSortDir' );
        sortExpressionOM = ApexPages.currentPage().getParameters().get( 'omExp' );
        sortDirectionOM = ApexPages.currentPage().getParameters().get( 'omSortDir' );
        
        sortExpressionRes = ApexPages.currentPage().getParameters().get( 'resExp' );
        sortDirectionRes = ApexPages.currentPage().getParameters().get( 'resSortDir' );
        sortExpressionMile = ApexPages.currentPage().getParameters().get( 'mileExp' );
        sortDirectionMile = ApexPages.currentPage().getParameters().get( 'mileSortDir' );
        filterVal = ApexPages.currentPage().getParameters().get( 'weekFilter' );
        
        if (filterVal == null)
        {
        	Date currentWeek = date.today().toStartOfWeek().addDays( 1 );
        	filterVal = currentWeek.year() + '-' + currentWeek.month() + '-' + currentWeek.day();
        }
        
        reportType = ApexPages.currentPage().getParameters().get( 'reportType' );
        tab = ApexPages.currentPage().getParameters().get( 'tabOpt' );
        
    	if (sortExpressionProj == null)
    	{
    		sortExpressionProj = 'Percentage';
        	sortDirectionProj = 'desc';
    	}
    	
    	if (sortExpressionOM == null)
    	{
    		sortExpressionOM = 'Percentage';
        	sortDirectionOM = 'desc';
    	}
    	
    	if (tab == null || tab.length() == 0)
    	{
    		tab = 'Projects';
    	}
    	else
    	{
        	tab = EncodingUtil.urlDecode( tab, 'UTF-8' );
    	}
    }
    
    
    public List<ResourceObj> getHoursByProject()
    {
    	return 	getHoursByProject( 'Req' );
    }
    public List<ResourceObj> getHoursByOM()
    {
    	return 	getHoursByProject( 'OM' );
    }
    public List<ResourceObj> getHoursBySR()
    {
    	return 	getHoursByProject( 'SR' );
    }
    public List<ResourceObj> getHoursByHold()
    {
    	return 	getHoursByProject( 'onhold' );
    }
    
    
    public PageReference filter()
    {
    	PageReference myPage = new PageReference( '/apex/CMS_Resource_Report?projExp='+ sortExpressionProj + '&projSortDir=' + sortDirectionProj + '&omExp=' + sortExpressionOM + '&omSortDir=' + sortDirectionOM + '&tabOpt=' + EncodingUtil.urlEncode( tab, 'UTF-8' ) + '&weekFilter=' + filterVal );
	    myPage.setRedirect( true );

        return myPage;
    }
    
    
    public PageReference sortResourceList()
    {
    	sortDirectionProj = sortDirectionProj == 'desc' ? 'asc' : 'desc';
    	sortDirectionOM = sortDirectionOM == 'desc' ? 'asc' : 'desc';
    	sortDirectionRes = sortDirectionRes == 'desc' ? 'asc' : 'desc';
		sortDirectionMile = sortDirectionMile == 'desc' ? 'asc' : 'desc';

    	PageReference myPage;

    	if ((sortExpressionRes != null && sortExpressionRes.length() > 0) || (sortExpressionMile != null && sortExpressionMile.length() > 0))
    	{
    		myPage = new PageReference( '/apex/CMS_SubReport?resExp='+ sortExpressionRes + '&resSortDir=' + sortDirectionRes + '&mileExp=' + sortExpressionMile + '&mileSortDir=' + sortDirectionMile + '&projectName=' + EncodingUtil.urlEncode( projectName, 'UTF-8' ) + '&weekFilter=' + filterVal );
	        myPage.setRedirect(true);
    	}    	
    	else if ((sortExpressionProj != null && sortExpressionProj.length() > 0) || (sortExpressionOM != null && sortExpressionOM.length() > 0))
    	{
	        myPage = new PageReference( '/apex/CMS_Resource_Report?projExp='+ sortExpressionProj + '&projSortDir=' + sortDirectionProj + '&omExp=' + sortExpressionOM + '&omSortDir=' + sortDirectionOM + '&tabOpt=' + EncodingUtil.urlEncode( tab, 'UTF-8' ) + '&weekFilter=' + filterVal );
	        myPage.setRedirect(true);
    	}
    	
        return myPage;
    }
    
    public List<ResourceObj> getHoursByProject( String projectType )
    {
        List<ResourceObj> values = new List<ResourceObj>();
        Date todayObj = date.today();
        
		Date startDate = date.valueOf( filterVal );
		Date endDate = startDate.addDays( 6 );		
		
		Map<String, CMS_Projects__c> projects = new Map<String, CMS_Projects__c>();
        
        List<String> projectNames = new List<String>();
        Integer total = 0;
        
        String mysql = 'SELECT Name, Anticipated_Hours__c, Due_Date__c, Start_Date__c, Project_Number__c, Application_Affected__c, Requestor__c,' + 
                              'Project_Manager__c, Project_Lead__r.name, Comments__c, Priority__c ' +
        				 'FROM CMS_Projects__c ';
       	//mysql += 'WHERE Due_Date__c >= :startDate ' +
        //           'AND Start_Date__c <= :endDate ';
        mysql += 'WHERE name != \'-1\' ';
        
        if (projectType.equals( 'OM' ))
        {
        	mysql += 'AND Status__c != \'Completed\' ';
        	mysql += 'AND Project_Type__c = \'O&M\'';
        }
        else if (projectType.equals( 'SR' ))
        {
        	mysql += 'AND Status__c != \'Completed\' ';
        	mysql += 'AND Project_Type__c = \'Service Request\'';
        }
        else if (projectType.equals( 'Req' ))
        {
        	List<String> listOfStatus = new List<String>{'Completed', 'On Hold'};
          
			mysql += 'AND Status__c not in :listOfStatus ';
			mysql += 'AND Project_Type__c = \'Project\'';
        }
        else if (projectType.equals( 'onhold' ))
        {
        	mysql += 'AND Status__c = \'On Hold\'';
        }
        
        for (CMS_Projects__c c: Database.query( mysql ))
        {
        	projects.put( c.Name, c );
            projectNames.add( c.Name );
        }
		
		
		
		Map<String, List<CMS_Milestone_Task__c>> taskMaps = new Map<String, List<CMS_Milestone_Task__c>>();
		
		for (CMS_Milestone_Task__c current : [SELECT CMS_Milestone__r.CMS_Projects__r.name, CMS_Milestone__r.Lead__r.name,
													 Due_Date__c, Start_Date__c, Completed_Date__c, Id, Hours_Spent__c, Name, 
                                                     Assigned_Users__c, Anticipated_Hours__c, Functional_Roles__c, percentage__c, 
                                                     Override_Percentage__c, Override_Completed_Date__c, Override__c
		                                        FROM CMS_Milestone_Task__c 
		                                       WHERE CMS_Milestone__r.CMS_Projects__r.name in :projectNames
                                                 AND Due_Date__c >= :startDate 
                                                 AND Start_Date__c <= :endDate])
        {
        	if (taskMaps.containsKey( current.CMS_Milestone__r.CMS_Projects__r.name ))
        	{
        		taskMaps.get( current.CMS_Milestone__r.CMS_Projects__r.name ).add( current );
        	}
        	else
        	{
        		List<CMS_Milestone_Task__c> tasks = new List<CMS_Milestone_Task__c>();
        		tasks.add( current );
        		
        		taskMaps.put( current.CMS_Milestone__r.CMS_Projects__r.name, tasks );	
        	}
        }
        
		for (String myProject : projects.keySet())
		{
			if (!taskMaps.containsKey( myProject ))
        	{
        		CMS_Projects__c myProjectObj = projects.get( myProject );
        		 
        		if (myProjectObj.Start_Date__c <= endDate && myProjectObj.Due_Date__c >= startDate)
        		{
        			taskMaps.put( myProject, new List<CMS_Milestone_Task__c>() );
        		}
        	}
		}
        
        for (String myProject : taskMaps.keySet())
        {
        	ResourceObj ro = new ResourceObj();
        	ro.objStr= myProject;
        	ro.anticipatedHours = Integer.valueOf( projects.get( myProject ).Anticipated_Hours__c );
			ro.ProjectManger = projects.get( myProject ).Project_Manager__c;
			ro.contractorPM = projects.get( myProject ).Project_Lead__r.name;
			ro.priority = projects.get( myProject ).Priority__c;
            ro.requestor = projects.get( myProject ).Requestor__c;
            ro.comments = projects.get( myProject ).Comments__c;
			ro.resourceNumber = projects.get( myProject ).Project_Number__c;
			ro.applicationAffected = projects.get( myProject ).Application_Affected__c;

			Decimal hoursSpent = 0;
			Decimal avgCompPercentage = 0;
			Integer resources = 0;
			String devLeads = '';
			
			Set<String> listOfUsers = new Set<String>();
			
        	for (CMS_Milestone_Task__c myTask : taskMaps.get( myProject ))
        	{
        		if (ro.startDate == null || ro.startDate > myTask.Start_Date__c)
        		{
        			ro.startDate = myTask.Start_Date__c;
        		}
        		
        		if (ro.dueDate == null || ro.dueDate < myTask.Due_Date__c)
        		{
        			ro.dueDate = myTask.Due_Date__c;
        		}
        		
        		hoursSpent += myTask.Hours_Spent__c != null ? myTask.Hours_Spent__c : 0;
        		
        		if (myTask.Override__c)
        		{
        			if (myTask.Override_Percentage__c != null)
        			{
        				avgCompPercentage += myTask.Override_Percentage__c;
        			}        			
        		}
        		else
        		{
        			avgCompPercentage += myTask.percentage__c != null ? myTask.percentage__c : 0;
        		}
        		
        		listOfUsers.addAll( myTask.Assigned_Users__c.split( ',' ));
        		
        		if (devLeads.length() == 0)
        		{
        			devLeads += myTask.CMS_Milestone__r.Lead__r.name;
        		}
        		else
        		{
        			devLeads += ', ' + myTask.CMS_Milestone__r.Lead__r.name;
        		}
        	}
        	
        	ro.hours = Integer.ValueOf( hoursSpent );
        	ro.style = 'background-color:#00FF00;';
    		ro.alt = 'On schedule';
			ro.status = 'Status1';
			
			if ( taskMaps.get( myProject ) != null && taskMaps.get( myProject ).size() != 0)
			{
        		ro.completedPercentage = avgCompPercentage / taskMaps.get( myProject ).size();
			}
			else
			{
				ro.completedPercentage = 0;
			}
			
        	ro.involvedPersonnel = listOfUsers.size();
			ro.devLeads = devLeads;
			
			Double percentage = 0;

			if (ro.startDate != null)
        	{
        		Double daysLeft = ro.startDate.daysBetween( todayObj ) + 1;
				Double totalDays = ro.startDate.daysBetween( ro.dueDate ) + 1;
				percentage = (daysLeft/totalDays) * 100;
        	}
			        		
        	if (ro.completedPercentage < 75 && percentage >= 75)
			{
				ro.style = 'background-color: #FF0000;';
				ro.alt = '75% of the days have been passed and the completion percentage has not met 75%.';
				ro.status = 'Status3';
			}
			else if (ro.completedPercentage < 50 && percentage >= 50)
			{
				ro.style = 'background-color: #FFFF00;';
				ro.alt = '50% of the days have been passed and the completion percentage has not met 50%.';
				ro.status = 'Status2';
			}
			
			ro.startDate = projects.get( myProject ).Start_Date__c;
			ro.dueDate = projects.get( myProject ).Due_Date__c;
			
			if (projectType.equals( 'OM' ))
	        {
	        	ro.sortDirection = this.sortDirectionOM;
            	ro.sortExpression = this.sortExpressionOM;
            	
            	Double daysSpent = (ro.startDate.daysBetween( todayObj ) + 1) / 7;     		
        		ro.avg = 0;
                
                if (daysSpent != 0)
                {   
                    ro.avg =  ro.hours / daysSpent;
                }
	        }
	        else
	        {
	        	ro.sortDirection = this.sortDirectionProj;
            	ro.sortExpression = this.sortExpressionProj;
	        }
	        
	        if (ro.hours > 0 && ro.objStr != null && ro.objStr.length() > 0)
            {
                total += ro.hours;
            }
            
             values.add( ro );
        }

        for (Integer i = 0; i < values.size(); i++)
        {
            ResourceObj asr = values.get( i );
            
            if (asr.hours > 0 && asr.objStr != null && asr.objStr.length() > 0)
            {
                asr.percentage = (asr.hours * 100) / total;
            }
        }

		values.sort();
        
        return values;
    }
    
    
    public List<ResourceObj> getResourcesByProject()
    {
        List<ResourceObj> calculatedValues = new List<ResourceObj>();
        
        Integer total = 0;
        
        Map<String, List<CMS_Milestone_Task__c>> taskMaps = new Map<String, List<CMS_Milestone_Task__c>>();
		
		for (CMS_Milestone_Task__c current : [SELECT CMS_Milestone__r.CMS_Projects__r.name, CMS_Milestone__r.Lead__r.name,
													 Due_Date__c, Start_Date__c, Completed_Date__c, Id, Hours_Spent__c, Name, 
                                                     Assigned_Users__c, Anticipated_Hours__c, Functional_Roles__c, percentage__c, 
                                                     Override_Percentage__c, Override_Completed_Date__c, Override__c
		                                        FROM CMS_Milestone_Task__c 
		                                       WHERE CMS_Milestone__r.CMS_Projects__r.name = :projectName])
        {
        	if (taskMaps.containsKey( current.Functional_Roles__c ))
        	{
        		taskMaps.get( current.Functional_Roles__c ).add( current );
        	}
        	else
        	{
        		List<CMS_Milestone_Task__c> tasks = new List<CMS_Milestone_Task__c>();
        		tasks.add( current );
        		
        		taskMaps.put( current.Functional_Roles__c, tasks );	
        	}
        }
        
        
        for (String myFunctionalRole : taskMaps.keySet())
        {
        	ResourceObj ro = new ResourceObj();
        	
        	ro.objStr= myFunctionalRole;
        	
        	Decimal hoursSpent = 0;
        	Decimal antiHours = 0;
			Decimal avgCompPercentage = 0;
			Integer resources = 0;
			String devLeads = '';
			
			Set<String> listOfUsers = new Set<String>();
        	
        	for (CMS_Milestone_Task__c myTask : taskMaps.get( myFunctionalRole ))
        	{
        		if (ro.startDate == null || ro.startDate > myTask.Start_Date__c)
        		{
        			ro.startDate = myTask.Start_Date__c;
        		}
        		
        		if (ro.dueDate == null || ro.dueDate < myTask.Due_Date__c)
        		{
        			ro.dueDate = myTask.Due_Date__c;
        		}
        		
        		hoursSpent += myTask.Hours_Spent__c != null ? myTask.Hours_Spent__c : 0;
        		antiHours += myTask.Anticipated_Hours__c != null ? myTask.Anticipated_Hours__c : 0;
        		
        		if (myTask.Override__c)
        		{
        			if (myTask.Override_Percentage__c != null)
        			{
        				avgCompPercentage += myTask.Override_Percentage__c;
        			} 
        			
        		}
        		else
        		{
        			avgCompPercentage += myTask.percentage__c != null ? myTask.percentage__c : 0;
        		}
        		
        		listOfUsers.addAll( myTask.Assigned_Users__c.split( ',' ));
        		
        		if (devLeads.length() == 0)
        		{
        			devLeads += myTask.CMS_Milestone__r.Lead__r.name;
        		}
        		else
        		{
        			devLeads += ', ' + myTask.CMS_Milestone__r.Lead__r.name;
        		}
        	}
        	
        	ro.hours =  Integer.valueOf( hoursSpent );
            ro.involvedPersonnel =  listOfUsers.size();
            ro.anticipatedHours = Integer.valueOf( antiHours );
            ro.sortExpression = sortExpressionRes;
            ro.sortDirection = sortDirectionRes;
            
            if (ro.anticipatedHours == null)
            {
            	ro.anticipatedHours = 0;
            }
            
            if (ro.hours != null)
            {
            	total += ro.hours;
            }
            
             calculatedValues.add( ro );
        }

        for (Integer i = 0; i < calculatedValues.size(); i++)
        {
            ResourceObj asr = calculatedValues.get( i );
         	if (asr.hours != null && total != 0)
         	{   
            	asr.percentage = (asr.hours * 100) / total;
         	}
        }
        
		calculatedValues.sort();
		
        return calculatedValues;
    }

    
    //Defining the wrapper class for the individual report
    global class ResourceObj implements Comparable
    {
        public String objStr{ get; set; }
        public Integer anticipatedHours{ get; set; }
        public Integer hours{ get; set; }
        public Decimal percentage{ get; set; }
        public Decimal completedPercentage{ get; set; }
        public String style{ get; set; }
        public Integer involvedPersonnel{ get; set; }
        public Date startDate{ get; set; }
        public Date dueDate{ get; set; }
        public Date completedDate{ get; set;} 
        public String sortExpression{ get; set; }
        public String sortDirection{ get; set; }
        public String contractorPM{ get; set; }
        public String ProjectManger{ get; set; }
        public String comments{ get; set; }
        public String alt{ get; set; }
        public String status{ get; set; }
        public Double avg{ get; set; }
        public String priority{ get; set; }
        public String resourceNumber{ get; set; }
        public String applicationAffected{ get; set; }
        public String requestor{ get; set; }
        public String devLeads{ get; set; }
        
        public ResourceObj()
        {
            objStr= '';
            hours = 0;
            percentage = 0;
            style ='';
            involvedPersonnel = 0;
        }
        
        global Integer compareTo( Object compareTo )
        {
            ResourceObj other = (ResourceObj) compareTo;
            Integer retVal = 0;
            
            if (sortExpression != null && sortExpression.length() > 0 && 
                sortDirection != null && sortDirection.length() > 0)
            {
            	if (sortExpression.equals( 'name' ))
            	{
            		retVal = this.objStr.compareTo( other.objStr );
            	}
            	else if (sortExpression.equals( 'StartDate' ))
            	{
            		if (this.startDate == other.startDate) retVal = 0;
            		else if (this.startDate > other.startDate) retVal = 1;
            		else retVal = -1;
            	}
            	else if (sortExpression.equals( 'DueDate' ))
            	{
            		if (this.dueDate == other.dueDate) retVal = 0;
            		else if (this.dueDate > other.dueDate) retVal = 1;
            		else retVal = -1;
            	}
            	else if (sortExpression.equals( 'completedDate' ))
            	{
            		if (this.completedDate == other.completedDate) retVal = 0;
            		else if (this.completedDate > other.completedDate) retVal = 1;
            		else retVal = -1;
            	}
            	else if (sortExpression.equals( 'Percentage' ))
            	{
            		if (this.percentage == other.percentage) retVal = 0;
            		else if (this.percentage > other.percentage) retVal = 1;
            		else retVal = -1;
            	}
            	else if (sortExpression.equals( 'ProjectedHour' ))
            	{
            		if (this.anticipatedHours == null) retVal = -1;
            		else if (other.anticipatedHours == null) retVal = 1;
            		else if (this.anticipatedHours == other.anticipatedHours) retVal = 0;
            		else if (this.anticipatedHours > other.anticipatedHours) retVal = 1;
            		else retVal = -1;
            	}
            	else if (sortExpression.equals( 'ActualHours' ))
            	{
            		if (this.hours == other.hours) retVal = 0;
            		else if (this.hours > other.hours) retVal = 1;
            		else retVal = -1;
            	}
            	else if (sortExpression.equals( 'Resources' ))
            	{
            		if (this.involvedPersonnel == other.involvedPersonnel) retVal = 0;
            		else if (this.involvedPersonnel > other.involvedPersonnel) retVal = 1;
            		else retVal = -1;
            	}
            	else if (sortExpression.equals( 'ProjectManager' ))
            	{
            		retVal = this.ProjectManger.compareTo( other.ProjectManger );
            	}
            	else if (sortExpression.equals( 'ContractProjectManager' ))
            	{
            		retVal = this.contractorPM.compareTo( other.contractorPM );
            	}
            	else if (sortExpression.equals( 'CcompletedPercentage' ))
            	{
            		if (this.completedPercentage == other.completedPercentage) retVal = 0;
            		else if (this.completedPercentage > other.completedPercentage) retVal = 1;
            		else retVal = -1;
            	}
            	else if (sortExpression.equals( 'average' ))
            	{
            		if (this.avg == other.avg) retVal = 0;
            		else if (this.avg > other.avg) retVal = 1;
            		else retVal = -1;
            	}
            	else if (sortExpression.equals( 'status' ))
            	{
            		retVal = this.status.compareTo( other.status );
            	}
            	else if (sortExpression.equals( 'priority' ))
            	{
            		retVal = this.priority.compareTo( other.priority );
            	}
            	else if (sortExpression.equals( 'resourceNumber' ))
            	{
            		retVal = this.resourceNumber.compareTo( other.resourceNumber );
            	}
            	else if (sortExpression.equals( 'applicationAffected' ))
            	{
            		retVal = this.applicationAffected.compareTo( other.applicationAffected );
            	}
            	else if (sortExpression.equals( 'requestor' ))
            	{
            		retVal = this.requestor.compareTo( other.requestor );
            	}
            	else if (sortExpression.equals( 'devLeads' ))
            	{
            		retVal = this.devLeads.compareTo( other.devLeads );
            	}
            }
            
            if (sortDirection == 'asc')
            {
            	retVal = retVal * -1;
            }
            
            return retVal;
        }
    }
    
    
    public List<Data> getData()
    {
    	Date todayObj = date.today();
    	
    	List<Data> sortedList = new List<Data>();
    	Map<String, List<CMS_Milestone_Task__c>> taskMaps = new Map<String, List<CMS_Milestone_Task__c>>();
		
		for (CMS_Milestone_Task__c current : [SELECT CMS_Milestone__r.name, CMS_Milestone__r.Lead__r.name,
													 Due_Date__c, Start_Date__c, Completed_Date__c, Id, Hours_Spent__c, Name, 
                                                     Assigned_Users__c, Anticipated_Hours__c, Functional_Roles__c, percentage__c, 
                                                     Override_Percentage__c, Override_Completed_Date__c, Override__c
		                                        FROM CMS_Milestone_Task__c 
		                                       WHERE CMS_Milestone__r.CMS_Projects__r.name = :projectName])
        {
        	if (taskMaps.containsKey( current.CMS_Milestone__r.name ))
        	{
        		taskMaps.get( current.CMS_Milestone__r.name ).add( current );
        	}
        	else
        	{
        		List<CMS_Milestone_Task__c> tasks = new List<CMS_Milestone_Task__c>();
        		tasks.add( current );
        		
        		taskMaps.put( current.CMS_Milestone__r.name, tasks );	
        	}
        }
    	
    	for (String milestone : taskMaps.keySet())
        {
        	Data newData = new Data();
        	
            newData.type = milestone;

			Decimal avgCompPercentage = 0;
			Integer resources = 0;
			String devLeads = '';
			
			Set<String> listOfUsers = new Set<String>();
			
        	for (CMS_Milestone_Task__c myTask : taskMaps.get( milestone ))
        	{
        		if (newData.startDate == null || Date.parse( newData.startDate ) > myTask.Start_Date__c)
        		{
        			newData.startDate = myTask.Start_Date__c.month() + '/' + myTask.Start_Date__c.day() + '/' + myTask.Start_Date__c.year();
        		}
        		
        		if (newData.dueDate == null || Date.parse( newData.dueDate ) < myTask.Due_Date__c)
        		{
        			newData.dueDate = myTask.Due_Date__c.month() + '/' + myTask.Due_Date__c.day() + '/' + myTask.Due_Date__c.year();
        		}
        		
        		if (myTask.Override__c)
        		{
        			if (myTask.Override_Percentage__c != null)
        			{
        				avgCompPercentage += myTask.Override_Percentage__c;
        			} 
        			
        			if (myTask.Override_Completed_Date__c != null && (newData.completedDate == null || Date.parse( newData.completedDate ) < myTask.Override_Completed_Date__c))
        			{
        				newData.completedDate = myTask.Override_Completed_Date__c.month() + '/' + myTask.Override_Completed_Date__c.day() + '/' + myTask.Override_Completed_Date__c.year();
        			}   			
        		}
        		else
        		{
        			avgCompPercentage += myTask.percentage__c != null ? myTask.percentage__c : 0;
        			
        			if (myTask.Completed_Date__c != null && (newData.completedDate == null || Date.parse( newData.completedDate ) < myTask.Completed_Date__c))
        			{
        				newData.completedDate = myTask.Completed_Date__c.month() + '/' + myTask.Completed_Date__c.day() + '/' + myTask.Completed_Date__c.year();
        			}
        		}
        		
        		listOfUsers.addAll( myTask.Assigned_Users__c.split( ',' ));
        	}

        	newData.style = 'background-color:#00FF00;';
    		newData.alt = 'On schedule';
			newData.status = 'Status1';
			
			if ( taskMaps.get( milestone ) != null && taskMaps.get( milestone ).size() != 0)
			{
        		newData.percentage = Integer.valueOf( avgCompPercentage / taskMaps.get( milestone ).size() );
			}
			else
			{
				newData.percentage = 0;
			}
        	newData.countOfRecords = listOfUsers.size();

			Double percentage = 0;

			if (newData.startDate != null)
        	{
        		Double daysLeft = Date.parse( newData.startDate ).daysBetween( todayObj ) + 1;
				Double totalDays = Date.parse( newData.startDate ).daysBetween( Date.parse( newData.dueDate )) + 1;
				percentage = (daysLeft/totalDays) * 100;
        	}

			if (newData.percentage == null)
			{
				newData.percentage = 0;
				newData.status = 'Not Started';
				
				if (newData.startDate != null)
				{
					if (todayObj > Date.Parse( newData.startDate ))
					{
						newData.style = 'background-color: #FF0000;';
						newData.alt = 'Start date has been passed and the milestone did not start yet!';
					}
				}
			}
			else if (newData.percentage == 100)
			{
				newData.status = 'Completed';
				
				if ( Date.Parse( newData.dueDate ) < Date.Parse( newData.completedDate ))
				{
					newData.style = 'background-color: #FF0000;';
					newData.alt = 'The milestone was delayed for ' + Date.Parse( newData.dueDate ).daysBetween( Date.Parse( newData.completedDate )) + ' days.';
				}
			}
			else
			{
				if (newData.completedDate != null)
				{
					newData.completedDate = null;
				}
				
				newData.status = 'In Progress';

				if (newData.percentage < 75 && percentage >= 75)
				{
					newData.style = 'background-color: #FF0000;';
					newData.alt = '75% of the days have been passed and the completion percentage has not met 75%.';
				}
				else if (newData.percentage < 50 && percentage >= 50)
				{
					newData.style = 'background-color: #FFFF00;';
					newData.alt = '50% of the days have been passed and the completion percentage has not met 50%.';
				}
			}
			
			newData.sortDirection = sortDirectionMile;
        	newData.sortExpression = sortExpressionMile;
            
            sortedList.add( newData );
        }
        
		sortedList.sort();

        return sortedList;
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
            	if (sortExpression.equals( 'name' ))
            	{
            		retVal = this.type.compareTo( other.type );
            	}
            	else if (sortExpression.equals( 'status' ))
            	{
            		retVal = this.status.compareTo( other.status );
            	}
            	else if (sortExpression.equals( 'Percentage' ))
            	{
            		if (this.percentage == other.percentage) retVal = 0;
            		else if (this.percentage > other.percentage) retVal = 1;
            		else retVal = -1;
            	}
            	else if (sortExpression.equals( 'Start Date' ))
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
            	else if (sortExpression.equals( 'Resources' ))
            	{
            		if (this.countOfRecords == other.countOfRecords) retVal = 0;
            		else if (this.countOfRecords > other.countOfRecords) retVal = 1;
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
    
    public static testMethod void testCMS_ReportController()
    {
    	Test.startTest();
    	
    	ApexPages.currentPage().getParameters().put( 'projectName', 'SF:test' );
    	User u3 = [SELECT Id FROM User WHERE name like 'Integrator Functional%' LIMIT 1];
        CMS_ReportController rc = new CMS_ReportController();
        
        ApexPages.currentPage().getParameters().put( 'tabOpt', 'SF:test' );
        CMS_ReportController rc2 = new CMS_ReportController();
        
        CMS_Projects__c testRecord = new CMS_Projects__c();
        testRecord.Name = 'SF:test';
        testRecord.Anticipated_Hours__c = 5;
        testRecord.Project_Number__c = 'SF:test';
        testRecord.Project_Manager__c = 'test';
        testRecord.Due_Date__c = Date.today().addDays(5);
        testRecord.Start_Date__c = Date.today().addDays( -1 );
        testRecord.Project_Type__c = 'O&M';
        testRecord.Status__c = 'Active';
        insert testRecord;
        
        CMS_Projects__c testRecord2 = new CMS_Projects__c();
        testRecord2.Name = 'OM:test';
        testRecord2.Anticipated_Hours__c = 5;
        testRecord2.Project_Number__c = 'OM:test';
        testRecord2.Project_Manager__c = 'test';
        testRecord2.Due_Date__c = Date.today().addDays(5);
        testRecord2.Start_Date__c = Date.today().addDays( -1 );
        testRecord2.Project_Type__c = 'Project';
        testRecord2.Status__c = 'Active';
        insert testRecord2;
        
        CMS_Milestone__c milestoneRecord = new CMS_Milestone__c();
        milestoneRecord.Name = 'test';
        milestoneRecord.CMS_Projects__c = testRecord2.id;
        milestoneRecord.Anticipated_Hours__c = 4;
        milestoneRecord.Start_Date__c = Date.today();
        milestoneRecord.Due_Date__c = Date.today().addDays(5);
        insert milestoneRecord;
        
        CMS_Milestone_Task__c taskRecord = new CMS_Milestone_Task__c();
        taskRecord.Name = 'test';
        taskRecord.CMS_Milestone__c = milestoneRecord.id;
        taskRecord.Start_Date__c = Date.today().addDays( -1 );
        taskRecord.Due_Date__c = Date.today().addDays( 10 );
        taskRecord.Functional_Roles__c = 'test';
        taskRecord.Assigned_Users__c = 'test;test2';
        taskRecord.Override__c = true;
        taskRecord.Override_Percentage__c = 100;
        taskRecord.Override_Completed_Date__c = Date.today().addDays( 2 );
        insert taskRecord;
        
        CMS_Milestone_Task__c taskRecord2 = new CMS_Milestone_Task__c();
        taskRecord2.Name = 'test';
        taskRecord2.CMS_Milestone__c = milestoneRecord.id;
        taskRecord2.Start_Date__c = Date.today().addDays( -1 );
        taskRecord2.Due_Date__c = Date.today().addDays( 10 );
        taskRecord2.Functional_Roles__c = 'test';
        taskRecord2.Assigned_Users__c = 'test;test2';
        taskRecord2.percentage__c = 100;
        taskRecord2.Completed_Date__c = Date.today().addDays( 2 );
        insert taskRecord2;
        
        CMS_Milestone__c milestoneRecord2 = new CMS_Milestone__c();
        milestoneRecord2.Name = 'test2';
        milestoneRecord2.CMS_Projects__c = testRecord2.id;
        milestoneRecord2.Anticipated_Hours__c = 4;
        milestoneRecord2.Start_Date__c = Date.today().addDays( -1 );
        milestoneRecord2.Due_Date__c = Date.today().addDays(5);
        insert milestoneRecord2;
        
        CMS_Milestone_Task__c taskRecord3 = new CMS_Milestone_Task__c();
        taskRecord3.Name = 'test';
        taskRecord3.CMS_Milestone__c = milestoneRecord2.id;
        taskRecord3.Start_Date__c = Date.today().addDays( -1 );
        taskRecord3.Due_Date__c = Date.today().addDays( 10 );
        taskRecord3.Functional_Roles__c = 'test';
        taskRecord3.Assigned_Users__c = 'test;test2';
        taskRecord3.Override__c = true;
        taskRecord3.Override_Percentage__c = 25;
        insert taskRecord3;
        
        CMS_Milestone_Task__c taskRecord4 = new CMS_Milestone_Task__c();
        taskRecord4.Name = 'test';
        taskRecord4.CMS_Milestone__c = milestoneRecord2.id;
        taskRecord4.Start_Date__c = Date.today().addDays( -1 );
        taskRecord4.Due_Date__c = Date.today().addDays( 10 );
        taskRecord4.Functional_Roles__c = 'test';
        taskRecord4.Assigned_Users__c = 'test;test2';
        taskRecord4.percentage__c = 25;
        insert taskRecord4;
        
        System.RunAs( u3 )
    	{
    		rc.sortDirectionProj = 'asc';
    		rc.sortExpressionProj = 'Start Date';
    		rc.getHoursBySR();
    		rc.getHoursByHold();
    		rc.filter();
    		rc.getHoursByProject();
    		rc.getHoursByOM();
    		
	        rc.getData();
	        rc.projectName = 'OM:test';
	        
	        rc.getResourcesByProject();
	        
	        rc.sortExpressionRes = 'test';
    		rc.sortExpressionRes = 'test';
			rc.sortResourceList();
			
			rc2.sortExpressionProj = 'test';
			rc2.sortExpressionOM = 'test';
    		rc2.sortResourceList();
    		
    		
    		ResourceObj a = new ResourceObj();
    		a.objStr = 'test';
	        a.anticipatedHours = 2;
	        a.hours = 2;
	        a.percentage = 2;
	        a.completedPercentage = 2;
	        a.style = 'test';
	        a.involvedPersonnel = 2;
	        a.startDate = Date.Today();
	        a.dueDate = Date.Today();
	        a.completedDate =Date.Today();
	        a.contractorPM = 'test';
	        a.ProjectManger = 'test';
	        a.comments =  'test';
	        a.alt = 'test';
	        a.status = 'test';
	        a.avg = 2;
	        a.priority = 'test';
	        a.resourceNumber = '2';
	        a.applicationAffected = 'test';
	        a.requestor = 'test';
	        a.devLeads = 'test';
	        a.sortDirection = 'asc';
	        
	        ResourceObj b = new ResourceObj();
    		b.objStr = 'test';
	        b.anticipatedHours = 2;
	        b.hours = 2;
	        b.percentage = 2;
	        b.completedPercentage = 2;
	        b.style = 'test';
	        b.involvedPersonnel = 2;
	        b.startDate = Date.Today();
	        b.dueDate = Date.Today();
	        b.completedDate =Date.Today();
	        b.contractorPM = 'test';
	        b.ProjectManger = 'test';
	        b.comments =  'test';
	        b.alt = 'test';
	        b.status = 'test';
	        b.avg = 2;
	        b.priority = 'test';
	        b.resourceNumber ='2';
	        b.applicationAffected = 'test';
	        b.requestor = 'test';
	        b.devLeads = 'test';
	        
	        a.sortExpression = 'name';
	        a.compareTo( b );
	        
	        a.sortExpression = 'DueDate';
	        a.compareTo( b );
	        
	        a.sortExpression = 'StartDate';
	        a.compareTo( b );
	        
	        a.sortExpression = 'completedDate';
	        a.compareTo( b );
	        
	        a.sortExpression = 'Percentage';
	        a.compareTo( b );
	        
	        a.sortExpression = 'ProjectedHour';
	        a.compareTo( b );
	        
	        a.sortExpression = 'ActualHours';
	        a.compareTo( b );
	        
	        a.sortExpression = 'Resources';
	        a.compareTo( b );
	        
	        a.sortExpression = 'ProjectManager';
	        a.compareTo( b );
	        
	        a.sortExpression = 'ContractProjectManager';
	        a.compareTo( b );
	        
	        a.sortExpression = 'CcompletedPercentage';
	        a.compareTo( b );
	        
	        a.sortExpression = 'average';
	        a.compareTo( b );
	        
	        a.sortExpression = 'status';
	        a.compareTo( b );
	        
	        a.sortExpression = 'priority';
	        a.compareTo( b );
	        
	        a.sortExpression = 'resourceNumber';
	        a.compareTo( b );
	        
	        a.sortExpression = 'applicationAffected';
	        a.compareTo( b );
	        
	        a.sortExpression = 'requestor';
	        a.compareTo( b );
	        
	        a.sortExpression = 'devLeads';
	        a.compareTo( b );
	        
	        Data a1 = new Data();
	        a1.type = 'test';
	        a1.dueDate = '2/22/2013';
	        a1.startDate = '2/22/2013';
	        a1.percentage = 100;
	        a1.delayDate = 2;
	        a1.completedDate = '2/22/2013';
	        a1.status = 'test';
	        a1.countOfRecords = 2;
	        a1.style = 'test';
	        a1.alt = 'test';
	        a1.sortDirection = 'asc';
			
			Data b2 = new Data();
	        b2.type = 'test';
	        b2.dueDate = '2/22/2013';
	        b2.startDate = '2/22/2013';
	        b2.percentage = 100;
	        b2.delayDate = 2;
	        b2.completedDate = '2/22/2013';
	        b2.status = 'test';
	        b2.countOfRecords = 2;
	        b2.style = 'test';
	        b2.alt = 'test';
	        b2.sortDirection = 'asc';

	        a1.sortExpression = 'name';
	        a1.compareTo( b2 );
	        
	        a1.sortExpression = 'status';
	        a1.compareTo( b2 );
	        
	        a1.sortExpression = 'Percentage';
	        a1.compareTo( b2 );
	        
	        a1.sortExpression = 'Start Date';
	        a1.compareTo( b2 );
	        
	        a1.sortExpression = 'Due Date';
	        a1.compareTo( b2 );
	        
	        a1.sortExpression = 'Completed Date';
	        a1.compareTo( b2 );
	        
	        a1.sortExpression = 'Resources';
	        a1.compareTo( b2 );
    	}
    }
}
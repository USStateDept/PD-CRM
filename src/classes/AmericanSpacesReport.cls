public class AmericanSpacesReport
{
	public String reportName{ get; set; }
	
	public boolean getIsAmericanWashington()
	{
		String permissionName;
        try
        {
	        permissionName = [SELECT PermissionSet.Label
	    	                    FROM PermissionSetAssignment
	                           WHERE PermissionSet.IsOwnedByProfile = FALSE
	                             AND PermissionSetId
	                	          IN (SELECT ParentId FROM ObjectPermissions WHERE SObjectType = 'American_Spaces_Mission_Contact__c')
	                             AND Assignee.Name = :Userinfo.getName() LIMIT 1].PermissionSet.Label;
        }
        catch (Exception e)
        {
        	permissionName = '';
        }
        
        if (!permissionName.contains( 'SITECOM' ))
        {
        	return true;
        }
        
        return false;
	}
	
    public List<American_Spaces_Statistic__c> getStatistics()
    {
    	String soql = 'SELECT Month__c, SUM( Number_of_Program_Attendees__c ) totalAtt, SUM( Number_of_Programs__c ) totalProg, SUM( Number_of_Visitors__c ) totalVisit FROM American_Spaces_Statistic__c';
      	
      	String country = ApexPages.currentPage().getParameters().get( 'stats_country' );
      	String region  = ApexPages.currentPage().getParameters().get( 'stats_region' );
      	
      	if ((country != null && country.length() > 0) && (region != null && region.length() > 0))
      	{
      		soql += ' WHERE Name_of_Space__r.Managing_Post_City__r.country__c = :country AND  Name_of_Space__r.Managing_Post_City__r.region__c = :region';
      	}
      	else if (country != null && country.length() > 0) 
      	{
      		soql += ' WHERE Name_of_Space__r.Managing_Post_City__r.country__c = :country';
      	}
      	else if (region != null && region.length() > 0)
      	{
      		soql += ' WHERE Name_of_Space__r.Managing_Post_City__r.region__c = :region';
      	}
      	
      	soql += ' GROUP BY month__c';
      	
    	List<American_Spaces_Statistic__c> calculatedValues = new List<American_Spaces_Statistic__c>();
    	
    	
    	List<AggregateResult> aggregatedResults = Database.query( soql );
    	
    	for (AggregateResult ar : aggregatedResults)
        {
		    American_Spaces_Statistic__c assc = new American_Spaces_Statistic__c();
		    assc.Month__c = (String) ar.get( 'Month__c' );
		    assc.Number_of_Program_Attendees__c = (Decimal) ar.get( 'totalAtt' );
		    assc.Number_of_Programs__c = (Decimal) ar.get( 'totalProg' );
		    assc.Number_of_Visitors__c = (Decimal) ar.get( 'totalVisit' );
		    
		    calculatedValues.add( assc );
		}
    	
        return calculatedValues;
    }
    
    
	class adminRegionType implements Comparable
	{
		public String region{set; get;}
		public Integer infoResourceCenter{set; get;}
		public Integer americanCenter{set; get;}
		public Integer binationalCenter{set; get;}
		//public Integer scienceCenter{set; get;}
		public Integer americanCornor{set; get;}
		public Integer other{set; get;}
		public Integer numOfCountriesWithSpaces{set; get;}
		public Decimal percentageOfCountriesWithSpaces{set; get;}
		
		public adminRegionType()
		{
			region = '';
			infoResourceCenter = 0;
			americanCenter = 0;
			binationalCenter = 0;
			//scienceCenter = 0;
			americanCornor = 0;
			other = 0;
			numOfCountriesWithSpaces = 0;
			percentageOfCountriesWithSpaces = 0;
		}
		public Integer getTotal()
		{
			return infoResourceCenter + binationalCenter + americanCenter + americanCornor;
		}
		public Integer compareTo(Object compareTo)
		{
		    adminRegionType other = (adminRegionType) compareTo;
		    
		    return region.compareTo( other.region );
		}
	}
	
	public adminRegionType totalAdminREgionType{ get; set; }
	    
    public List<adminRegionType> getAdminRegionTypes()
    {
    	List<adminRegionType> calculatedValues = new List<adminRegionType>();
    	
    	Map<String, adminRegionType> calculatedMap = new Map<String, adminRegionType>();
    	
    	for (AggregateResult ar : [SELECT Region__c FROM American_Spaces_Post_Contacts__c 
                                   WHERE Region__c <> 'Not Applicable'
                                   GROUP BY Region__c ORDER BY Region__c DESC])
    	{
    		String region = (String) ar.get( 'Region__c' );
    		
    		if (!region.equalsIgnoreCase( 'iip' ))
    		{
    			adminRegionType art = new adminRegionType();
    			art.region = region;
    		
    			calculatedMap.put( region, art );
    		}
    	}
    	
    	totalAdminREgionType = new adminRegionType();
    	
    	for (American_Spaces_Contact__c c : [SELECT Report_Region__c, Type_of_Space__c FROM American_Spaces_Contact__c WHERE Status__c = 'In Operation' AND Open_to_public__c = 'Yes'])
        {
			if (( 'Information Resource Center' ).equalsIgnoreCase( c.Type_of_Space__c ))
			{
				calculatedMap.get( c.Report_Region__c ).infoResourceCenter++;
				totalAdminREgionType.infoResourceCenter++;
			}
			else if (( 'American Center' ).equalsIgnoreCase( c.Type_of_Space__c ))
			{
				calculatedMap.get( c.Report_Region__c ).americanCenter++;
				totalAdminREgionType.americanCenter++;
			}
			else if (( 'Binational Center' ).equalsIgnoreCase( c.Type_of_Space__c ))
			{
				calculatedMap.get( c.Report_Region__c ).binationalCenter++;
				totalAdminREgionType.binationalCenter++;
			}
			/*else if (( 'Science Corner' ).equalsIgnoreCase( c.Type_of_Space__c ))
			{
				calculatedMap.get( c.Report_Region__c ).scienceCenter++;
				totalAdminREgionType.scienceCenter++;
			}*/
			else if (( 'American Corner' ).equalsIgnoreCase( c.Type_of_Space__c ))
			{
				calculatedMap.get( c.Report_Region__c ).americanCornor++;
				totalAdminREgionType.americanCornor++;
			}
			else
			{
				calculatedMap.get( c.Report_Region__c ).other++;
				totalAdminREgionType.other++;
			}
		}
		
		calculatedValues = calculatedMap.values();
		calculatedValues.sort();
	    	
        return calculatedValues;
    }
    
    public Integer totalCountries{ get; set; }
    
    public List<adminRegionType> getCountriesWithSpaces()
    {
    	List<adminRegionType> calculatedValues = new List<adminRegionType>();
    	
    	totalCountries = 0;
    	
    	for (AggregateResult ar : [SELECT Region__c, COUNT_DISTINCT(country__c) total
    	                             FROM American_Spaces_Post_Contacts__c 
    	                            WHERE id in (SELECT Managing_Post_City__c FROM American_Spaces_Contact__c WHERE Status__c = 'In Operation' AND Open_to_public__c = 'Yes')
                                 GROUP BY Region__c])
    	{
    		String region = (String) ar.get( 'Region__c' );
    		Integer total = (Integer) ar.get( 'total' );
    		
    		adminRegionType art = new adminRegionType();
    		art.region = region;
    		art.numOfCountriesWithSpaces = total;
			
			calculatedValues.add( art );
			totalCountries += total;
    	}
    	
    	calculatedValues.sort();
    	
    	return calculatedValues;
    }
    
    
    public List<adminRegionType> getCountriesWithSpacesPieData()
    {
    	List<adminRegionType> pieData = new List<adminRegionType>();
    	
    	for (adminRegionType art : getCountriesWithSpaces())
    	{
    		art.percentageOfCountriesWithSpaces = Math.round((art.numOfCountriesWithSpaces * 100) / totalCountries);
    		//art.percentageOfCountriesWithSpaces = 20;
    		
    		pieData.add( art );
    	}
    	
    	return pieData;
    }
    
    class Statisitics implements Comparable
	{
		public String region{set; get;}
		public Integer infoResourceCenterProgram{set; get;}
		public Integer americanCenterProgram{set; get;}
		public Integer binationalCenterProgram{set; get;}
		//public Integer scienceCenterProgram{set; get;}
		public Integer americanCornorProgram{set; get;}
		public Integer infoResourceCenterAttendee{set; get;}
		public Integer americanCenterAttendee{set; get;}
		public Integer binationalCenterAttendee{set; get;}
		//public Integer scienceCenterAttendee{set; get;}
		public Integer americanCornorAttendee{set; get;}
		public Integer infoResourceCenterVisitor{set; get;}
		public Integer americanCenterVisitor{set; get;}
		public Integer binationalCenterVisitor{set; get;}
		//public Integer scienceCenterVisitor{set; get;}
		public Integer americanCornorVisitor{set; get;}
		
		public Statisitics()
		{
			region = '';
			infoResourceCenterProgram = 0;
			americanCenterProgram = 0;
			binationalCenterProgram = 0;
			//scienceCenterProgram = 0;
			americanCornorProgram = 0;
			infoResourceCenterAttendee = 0;
			americanCenterAttendee = 0;
			binationalCenterAttendee = 0;
			//scienceCenterAttendee = 0;
			americanCornorAttendee = 0;
			infoResourceCenterVisitor = 0;
			americanCenterVisitor = 0;
			binationalCenterVisitor = 0;
			//scienceCenterVisitor = 0;
			americanCornorVisitor = 0;
		}
		
		public Integer getTotalPrograms()
		{
			return infoResourceCenterProgram + americanCenterProgram + binationalCenterProgram + americanCornorProgram;
		}
		public Integer getTotalAttendee()
		{
			return infoResourceCenterAttendee + americanCenterAttendee + binationalCenterAttendee + americanCornorAttendee;
		}
		public Integer getTotalVisitor()
		{
			return infoResourceCenterVisitor + americanCenterVisitor + binationalCenterVisitor + americanCornorVisitor;
		}
		
		public Integer compareTo(Object compareTo)
		{
		    statisitics other = (statisitics) compareTo;
		    
		    return region.compareTo( other.region );
		}
	}
	
	public Statisitics grandTotal{ set; get; }
	public String year{ set; get; }
	
    public List<Statisitics> getAmericanSpacesStatistics()
    {
    	List<Statisitics> calculatedValue = new List<Statisitics>();
    	Map<String, Statisitics> calculatedMap = new Map<String, Statisitics>();
    	
    	for (AggregateResult ar : [SELECT Region__c FROM American_Spaces_Post_Contacts__c 
                                   WHERE Region__c <> 'Not Applicable'
                                   group by Region__c order by Region__c desc])
    	{
    		String region = (String) ar.get( 'Region__c' );
    		
    		if (!region.equalsIgnoreCase( 'iip' ))
    		{
    			Statisitics statistic = new Statisitics();
    			statistic.region = region;
    		
    			calculatedMap.put( region, statistic );
    		}
    	}
    	
    	grandTotal = new Statisitics();
    	
    	if (ApexPages.currentPage() != null)
    	{
    		year = ApexPages.currentPage().getParameters().get( 'year' );
    	}
    	
    	if (year == null || year.length() == 0)
    	{
    		year = String.ValueOf( datetime.now().year() );
    	}
    	
    	String prevYear = String.ValueOf( Integer.valueOf( year ) - 1 );
    	
    	List<American_Spaces_Statistic__c> fullList = [SELECT Name_of_Space__r.Type_of_Space__c, region__c, Number_of_Program_Attendees__c, 
    	                                                          Number_of_Programs__c, Number_of_Visitors__c
 													         FROM American_Spaces_Statistic__c 
 												            WHERE Name_of_Space__c != ''
 												              AND Name_of_Space__r.Status__c = 'In Operation' AND Name_of_Space__r.Open_to_public__c = 'Yes'
 													          AND Month__c in ('October', 'November', 'December') AND Year__c = :prevYear];
 		
 		List<American_Spaces_Statistic__c> thisYear = [SELECT Name_of_Space__r.Type_of_Space__c, region__c, Number_of_Program_Attendees__c, 
    	                                                      Number_of_Programs__c, Number_of_Visitors__c
 											             FROM American_Spaces_Statistic__c 
 											            WHERE Name_of_Space__c != ''
 											              AND Name_of_Space__r.Status__c = 'In Operation' AND Name_of_Space__r.Open_to_public__c = 'Yes'
 												          AND Month__c not in ('October', 'November', 'December') AND Year__c = :year];											           
    	
    	fullList.addAll( thisYear );
    	
    	for (American_Spaces_Statistic__c assc : fullList)
 		{
 			Decimal numOfPrograms = (assc.Number_of_Programs__c == null) ? 0 :  assc.Number_of_Programs__c;
 			Decimal numOfProgramAttendees = (assc.Number_of_Program_Attendees__c == null) ? 0 :  assc.Number_of_Program_Attendees__c;
 			Decimal numOfVisitors = (assc.Number_of_Visitors__c == null) ? 0 :  assc.Number_of_Visitors__c;
 			
 			if (( 'Information Resource Center' ).equalsIgnoreCase( assc.Name_of_Space__r.Type_of_Space__c ))
			{
				calculatedMap.get( assc.Region__c ).infoResourceCenterProgram += Integer.valueOf( numOfPrograms );
				calculatedMap.get( assc.Region__c ).infoResourceCenterAttendee += Integer.valueOf( numOfProgramAttendees );
				calculatedMap.get( assc.Region__c ).infoResourceCenterVisitor += Integer.valueOf( numOfVisitors );
				
				grandTotal.infoResourceCenterProgram += Integer.valueOf( numOfPrograms );
				grandTotal.infoResourceCenterAttendee += Integer.valueOf( numOfProgramAttendees );
				grandTotal.infoResourceCenterVisitor += Integer.valueOf( numOfVisitors );
			}
			
			else if (( 'American Center' ).equalsIgnoreCase( assc.Name_of_Space__r.Type_of_Space__c ))
			{
				calculatedMap.get( assc.Region__c ).americanCenterProgram += Integer.valueOf( numOfPrograms );
				calculatedMap.get( assc.Region__c ).americanCenterAttendee += Integer.valueOf( numOfProgramAttendees );
				calculatedMap.get( assc.Region__c ).americanCenterVisitor += Integer.valueOf( numOfVisitors );
				
				grandTotal.americanCenterProgram += Integer.valueOf( numOfPrograms );
				grandTotal.americanCenterAttendee += Integer.valueOf( numOfProgramAttendees );
				grandTotal.americanCenterVisitor += Integer.valueOf( numOfVisitors );
			}		
			else if (( 'Binational Center' ).equalsIgnoreCase( assc.Name_of_Space__r.Type_of_Space__c ))
			{
				calculatedMap.get( assc.Region__c ).binationalCenterProgram += Integer.valueOf( numOfPrograms );
				calculatedMap.get( assc.Region__c ).binationalCenterAttendee += Integer.valueOf( numOfProgramAttendees );
				calculatedMap.get( assc.Region__c ).binationalCenterVisitor += Integer.valueOf( numOfVisitors );
				
				grandTotal.binationalCenterProgram += Integer.valueOf( numOfPrograms );
				grandTotal.binationalCenterAttendee += Integer.valueOf( numOfProgramAttendees );
				grandTotal.binationalCenterVisitor += Integer.valueOf( numOfVisitors );
			}
			/*else if (( 'Science Corner' ).equalsIgnoreCase( assc.Name_of_Space__r.Type_of_Space__c ))
			{
				calculatedMap.get( assc.Region__c ).scienceCenterProgram += Integer.valueOf( numOfPrograms );
				calculatedMap.get( assc.Region__c ).scienceCenterAttendee += Integer.valueOf( numOfProgramAttendees );
				calculatedMap.get( assc.Region__c ).scienceCenterVisitor += Integer.valueOf( numOfVisitors );
				
				grandTotal.scienceCenterProgram += Integer.valueOf( numOfPrograms );
				grandTotal.scienceCenterAttendee += Integer.valueOf( numOfProgramAttendees );
				grandTotal.scienceCenterVisitor += Integer.valueOf( numOfVisitors );
			}*/
			else if (( 'American Corner' ).equalsIgnoreCase( assc.Name_of_Space__r.Type_of_Space__c ))
			{
				calculatedMap.get( assc.Region__c ).americanCornorProgram += Integer.valueOf( numOfPrograms );
				calculatedMap.get( assc.Region__c ).americanCornorAttendee += Integer.valueOf( numOfProgramAttendees );
				calculatedMap.get( assc.Region__c ).americanCornorVisitor += Integer.valueOf( numOfVisitors );
				
				grandTotal.americanCornorProgram += Integer.valueOf( numOfPrograms );
				grandTotal.americanCornorAttendee += Integer.valueOf( numOfProgramAttendees );
				grandTotal.americanCornorVisitor += Integer.valueOf( numOfVisitors );
			}
 		}
 		
 		calculatedValue = calculatedMap.values();
		calculatedValue.sort();
 		
 		return calculatedValue;
    }
    
    public class AmericanSpaceReportObj
    {
    	public String typeStr{get; set;}
    	public Integer total{get; set;}
    	public Decimal percentage{get; set;}
    }
    
    public List<AmericanSpaceReportObj> getProportionOfAmericanSpaces()
    {
    	List<AmericanSpaceReportObj> calculatedValues = new List<americanSpaceReportObj>();
    	Integer total = 0;
    	
    	for (AggregateResult ar : [SELECT Type_of_Space__c, count(id) total FROM American_Spaces_Contact__c WHERE Type_of_Space__c != null AND Status__c = 'In Operation' AND Open_to_public__c = 'Yes' GROUP BY Type_of_Space__c])
    	{
    		AmericanSpaceReportObj asro = new AmericanSpaceReportObj();
    		
    		asro.typeStr = (String) ar.get( 'Type_of_Space__c' );
    		asro.total = (Integer) ar.get( 'total' );
    		
    		total += asro.total;
    		
    		calculatedValues.add( asro );
    	}
    	
    	for (AmericanSpaceReportObj asr : calculatedValues)
    	{
    		asr.percentage = (asr.total * 100) / total;
    	}
    	
    	return calculatedValues;
    }
    
    
    public static testMethod void testAmericanSpacesReport()
    {             
        Test.startTest();
      
        American_Spaces_Post_Contacts__c aspc = new American_Spaces_Post_Contacts__c( Name='test', region__c='EUR', country__c='Brazil' );
        insert aspc;
        
        American_Spaces_Contact__c ascc1 = new American_Spaces_Contact__c( Name='test', Managing_Post_City__c=aspc.id, Type_of_Space__c='Information Resource Center' );
        insert ascc1;
        
        American_Spaces_Contact__c ascc2 = new American_Spaces_Contact__c( Name='test', Managing_Post_City__c=aspc.id, Type_of_Space__c='American Center' );
        insert ascc2;
        
        American_Spaces_Contact__c ascc3 = new American_Spaces_Contact__c( Name='test', Managing_Post_City__c=aspc.id, Type_of_Space__c='Binational Center' );
        insert ascc3;
        
        //American_Spaces_Contact__c ascc4 = new American_Spaces_Contact__c( Name='test', Managing_Post_City__c=aspc.id, Type_of_Space__c='Science Corner' );
        //insert ascc4;
        
         American_Spaces_Contact__c ascc5 = new American_Spaces_Contact__c( Name='test', Managing_Post_City__c=aspc.id, Type_of_Space__c='American Corner' );
        insert ascc5;
        
        American_Spaces_Statistic__c testRecord1 = new American_Spaces_Statistic__c( Name_of_Space__c=ascc1.id, Number_of_Programs__c=1, Number_of_Program_Attendees__c=1, Number_of_Visitors__c=1, Month__c='March', Year__c=String.ValueOf( datetime.now().year() ) );
        insert testRecord1;
        
        American_Spaces_Statistic__c testRecord2 = new American_Spaces_Statistic__c( Name_of_Space__c=ascc2.id, Number_of_Programs__c=1, Number_of_Program_Attendees__c=1, Number_of_Visitors__c=1, Month__c='March', Year__c=String.ValueOf( datetime.now().year() ) );
        insert testRecord2;
        
        American_Spaces_Statistic__c testRecord3 = new American_Spaces_Statistic__c( Name_of_Space__c=ascc3.id, Number_of_Programs__c=1, Number_of_Program_Attendees__c=1, Number_of_Visitors__c=1, Month__c='March', Year__c=String.ValueOf( datetime.now().year() ) );
        insert testRecord3;
        
        //American_Spaces_Statistic__c testRecord4 = new American_Spaces_Statistic__c( Name_of_Space__c=ascc4.id, Number_of_Programs__c=1, Number_of_Program_Attendees__c=1, Number_of_Visitors__c=1, Month__c='March', Year__c=String.ValueOf( datetime.now().year() ) );
        //insert testRecord4;
        
        American_Spaces_Statistic__c testRecord5 = new American_Spaces_Statistic__c( Name_of_Space__c=ascc5.id, Number_of_Programs__c=1, Number_of_Program_Attendees__c=1, Number_of_Visitors__c=1, Month__c='March', Year__c=String.ValueOf( datetime.now().year() ) );
        insert testRecord5;
        
        AmericanSpacesReport asr = new AmericanSpacesReport();
        
     
        for (adminRegionType a : asr.getAdminRegionTypes())
        {
        	a.getTotal();
        }
        
        asr.getIsAmericanWashington();
        asr.getCountriesWithSpaces();
        System.assertEquals( asr.getStatistics().size(), 1 );
           
        ApexPages.currentPage().getParameters().put( 'stats_country', 'Brazil' );
        System.assertEquals( asr.getStatistics().size(), 1 );
        
        ApexPages.currentPage().getParameters().remove( 'stats_country' );
        ApexPages.currentPage().getParameters().put( 'stats_region', 'EUR' );
        System.assertEquals( asr.getStatistics().size(), 1 );
        
        asr.getProportionOfAmericanSpaces();
        asr.getCountriesWithSpacesPieData();
        
        for (Statisitics s : asr.getAmericanSpacesStatistics())
        {
        	s.getTotalPrograms();
        	s.getTotalAttendee();
        	s.getTotalVisitor();
        }
        
    }
}
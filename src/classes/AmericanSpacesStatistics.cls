public class AmericanSpacesStatistics
{
    public ApexPages.StandardController std{get; set;}
    public American_Spaces_Statistic__c statistic{get; set;}
	private boolean isModifiable = false;

    public AmericanSpacesStatistics( ApexPages.StandardController stdCtrl )
    {
        std = stdCtrl;
        if (!Test.isRunningTest())
        {       
            statistic = (American_Spaces_Statistic__c) std.getRecord();

           	try
            {
            	String id;
            	
            	if (statistic.id != null)
            	{
            		American_Spaces_Statistic__c assc = [SELECT Name_of_Space__c FROM American_Spaces_Statistic__c WHERE id = :statistic.id];
            		id = assc.Name_of_Space__c;
            		
            	}
            	else
	           	{
	           		id = ApexPages.currentPage().getParameters().get( 'spaceId' );
	           	}
	           		
	       		American_Spaces_Contact__c aspc = [SELECT Managing_Post_City__c, country__c FROM American_Spaces_Contact__c WHERE id = :id];
	       		statistic.Name_of_Space__c = aspc.id;
	       		isModifiable = AmericanSpacesAccess.hasAccess( aspc.Managing_Post_City__c, aspc.Country__c );
            }
            catch (Exception e)
            {
            	// This method is running on the photo page...                    	 
            }
        }            
    }

    
    public American_Spaces_Statistic__c getStatistic()
    {
        return statistic;
    }
    public void setStatistic( American_Spaces_Statistic__c statistic )
    {
    	this.statistic = statistic;
    }
        
    
    public PageReference save()
    {
    	PageReference returningPage = null;
    
    	if (std != null)
    	{    	
			std.save();
			
			statistic = (American_Spaces_Statistic__c) std.getRecord();
    	}
    	
		Id id = [SELECT Name_of_Space__r.id FROM American_Spaces_Statistic__c WHERE id = :getStatistic().id].Name_of_Space__r.id;
		returningPage = new PageReference( '/' + id );
   	
	    return returningPage;
    }
	
	
	public PageReference deleteTheRecord()
    {
    	Id id = [SELECT Name_of_Space__r.id FROM American_Spaces_Statistic__c WHERE id = :getStatistic().id].Name_of_Space__r.id;
    	PageReference returningPage = new PageReference( '/' + id );
    	
    	delete statistic;
    	
        return returningPage;
	}
	
	
	public boolean getIsModifiable()
    {
    	return isModifiable;
    }
    
    public boolean getIsDeletable()
    {
    	String myPermissionset = GLOBAL_Library.getPermissionset( Userinfo.getName(), 'American_Spaces_Statistic__c' );

    	if (myPermissionset != 'American Spaces Washington')
    	{
    		Id userID = [SELECT CreatedById FROM American_Spaces_Statistic__c WHERE id = :getStatistic().id].CreatedById;
    		
    		if (userID != UserInfo.getUserId())
    		{
    			return false;
    		}
    	}
    	
    	return true;
    }
    
    
    public static testMethod void testAmericanSpacesStatistics()
    {             
        Test.startTest();
        
        American_Spaces_Post_Contacts__c aspc = new American_Spaces_Post_Contacts__c( Name='test' );
        insert aspc;
        
        American_Spaces_Contact__c ascc = new American_Spaces_Contact__c( Name='test', Managing_Post_City__c=aspc.id );
        insert ascc;
        
        American_Spaces_Statistic__c testRecord = new American_Spaces_Statistic__c( Name_of_Space__c=ascc.id );
        insert testRecord;
        
        AmericanSpacesStatistics acv = new AmericanSpacesStatistics( null );
        
        acv.setStatistic( testRecord ); 
        System.assertEquals( acv.getStatistic(), testRecord );          
        System.assertEquals( acv.save().getUrl(), new PageReference( '/' + ascc.id ).getUrl());
        System.assertEquals( acv.getIsModifiable(), false );
        acv.getIsDeletable();
        acv.deleteTheRecord();        
    }
}
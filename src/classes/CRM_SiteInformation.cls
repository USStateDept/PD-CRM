public class CRM_SiteInformation
{
    public ApexPages.StandardController std{get; set;}
    public Site_Information__c siteInformation{get; set;}


    public CRM_SiteInformation( ApexPages.StandardController stdCtrl )
    {
        std = stdCtrl;
        if (!Test.isRunningTest())
        {       
            siteInformation = (Site_Information__c) std.getRecord();
        }            
    }

    
    public PageReference save()
    {
    	PageReference returningPage = null;
    
    	if (std != null)
    	{    	
			std.save();
			
			siteInformation = (Site_Information__c) std.getRecord();
    	}
    	
		Id id = [SELECT City__r.id FROM Site_Information__c WHERE id = :siteInformation.id].City__r.id;
		returningPage = new PageReference( '/' + id );
   	
	    return returningPage;
    }

    
    public static testMethod void testCRM_SiteInformation()
    {             
        Test.startTest();
        Embassy_Contacts__c ecRecord = new Embassy_Contacts__c( First_Name_x__c='test', Middle_Name_x__c='test', Last_Name_x__c='test', Job_Title_x__c='test', Phone_Work_x__c='test', Email_Work_x__c='test@test.com' );
    	insert ecRecord;
        
        Site_Information__c testRecord = new Site_Information__c( name='test', city__c=ecRecord.id );
        insert testRecord;
        
        User u3 = [SELECT Id FROM User WHERE name like 'Integrator Functional%' LIMIT 1];
    	
        System.RunAs( u3 )
    	{
    		ApexPages.StandardController sc = new ApexPages.StandardController( testRecord );
        	CRM_SiteInformation acv = new CRM_SiteInformation( sc );
        	
        	System.assertEquals( '/' + ecRecord.id, acv.save().getURL() );
    	}
        
        Test.stopTest();
    }  
}
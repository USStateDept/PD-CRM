public class CRM_UpdateService
{
    public ApexPages.StandardController std{get; set;}
    public Update_Services_History__c updateService{get; set;}


    public CRM_UpdateService( ApexPages.StandardController stdCtrl )
    {
        std = stdCtrl;
        if (!Test.isRunningTest())
        {       
            updateService = (Update_Services_History__c) std.getRecord();
        }            
    }

    
    public Update_Services_History__c getUpdateService()
    {
        return updateService;
    }
    public void setUpdateService( Update_Services_History__c updateService )
    {
    	this.updateService = updateService;
    }
        
    
    public PageReference save()
    {
    	PageReference returningPage = null;
    
    	if (std != null)
    	{    	
			std.save();
			
			updateService = (Update_Services_History__c) std.getRecord();
    	}
    	
		Id id = [SELECT City__r.id FROM Update_Services_History__c WHERE id = :updateService.id].City__r.id;
		returningPage = new PageReference( '/' + id );
   	
	    return returningPage;
    }

    
    public static testMethod void testCRM_UpdateService()
    {             
        Test.startTest();
        Embassy_Contacts__c ecRecord = new Embassy_Contacts__c( First_Name_x__c='test', Middle_Name_x__c='test', Last_Name_x__c='test', Job_Title_x__c='test', Phone_Work_x__c='test', Email_Work_x__c='test@test.com' );
    	insert ecRecord;
        
        Update_Services_History__c testRecord = new Update_Services_History__c( city__c=ecRecord.id );
        insert testRecord;
        
        CRM_UpdateService acv = new CRM_UpdateService( null );
        
        acv.setUpdateService( testRecord ); 
        System.assertEquals( acv.getUpdateService(), testRecord );          
        System.assertEquals( acv.save().getUrl(), new PageReference( '/' + ecRecord.id ).getUrl());
    }  
}
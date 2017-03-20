public class CRM_SpecialEvent
{
    public ApexPages.StandardController std{get; set;}
    public Special_Event_Services_History__c specialEventServices{get; set;}

    public CRM_SpecialEvent( ApexPages.StandardController stdCtrl )
    {
        std = stdCtrl;
        
        if (std != null)
        {       
            specialEventServices = (Special_Event_Services_History__c) std.getRecord();
        }            
    }
    
    
    public PageReference save()
    {
		upsert specialEventServices;
	    return new PageReference( '/' + specialEventServices.City__c );
    }

    
    public static testMethod void testCRM_SpecialEvent()
    {             
        Test.startTest();
        Embassy_Contacts__c ecRecord = new Embassy_Contacts__c( First_Name_x__c='test', Middle_Name_x__c='test', Last_Name_x__c='test', Job_Title_x__c='test', Phone_Work_x__c='test', Email_Work_x__c='test@test.com' );
    	insert ecRecord;
        
    	Date fromDate =  Date.newInstance(2008,12,2);
    	Date toDate = Date.newInstance(2008,12,4);
    	
        Special_Event_Services_History__c testRecord = new Special_Event_Services_History__c( city__c=ecRecord.id );
        
        testRecord.From_Date__c = fromDate;
        testRecord.To_Date__c = toDate;
        
        insert testRecord;
        
        User u3 = [SELECT Id FROM User WHERE name like 'Integrator Functional%' LIMIT 1];
    	
        System.RunAs( u3 )
    	{
    		ApexPages.StandardController sc = new ApexPages.StandardController( testRecord );
    		CRM_SpecialEvent acv = new CRM_SpecialEvent( sc );
	        System.assertEquals( '/' + ecRecord.id, acv.save().getUrl() );
    	}
        
        Test.stopTest();
    }  
}
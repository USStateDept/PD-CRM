public with sharing class CONX_DataImport
{
    public CONX_DataImport(){}
    
    public void processDataRestore()
    {
        for (CONX_Program_Request__c program : [SELECT id, Language__c FROM CONX_Program_Request__c])
        {
        	if (program.Language__c != null)
            {
            	List<CONX_Language__c> oldLangs = [SELECT id FROM CONX_Language__c WHERE CONX_Program_Request__c = :program.id];
            	delete oldLangs;	
            
	        	String[] listOfLang = program.Language__c.split( ',' );
	            	
	        	List<CONX_Language__c> langs = new List<CONX_Language__c>();
	        	
	        	for (String lang : listOfLang)
	        	{
	        		CONX_Language__c c = new CONX_Language__c();
	        		
	        		c.CONX_Program_Request__c = program.id;
	        		c.Language__c = lang;
	        		
	        		langs.add( c );
	        	}
	        	
	        	insert( langs );
            }
        }
    }
    
    
    public static testMethod void CONX_DataImport()
    {             
        Test.startTest();
        
        CONX_Program_Request__c crc = new CONX_Program_Request__c( Language__c='English', Program_Titles__c='test', status__c='Archive', End_Time__c='00:test', Washington_End_Time__c='00:test', Washington_Start_Time__c='00:test', Start_EDT_UTC_Local__c='00:test', Target_Country__c='United States',Date_of_Program__c=date.today(), Requestor_Last_Name__c='test',Requestor_First_Name__c='test', Requestor_Email_Work__c='test@test.com', Source_of_Request__c='Test', Target_Region__c='AF');
        insert crc;
        
        CONX_DataImport cdi = new CONX_DataImport();
        cdi.processDataRestore();
    }
}
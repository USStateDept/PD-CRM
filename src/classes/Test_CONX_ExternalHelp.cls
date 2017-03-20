@isTest
public class Test_CONX_ExternalHelp {
    
    public static testMethod void TESTCONX_ExternalHelp()
    {             
        Test.startTest();
        
        PermissionSet ps = [SELECT ID From PermissionSet WHERE Label = 'CONX Project Coordinator'];
        User u3 = [SELECT Id FROM User WHERE name like 'Integrator Functional%' LIMIT 1];
        PermissionSetAssignment PSAssignment;
        
        List<PermissionSetAssignment> psaList = [SELECT Id,PermissionSetId FROM PermissionSetAssignment WHERE PermissionSetId = :ps.ID AND AssigneeId = :u3.id];
        if(psaList != null && psaList.size() > 0)
        {
        	PSAssignment = psaList.get(0);    
        }
        else
        {   
        	PSAssignment = new PermissionSetAssignment(AssigneeId = u3.id, PermissionSetId = ps.ID );
            insert( PSAssignment );   
        }
    	
    	System.RunAs(u3)
    	{
	        CONX_Help_Request__c crc1 = new CONX_Help_Request__c( Program_Date_Time__c=date.today(), Body__c = 'test',Requestor_Email__c='test@test.com' );
	        CONX_Help_Request__c crc2 = new CONX_Help_Request__c( Program_Date_Time__c=date.today(), Body__c = 'test',Requestor_Email__c='test@test.com' );
	        
	        List<CONX_Help_Request__c> testList = new List<CONX_Help_Request__c>();
	        testList.add( crc1 );
	        testList.add( crc2 );
	        
	        CONX_ExternalHelp.processHelpRequest( testList );
    	}
        
        Test.stopTest();
    }
    
    public static testMethod void TEST_One_CONX_ExternalHelp()
    {
        Test.startTest();
        
        PermissionSet ps = [SELECT ID From PermissionSet WHERE Label = 'CONX Project Coordinator'];
        User u3 = [SELECT Id FROM User WHERE name like 'Integrator Functional%' LIMIT 1];
        PermissionSetAssignment PSAssignment;
        
        List<PermissionSetAssignment> psaList = [SELECT Id,PermissionSetId FROM PermissionSetAssignment WHERE PermissionSetId = :ps.ID AND AssigneeId = :u3.id];
        if(psaList != null && psaList.size() > 0)
        {
        	PSAssignment = psaList.get(0);    
        }
        else
        {   
        	PSAssignment = new PermissionSetAssignment(AssigneeId = u3.id, PermissionSetId = ps.ID );
            insert( PSAssignment );   
        }

        System.RunAs(u3)
    	{
            CONX_Help_Request__c crc1 = new CONX_Help_Request__c( Program_Date_Time__c=date.today(), Body__c = 'test',Requestor_Email__c='test@test.com' );
            
            List<CONX_Help_Request__c> testList = new List<CONX_Help_Request__c>();
	        testList.add( crc1 );
            
            CONX_ExternalHelp.processHelpRequest( testList );
        }
		Test.stopTest();        
    }
}
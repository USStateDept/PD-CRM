@isTest
public class Test_CONX_ExternalRequest {
    
 
    public static testMethod void CONX_ExternalRequest()
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
            CONX_Program_Request__c crc1 = new CONX_Program_Request__c( Program_Titles__c='test', status__c='Archive', Languages__c='English', Start_EDT_UTC_Local__c='test', Request_Country__c='United States',Date_of_Program__c=date.today(), Requestor_Last_Name__c='test',Requestor_First_Name__c='test', Requestor_Email_Work__c='test@test.com', Source_of_Request__c='false', Request_Post__c='false', Target_Post__c='false', Request_Region__c='AF');
            CONX_Program_Request__c crc2 = new CONX_Program_Request__c( Program_Titles__c='test', status__c='Archive', Languages__c='false', Start_EDT_UTC_Local__c='test', Request_Country__c='Choose one',Date_of_Program__c=date.today(), Requestor_Last_Name__c='test',Requestor_First_Name__c='test', Requestor_Email_Work__c='test@test.com', Source_of_Request__c='test', Request_Region__c='Choose one',Request_Post__c='Accra',
                                                                       Target_Region__c='Choose one',Target_Country__c='Choose one',Themes__c='Choose one',Speaker_1_Location__c='Choose one',Target_Post__c='test\'s Stephanie',Program_Goal_s__c='test',Notes__c='test notes',Target_Audiences__c='false');
            
            CONX_Program_Request__c crc3 = new CONX_Program_Request__c(Program_Titles__c='tester',status__c='Archive', Languages__c='English',Start_EDT_UTC_Local__c='test', Request_Country__c='United States',Requestor_Last_Name__c='test',Requestor_First_Name__c='test', Requestor_Email_Work__c='test@test.com', 
                                                                       Source_of_Request__c='false', Request_Post__c='false', Target_Post__c='false', Request_Region__c='AF',
                                                                      Speaker_1_First_Name__c='speaker1',Speaker_2_First_Name__c='speaker2',Speaker_3_First_Name__c='speaker3',Speaker_4_First_Name__c='speaker4',Speaker_5_First_Name__c='speaker5',
                                                                      Target_Audiences__c='Academics');
            List<CONX_Program_Request__c> testList = new List<CONX_Program_Request__c>();
            testList.add( crc1 );
            testList.add( crc2 );
            testList.add( crc3 );
            
            CONX_ExternalRequest.programRequestHandler( testList );
        }
        Test.stopTest();
    }
    
    public static testMethod void One_CONX_ExternalRequest()
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
            CONX_Program_Request__c crc1 = new CONX_Program_Request__c( Program_Titles__c='test', status__c='Archive', Languages__c='English', Start_EDT_UTC_Local__c='test', Request_Country__c='United States',Date_of_Program__c=date.today(), Requestor_Last_Name__c='test',Requestor_First_Name__c='test', Requestor_Email_Work__c='test@test.com', Source_of_Request__c='false', Request_Post__c='false', Target_Post__c='false', Request_Region__c='AF');
            List<CONX_Program_Request__c> testList = new List<CONX_Program_Request__c>();
            testList.add(crc1);
            
            CONX_ExternalRequest.programRequestHandler(testList);
        }
        Test.stopTest();
    }
}
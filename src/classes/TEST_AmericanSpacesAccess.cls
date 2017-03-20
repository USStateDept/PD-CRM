@isTest
public class TEST_AmericanSpacesAccess
{
	static testMethod void hasAccess()
	{
		
		American_Spaces_Post_Contacts__c aspc = new American_Spaces_Post_Contacts__c( Name='test' );
        insert aspc;
        
        User u3 = [SELECT Id FROM User WHERE name = 'Integrator Functional' LIMIT 1];
        
        PermissionSet ps = [SELECT ID From PermissionSet WHERE Label = 'American Spaces Washington'];
        //PermissionSetAssignment PSAssignment = new PermissionSetAssignment(AssigneeId = u3.id, PermissionSetId = ps.ID );
        //Stephanie P. (6/17/14) - Check if this assignment doesn't exist, then insert; otherwise, ignore
        /*
        PermissionSetAssignment PSAssignment = [SELECT Id,PermissionSetId,AssigneeId From PermissionSetAssignment WHERE AssigneeId = :u3.id AND PermissionSetId = :ps.ID];
        if(PSAssignment == null) {
            PSAssignment = new PermissionSetAssignment(AssigneeId = u3.id, PermissionSetId = ps.ID );
        	insert( PSAssignment );
        }
        */
        //Stephanie P. (8/21/14) - The configuration in full copy has been reset after refresh from production.
        //This means all configuration that has been configured, they're all gone.
        PermissionSetAssignment PSAssignment;
        List<PermissionSetAssignment> psaList = [SELECT Id,PermissionSetId FROM PermissionSetAssignment WHERE PermissionSetId = :ps.ID AND AssigneeId = :u3.id];
        if(psaList != null && psaList.size() > 0)
        {
        	PSAssignment = psaList.get(0);    
        }
        else
        {   
        	PSAssignment = new PermissionSetAssignment(AssigneeId = u3.id, PermissionSetId = ps.ID );
            System.runAs(u3) {
            	insert( PSAssignment );                   
            }
        }
        
		Test.startTest();
        /*
         System.RunAs(u3)
    	{
    		System.assertEquals( true, AmericanSpacesAccess.hasAccess( aspc.id, 'test' ));
    		System.assertEquals( true, AmericanSpacesAccess.hasDeleteAccess());
    	}
		*/
        System.runAs(u3)
        {
    		delete PSAssignment;            
        }
    	
    	ps = [SELECT ID From PermissionSet WHERE Label = 'American Spaces Manager'];
        PSAssignment = new PermissionSetAssignment(AssigneeId = u3.id, PermissionSetId = ps.ID );
        System.RunAs(u3)
    	{
        	insert( PSAssignment );
        }
        
        System.RunAs(u3)
    	{
    		IRO_Contacts__c myIROContact = new IRO_Contacts__c( First_Name__c='Integrator', last_name__c='Functional', Home_Post__c=aspc.id );
    		insert myIROContact;
    		
    		//System.assertEquals( true, AmericanSpacesAccess.hasAccess( aspc.id, 'test' ));
    		//System.assertEquals( false, AmericanSpacesAccess.hasDeleteAccess());
    	}
    	
    	ps = [SELECT ID From PermissionSet WHERE Label = 'American Spaces Editor'];
        PSAssignment = new PermissionSetAssignment(AssigneeId = u3.id, PermissionSetId = ps.ID );
        System.RunAs(u3)
    	{
        	insert( PSAssignment );
        }
        
        System.RunAs(u3)
    	{
    		American_Spaces_Mission_Contact__c myAmSpacesMissContact = new American_Spaces_Mission_Contact__c( First_Name__c='Integrator', last_name__c='Functional', Managing_Post_City__c=aspc.id );
    		insert myAmSpacesMissContact;
    		
    		//System.assertEquals( true, AmericanSpacesAccess.hasAccess( aspc.id, 'test' ));
    	}
    	
    	Test.stopTest();
	}	
}
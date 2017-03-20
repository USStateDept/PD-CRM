@isTest
public class TEST_AmericanSpacesBranch
{
	public static testMethod void testAmericanSpacesContacts()
    {             
        Test.startTest();
        
        American_Spaces_Post_Contacts__c aspc = new American_Spaces_Post_Contacts__c( Name='test' );
        insert aspc;
        
        American_Spaces_Contact__c asccc = new American_Spaces_Contact__c( Name='test', Managing_Post_City__c=aspc.id );
        insert asccc;
        
        American_Space_Branch__c ascc = new American_Space_Branch__c( Name_of_Space__c=asccc.id );
        insert ascc;
        
        Attachment doc = new Attachment( name='testImg.png', parentId=ascc.Id, body=Blob.valueOf('Test Blob String') );
        insert doc;
        
        American_Spaces_Notes_and_Attachments__c asna = new American_Spaces_Notes_and_Attachments__c( Name='test', Document_ID__c=doc.id, object_ID__c=ascc.id );
        insert asna;

        ApexPages.StandardController sc = new ApexPages.StandardController( ascc );
        AmericanSpacesBranch amsc = new AmericanSpacesBranch( sc );
        
        amsc.setAmericanSpacesBranch( ascc );
        System.assertEquals( ascc, amsc.getAmericanSpacesBranch() );
        
        System.assertEquals( 1, amsc.getAttachments().size() );

        amsc.newAttachment();

        amsc.attachmentNumber = 1;
        amsc.deleteAttachment();
        System.assertEquals( 1, amsc.getAttachments().size() );
        System.assertEquals( 0, amsc.getCurrentattachments().size() );
        System.assertEquals( true, amsc.updateAmericanSpaceContact( true ));
        
        System.assertEquals( '/' + asccc.id, amsc.save().getUrl() );
        System.assertEquals( '/' + asccc.id, amsc.cancel().getUrl() );
        
        System.assertEquals( '/' + asccc.id, amsc.deleteTheRecord().getUrl() );
        
        PermissionSet ps = [SELECT ID From PermissionSet WHERE Label = 'American Spaces Washington'];
        User u3 = [SELECT Id FROM User WHERE name like 'Integrator Functional%' LIMIT 1];
        //PermissionSetAssignment PSAssignment = new PermissionSetAssignment(AssigneeId = u3.id, PermissionSetId = ps.ID );
        //Stephanie P. (6/17/14) - Check if this assignment doesn't exist, then insert; otherwise, ignore
        /*
        PermissionSetAssignment PSAssignment = [SELECT Id From PermissionSetAssignment WHERE AssigneeId = :u3.id AND PermissionSetId = :ps.ID];
        if(PSAssignment == null)  {    
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
            System.runAs(u3)
            {
            	insert( PSAssignment );   
            }
        }
        /*
        System.RunAs(u3)
        {
        	System.assertEquals( true, amsc.getIsDeletable() );
        }
		*/
    }
    
    
    public static testMethod void testAmericanSpacesContacts2()
    {             
        Test.startTest();
        
        American_Spaces_Post_Contacts__c aspc = new American_Spaces_Post_Contacts__c( Name='test' );
        insert aspc;
        
        American_Spaces_Contact__c asccc = new American_Spaces_Contact__c( Name='test', Managing_Post_City__c=aspc.id );
        insert asccc;
        
        American_Space_Branch__c ascc = new American_Space_Branch__c( Name_of_Space__c=asccc.id );

        ApexPages.currentPage().getParameters().put( 'spaceID', asccc.id );
        
        ApexPages.StandardController sc = new ApexPages.StandardController( ascc );
        AmericanSpacesBranch amsc = new AmericanSpacesBranch( sc );

		amsc.newAttachment();
		
		PermissionSet ps = [SELECT ID From PermissionSet WHERE Label = 'American Spaces Washington'];
        User u3 = [SELECT Id FROM User WHERE name like 'Integrator Functional%' LIMIT 1];
        //PermissionSetAssignment PSAssignment = new PermissionSetAssignment(AssigneeId = u3.id, PermissionSetId = ps.ID );
        //Stephanie P. (6/17/14) - Check if this assignment doesn't exist, then insert; otherwise, ignore
        /*
        PermissionSetAssignment PSAssignment = [SELECT Id From PermissionSetAssignment WHERE AssigneeId = :u3.id AND PermissionSetId = :ps.ID];
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
            System.runAs(u3)
            {
            	insert( PSAssignment );                  
            }
        }
        /*
        System.RunAs(u3)
        {
        	System.assertEquals( true, amsc.getIsModifiable() );
        }
		*/
        System.assertEquals( true, amsc.updateAmericanSpaceContact( true ));
    }
}
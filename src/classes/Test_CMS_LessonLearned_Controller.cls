@isTest
public class Test_CMS_LessonLearned_Controller {

    public static testMethod void testPM_CMS_LessonLearned_Controller() {
        PermissionSetAssignment PSAssignment;
        CMS_LessonLearned_Controller llController;
        
        User u3 = [SELECT Id, name FROM User WHERE name like 'Integrator Functional%' LIMIT 1];
        
        // Testing Project Manager
    	PermissionSet ps = [SELECT ID From PermissionSet WHERE Label = 'CMS Project Manager'];

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
        
        Test.startTest();

        System.runAs(u3) {
            ApexPages.StandardController sc = new ApexPages.StandardController( new CMS_Lesson_Learned__c() );
            llController = new CMS_LessonLearned_Controller(sc);            
        }

        Test.stopTest();
        
        Boolean isEditable = llController.editable;
        Boolean isReadOnly = llController.readOnly;
		String permissionSet = llController.myPermissionset;
        
        //System.assertEquals(true, isEditable);
        //System.assertEquals(false, isReadOnly);  

    }
    
   	public static testMethod void testCMBasic_CMS_LessonLearned_Controller() {
        PermissionSetAssignment PSAssignment;
        CMS_LessonLearned_Controller llController;
        
        User u3 = [SELECT Id, name FROM User WHERE name like 'Integrator Functional%' LIMIT 1];
        
        // Testing Project Manager
    	PermissionSet ps = [SELECT ID From PermissionSet WHERE Label = 'CMS Basic'];

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
        
        Test.startTest();

        System.runAs(u3) {
            ApexPages.StandardController sc = new ApexPages.StandardController( new CMS_Lesson_Learned__c() );
            llController = new CMS_LessonLearned_Controller(sc);            
        }

        Test.stopTest();
        
        Boolean isEditable = llController.editable;
        Boolean isReadOnly = llController.readOnly;
		String permissionSet = llController.myPermissionset;
        
        System.assertEquals(false, isEditable);
        System.assertEquals(true, isReadOnly);  

    }
 }
@isTest
public class TEST_FolderController
{
		public static testmethod void FolderController()
		{
			PermissionSet ps = [SELECT ID From PermissionSet WHERE Label = 'Folder_Manager'];
	        User u = [SELECT Id FROM User WHERE name like 'Integrator Functional%' LIMIT 1];
	        PermissionSetAssignment PSAssignment = new PermissionSetAssignment( AssigneeId = u.id, PermissionSetId = ps.ID );
	
			test.startTest();
	   		System.runAs(u) 
	   		{
	   			Folder__c myFolder = new Folder__c();
	   			myFolder.name = 'testing folder';
	   			insert myFolder;
	   			
	   			File__c myFile = new File__c();
	   			myFile.name = 'testing';

	   			ApexPages.currentPage().getParameters().put( 'parentID', myFolder.id );
	   			
	   			ApexPages.StandardController sc = new ApexPages.StandardController( myFile );
	   			
	   			Folder_Controller myController = new Folder_Controller( sc );
	   			
	   			System.assertEquals( 0, myController.getMyFolderFiles().size() );
	   			myController.fileName = 'test';
	   			myController.fileType = 'pdf';
	   			myController.isNotInFile = true;
	   			System.assertEquals( 0, myController.getAvailableFiles().size() );
	   			
	   			myController.isNotInFile = false;
	   			System.assertEquals( 0, myController.getAvailableFiles().size() );
	   			
	   			System.assertEquals( null, myController.refresh() );
	   			System.assertEquals( '/' + myFolder.id, myController.saveMe().getUrl() );

	   			Folder_Controller.ContentDoc myContentDoc = new Folder_Controller.ContentDoc( new ContentDocument() );
	   			
	   		}
	   		test.stopTest();
		}
}
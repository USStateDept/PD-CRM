/**
	 * Test for COMP_Notify_Emails2 class 
	 *
	 * <p>The class being tested assembles published articles for a compilation email via batch apex</p>
	 */
@isTest
private class COMP_Notify_Emails2_Test {
    
	static testMethod void scheduleTest()
	{
		Blob file = Blob.valueOf( '' );
		Folder newFolder = [Select Id From Folder WHERE name = 'Shared Documents' limit 1];
		Document newDoc = new Document( name='Compilation Attachment',  Keywords='Compilation Attachment', Description='Compilation Attachment', body=file, folderId=newFolder.id );
		insert newDoc;
	
		Test.startTest();
		COMP_NotifyEmails2 sched = new COMP_NotifyEmails2();
		//COMP_NotifyEmails sched = new Comp_NotifyEmails();
		Id job_id = System.schedule('test','0 0 0 30 12 ? 2099', sched);
		//Id job_id = System.schedule('test', '0 0 0 30 12 ? 2099', sched);
		System.assertNotEquals(null,job_id);
		Test.stopTest();
	}

	static testmethod void testCOMP_NotifyEmails2()
	{
		list<Digital_Asset__c> testAssets = DA_Test_Helper.createDigitalAssets(4,null);
		system.debug('DEBUG:: testAssets: '+ testAssets);
		list<Digital_Asset__c> testAssetsforInsert = new list<Digital_Asset__c>();
		integer i = 0;
		for(Digital_Asset__c da: testAssets)
		{
			//0: english, publication
			//1: english, toc
			//2: spanish, publication
			//3: english, note to posts
			
			da.Name = 'Some headline' + i;
			da.Language__c = 'English';
			if(i==2)
				da.Language__c = 'Spanish';
				
			da.Asset_Type__c='Publication';
			if(i==1)
			{
				da.Asset_Type__c = 'Table of Contents';
			}
			if(i==3)
				da.Asset_Type__c = 'Note to Posts';
				
			da.Asset_Subtype__c = 'Internal Use Only';
			da.Status__c = 'Published';
			da.Include_In_Compilation__c = true;
			da.Post_Date__c = DateTime.now();
			da.Asset_Date_Time__c = DateTime.now();
			da.Top__c = 'The Top Field';
			testAssetsforInsert.add(da);
			i++;
		}

		insert testAssets;
		
		list<Digital_Asset__c> compAssets = COMP_NotifyEmails2.getCompilationAssets();
		system.assertEquals(compAssets.size(), 4);
		
		Document newDoc = DA_Test_Helper.createCompilationAttachment();
		insert newDoc;
		
		//since it is a static/void method, nothing returned to assert 
		COMP_NotifyEmails2.send_Compilation_Emails();
	
	}
    
}
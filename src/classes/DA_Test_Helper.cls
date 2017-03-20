global class DA_Test_Helper 
{
   	 /**
	 * These are helper methods for test classes creating/editing Digital_Asset__c records
	 *
	 * <p>Creates an Digital_Asset__c record for a test case that can be used throughout the State dept. Salesforce APEX development. 
	 * The developer can pass an integer to indicate how many records to create.</p>
	 *
	 * <p>This implementation will return a list of Digital_Asset__c.</p>
	 * 
	 * @param Integer Number of records to create
	 * 
	 */
	global static list<Digital_Asset__c> createDigitalAssets (integer iQty, map<String,String> mFieldVals)
	{
		list<Digital_Asset__c> retVals = new list<Digital_Asset__c>();
		
		for(integer i=0; i<iQty; i++)
		{	
			Digital_Asset__c da = (Digital_Asset__c)GLOBAL_Library.createObj('Digital_Asset__c', mFieldVals);
			retVals.add(da);
		}
		
		return retVals; 	
	}
	
	global static Profile getProfile (string ProfileName)
	{
		Profile retVal = [SELECT Id FROM Profile WHERE Name=: ProfileName LIMIT 1]; 
		return retVal;
	}
	
	global static QueueSobject getQueue (string QueueName)
	{
		QueueSobject retVal = [SELECT q.QueueId FROM QueueSobject q WHERE q.Queue.Name =: QueueName LIMIT 1];
		return retVal;
	}
	
	//this does not use the createObj method because of an error related to isPortalEnabled attribute on user
	global static User createUserWithoutProfile()
	{
		User retVal = new User(Alias = 'standt', Email='standarduser8675309@testorg.com', 
							EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
							LocaleSidKey='en_US', TimeZoneSidKey='America/Los_Angeles');
		return retVal;
	}
	
	global static Document createCompilationAttachment()
	{
		Blob file = Blob.valueOf( '' );
		Folder newFolder = [Select Id From Folder WHERE name = 'Shared Documents' limit 1];
		Document retVal = new Document( name='Compilation Attachment',  Keywords='Compilation Attachment', Description='Compilation Attachment', body=file, folderId=newFolder.id );
		return retVal;
		
	}
 

}
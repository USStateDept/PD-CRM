/**
	 * Test for DA_Email.cls  
	 *
	 * <p>Confirms functionality for sending notification emails via Send Email button</p>
	 */
@isTest
private class DA_Email_Test {

    private static Digital_Asset__c createDigitalAsset()
    {
    	Digital_Asset__c retVal = (Digital_Asset__c)GLOBAL_Library.createObj('Digital_Asset__c', null);
    	retVal.Article_Body__c = 'Sample Body Text 123';
        retVal.Language__c = 'English';
    	insert retVal;
    	return retVal;
    }
    
    private static DA_Email setupController()
    {
    	Digital_Asset__c testasset = createDigitalAsset();

	    PageReference pageRef = Page.DA_Email;
	
	   	Test.setCurrentPage(pageRef);
	   	
	    ApexPages.StandardController sc = new ApexPages.standardController(testasset);
		
		// Add parameters to page URL
		ApexPages.currentPage().getParameters().put('reqType', 'Generic');
		ApexPages.currentPage().getParameters().put('Id',testasset.Id);
		DA_Email retVal = new DA_Email(sc);
		retVal.dId = testasset.Id;
		return retVal;
    }
    
    static testMethod void testSendVideoEmail() 
	{
	
		Digital_Asset__c testasset = createDigitalAsset(); 
        	
	    PageReference pageRef = Page.DA_Email;
	
	   	Test.setCurrentPage(pageRef);
	   	
	    ApexPages.StandardController sc = new ApexPages.standardController(testasset);
		
		// Add parameters to page URL
		ApexPages.currentPage().getParameters().put('reqType', 'Video');
		ApexPages.currentPage().getParameters().put('Id',testasset.Id);
		DA_Email controller = new DA_Email(sc);
		
		      
		// Instantiate a new controller with all parameters in the page
		controller.dId = testasset.Id;
		controller.userEmail = 'somesender@sometestdomain.test';
		controller.emailTo = 'someuser@domain.test, someotheruser@domain.test';
		controller.emailCC = 'someuser2@domain.test';
		controller.emailSubject = 'some subject';
		controller.emailBody = 'hello world';
		controller.reqType = 'Video';
		controller.sendEmail();
		
		string response = controller.response;
		// Verify that the success page displays
		//System.assertEquals(DA_Email.EMAIL_SENT_SUCCESS_MSG, response);

	}


	static testMethod void testSendPhotoEmail2() 
	{
		Digital_Asset__c testasset = createDigitalAsset();
	
	    PageReference pageRef = Page.DA_Email;
	
	   	Test.setCurrentPage(pageRef);
	   	
	    ApexPages.StandardController sc = new ApexPages.standardController(testasset);
		
		// Add parameters to page URL
		ApexPages.currentPage().getParameters().put('reqType', 'photo');
		ApexPages.currentPage().getParameters().put('Id',testasset.Id);
		DA_Email controller = new DA_Email(sc);
		
		      
		// Instantiate a new controller with all parameters in the page
		controller.dId = testasset.Id;
		controller.emailTo = 'someuser@domain2.test, someotheruser2@domain.test';
		controller.emailCC = 'someuser2@domain2.test';
		controller.emailSubject = 'some very long subject 0123456789 0123456789 0123456789 0123456789 0123456789 0123456789 0123456789 0123456789 0123456789 0123456789';
		controller.emailBody = 'hello world';
		controller.reqType = 'Video';
		controller.addComments = 'Some additional comments';
		controller.sendEmail2();
		
		string response = controller.response;
		// Verify that the success page displays
		System.assertEquals(DA_Email.EMAIL_SENT_SUCCESS_MSG, response);

	}
	
	static testMethod void testNegativeScenariosSendEmail()
	{
		// Instantiate a new controller with all parameters in the page except subject and To; should generate an error
		DA_Email controller = setupController();
		controller.emailTo = '';
		controller.emailCC = 'someuser2@domain2.test';
		controller.emailSubject = 'some subject';
		controller.emailBody = '';
		controller.reqType = 'Video';
		controller.sendEmail();
		
		string response = controller.response;
		// Verify that the success page displays
		System.assertNotEquals(DA_Email.EMAIL_SENT_SUCCESS_MSG, response);
		System.assertEquals(ApexPages.hasMessages(),true);
	}
	
	static testMethod void testNegativeScenariosSendEmail2()
	{
		// Instantiate a new controller with all parameters in the page except subject and To; should generate an error
		DA_Email controller = setupController();
		controller.emailTo = '';
		controller.emailCC = 'someuser2@domain2.test';
		controller.emailSubject = 'some subject';
		controller.emailBody = '';
		controller.reqType = 'Video';
		controller.sendEmail2();
		
		string response = controller.response;
		// Verify that the success page displays
		System.assertNotEquals(DA_Email.EMAIL_SENT_SUCCESS_MSG, response);
		System.assertEquals(ApexPages.hasMessages(),true);
	}
	
	static testMethod void testBodyCreation()
	{
		Digital_Asset__c testasset = createDigitalAsset();

	    PageReference pageRef = Page.DA_Email;
	
	   	Test.setCurrentPage(pageRef);
	   	
	    ApexPages.StandardController sc = new ApexPages.standardController(testasset);
		
		// Add parameters to page URL
		ApexPages.currentPage().getParameters().put('reqType', 'Generic');
		ApexPages.currentPage().getParameters().put('Id',testasset.Id);
		DA_Email controller = new DA_Email(sc);
		
		      
		// Instantiate a new controller with all parameters in the page
		controller.dId = testasset.Id;
		
		string determineBody = DA_Email.determineBody(DA_Email.EMAIL_GENERIC_TYPE);
		system.assertEquals(determineBody,DA_NotifyGeneric.getNotifyGenericMessage());
		
	}
	
	static testMethod void testOtherClassMethods()
	{

		string defaultTo = DA_Email.defaultTo(DA_Email.EMAIL_VIDEO_TYPE);
		system.assertEquals(defaultTo, DA_Email.EMAIL_TO_DEFAULT_VIDEO);
		
		string defaultCC = DA_Email.defaultCC(DA_Email.EMAIL_PHOTO_TYPE);
		system.assertEquals(defaultCC, DA_Email.EMAIL_CC_DEFAULT_PHOTO);
		
		string determineSubj = DA_Email.determineSubject(DA_Email.EMAIL_GENERIC_TYPE);
		system.assertEquals(determineSubj, DA_Email.EMAIL_GEN_SUBJ_PREFIX);
		
		list<string> emails = DA_Email.parseEmails('test1@test1.com,test2@test2.com,test3@test3.com');
		system.assertEquals(emails.size(), 3);
		
	}
    
    
}
/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class DA_Email_Triggers_Test {

    
    static testMethod void testSendTriggerEmail()
    {
    	Global_Variable__c gvc1 = new Global_Variable__c(Name = 'Copy_Desk_Notification_Email_Address', Value__c = 'email_test@test123.test');
    	Global_Variable__c gvc2 = new Global_Variable__c(Name = 'Copy_Desk_Notification_Enabled', Value__c = 'true');
    	
    	insert gvc1;
    	insert gvc2;
    	
    	//Digital_Asset__c testAsset = (Digital_Asset__c)GLOBAL_Library.createObj('Digital_Asset__c', null);
    	Digital_Asset__c testAsset = new Digital_Asset__c();
        //insert testAsset;
    	
    	QueueSobject q = DA_Test_Helper.getQueue('Copy Desk Queue');
    	testAsset.OwnerId = q.QueueId;
    	
    	//update testAsset;
    	
    }
    
    static testMethod void testNegativeSendTriggerEmail()
    {
    	//tests a scenario where the custom settings are missing
    	
    	string msg = 'success';
    	//Digital_Asset__c testAsset = (Digital_Asset__c)GLOBAL_Library.createObj('Digital_Asset__c', null);
    	Digital_Asset__c testAsset = new Digital_Asset__c();
    	//insert testAsset;
    	
    	QueueSobject q = DA_Test_Helper.getQueue('Copy Desk Queue');
    	testAsset.OwnerId = q.QueueId;
    	test.startTest();
        /*
    	try
    	{
    		update testAsset;
    	}
    	catch (DMLException e)
    	{
    		msg = e.getMessage();	
    		system.debug('DEBUG:: msg : ' + msg);
    		system.AssertNotEquals(msg,'success');
    		system.Assert(msg.contains(DA_Email_Triggers.CUST_SETTING_EXCEPTION_MSG));
    	}
*/
    	test.stopTest();
    }
    
    static testMethod void testsubjForCopyDeskNotification()
    {
    	string retVal = DA_Email_Triggers.subjForCopyDeskNotification('A very long string 0123456789 0123456789 0123456789 0123456789 0123456789 0123456789 0123456789 0123456789');
    	system.Assert(retVal.length() < 80);
    	
    }
    
    static testMethod void testbodyForCopyDeskNotification()
    {
    	//string retVal = DA_Email_Triggers.bodyForCopyDeskNotification((Digital_Asset__c)GLOBAL_Library.createObj('Digital_Asset__c', null), 'Joe Editor');
    	//system.AssertNotEquals(retVal,'');
    }
}
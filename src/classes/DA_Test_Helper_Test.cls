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
private class DA_Test_Helper_Test {
    
    static testmethod void testcreateDigitalAssets()
    {
    	list<Digital_Asset__c> results = DA_Test_Helper.createDigitalAssets(5,null);
    	system.assertEquals(5,results.size());
    }
    
    static testmethod void createUserWithoutProfile()
    {
    	User result = DA_Test_Helper.createUserWithoutProfile();
    	system.assertEquals(null,result.ProfileId);
    }
    
    static testmethod void testcreateCompilationAttachment()
    {
    	Document result = DA_Test_Helper.createCompilationAttachment();
    	system.assertEquals('Compilation Attachment', result.Name);
    }
    
    static testmethod void testgetProfile()
    {
    	Profile result = DA_Test_Helper.getProfile('Publishing Copy Desk');
    	system.assertNotEquals(null,result);
    }
    
    static testmethod void testgetQueue()
    {
    	QueueSobject result = DA_Test_Helper.getQueue('Copy Desk Queue');
    	system.assertNotEquals(null, result);
    }
    
}
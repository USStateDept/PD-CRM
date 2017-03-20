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
private class DA_PublishArticle_Test {

   public static string setupTest()
   {
        Test.setMock(HttpCalloutMock.class, new DA_MockHttpResponseGenerator());
        
        Global_Variable__c gvc1 = new Global_Variable__c(Name = 'XML Publishing Password', Value__c = 'password');
        Global_Variable__c gvc2 = new Global_Variable__c(Name = 'XML Publishing URL', Value__c = 'api.salesforce.com/foo/bar');
        Global_Variable__c gvc4 = new Global_Variable__c(Name = 'XML Publishing Tag URL', Value__c = 'api.salesforce.com/foo/bar');
        Global_Variable__c gvc3 = new Global_Variable__c(Name = 'XML Publishing User ID', Value__c = 'integration_user');
        
        insert gvc1;
        insert gvc2;
        insert gvc3;
        insert gvc4;
        
        //Digital_Asset__c testasset = (Digital_Asset__c)GLOBAL_Library.createObj('Digital_Asset__c', null);
        Digital_Asset__c testasset = new Digital_Asset__c();
        testasset.Status__c = 'Approved Not Published';
        testasset.Language__c = 'English';
        testasset.Parent_Slug_ID__c = null;
        testasset.Asset_Type__c = 'English';//this is done with intention due to method signature of DA_TranslateData.DetermineProclamation(Language, Subtype)
        testasset.Asset_Subtype__c = 'Transcript';
        testasset.Asset_Date_Time__c = null;
        testasset.Parent_Headline__c = null;
        testasset.Parent_Slug_ID__c = '';
        testasset.Publication_Title__c = null;
        insert testasset;
        
        return testasset.Id;
   }
   
   static testmethod void testNotifyMessage()
   {
      string retVal;
      //Digital_Asset__c testasset = (Digital_Asset__c)GLOBAL_Library.createObj('Digital_Asset__c', null);
      Digital_Asset__c testasset = new Digital_Asset__c();
      testasset.Name = 'some headline';
      testasset.Language__c = 'English';
      testasset.Asset_Type__c = 'Audio';
      testasset.Asset_Subtype__c = 'Internal Use Only';
      testasset.Headline_long__c = 'Some testing asset';
      testasset.Published_URL__c = 'www.shouldntgoanywhere.com.org.gov.edu';
      testasset.Social_Media_Blurb__c = 'some social media blurb';
      testasset.Microblog__c = 'some microblog text';
      testasset.Search_Keywords__c = 'some; super; keywords; required; field';
      
      insert testasset;
      
      retVal = DA_PublishArticle.GenerateNotifyMessage(testasset);
      system.assertNotEquals('', retVal);
      
   }
   
   static testmethod void testgetTags()
   {
        string assetId = setupTest();
        test.startTest();
        string result = DA_PublishArticle.getTags('some string');
        
        system.debug('DEBUG:: from mock: ' + result);
        test.stopTest();
   }
   
   static testmethod void testPublish()
   {
       Test.startTest();
       
       //Query current user who is running this test is a better way to make sure
       //current user is active
       User u = [SELECT id, name, isActive FROM User WHERE id = :UserInfo.getUserId()];

        //User u = DA_Test_Helper.createUserWithoutProfile();
        //u.Username = 'ok_to_publish@test.test';
        //u.id = '00530000006OGAc';
       	//insert u;
        Digital_Asset__c testasset = new Digital_Asset__c();
        testasset.OwnerID = u.Id;
        testasset.Status__c = 'Copy Desk';
        testasset.Language__c = 'Chinese';
        testasset.Parent_Slug_ID__c = null;
        testasset.Asset_Type__c = 'Article';
        testasset.Asset_Subtype__c = 'Copyrighted';
        testasset.Article_Body__c = 'This is a test asset to publish.';
        testasset.Asset_Date_Time__c = null;
        testasset.Parent_Headline__c = null;
        testasset.Parent_Slug_ID__c = '';
        testasset.Publication_Title__c = null;
        insert testasset;
        DA_PublishArticle.ActuallyPublish(testasset, u, null);
       
       Test.stopTest();
   }
    
    
   
   
   // run PublishArticle.testMe(); from Execute Anonymous to test
   /*public static testMethod void testSend()
   {
      DA_PublishArticle.sendXml('<IIP_ARTICLE><PUBLISHING_INFO><STAFF_USE_ONLY>1</STAFF_USE_ONLY><SLUG_ID><![CDATA[ salesforcetestslug ]]></SLUG_ID></PUBLISHING_INFO></IIP_ARTICLE>');
   }*/
}
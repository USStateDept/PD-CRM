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
private class DA_Create_Translation_Test 
{
    static testmethod void testLoadAsset2Translate()
    {
    	Digital_Asset__c testEnglishArticle = (Digital_Asset__c)GLOBAL_Library.createObj('Digital_Asset__c', null);
   		testEnglishArticle.Status__c = 'Published';
   		testEnglishArticle.Language__c = 'English';
   		testEnglishArticle.Asset_Type__c = 'Publication';
   		testEnglishArticle.Parent_Slug_Id__c = null;
   		insert testEnglishArticle;
    	test.startTest();
    	string result = DA_Create_Translation.LoadAsset2Translate(testEnglishArticle.Id);
    	system.assert(result.contains('The Translation Asset has been created and assigned to you'));
    	test.stopTest();
    }
    
    static testmethod void testNegativeTranslationCopyWrongStatus()
    {
    	Digital_Asset__c testEnglishArticle = (Digital_Asset__c)GLOBAL_Library.createObj('Digital_Asset__c', null);
   		testEnglishArticle.Status__c = 'Draft';
   		testEnglishArticle.Language__c = 'English';
   		testEnglishArticle.Asset_Type__c = 'Publication';
   		testEnglishArticle.Parent_Slug_Id__c = null;
   		insert testEnglishArticle;
    	test.startTest();
    	string result = DA_Create_Translation.LoadAsset2Translate(testEnglishArticle.Id);
    	system.assert(!result.contains('The Translation Asset has been created and assigned to you'));
    	test.stopTest();
    }
    
    static testmethod void testNegativeTranslationCopyHasParentSlug()
    {
    	Digital_Asset__c testEnglishArticle = (Digital_Asset__c)GLOBAL_Library.createObj('Digital_Asset__c', null);
   		testEnglishArticle.Status__c = 'Published';
   		testEnglishArticle.Language__c = 'English';
   		testEnglishArticle.Asset_Type__c = 'Publication';
   		testEnglishArticle.Parent_Slug_Id__c = 'test123';
   		insert testEnglishArticle;
    	test.startTest();
    	string result = DA_Create_Translation.LoadAsset2Translate(testEnglishArticle.Id);
    	system.assert(!result.contains('The Translation Asset has been created and assigned to you'));
    	test.stopTest();
    }
    
    static testmethod void testTranslationCopy()
    {
    	Profile p = DA_Test_Helper.getProfile('Publishing Translator');
		User u = DA_Test_Helper.createUserWithoutProfile();
		u.ProfileId = p.Id;
		u.Username = 'ok_to_translate@test.test';
		u.Default_Translation_Language__c = 'French';
		insert u;	

		test.startTest();
   		System.runAs(u) 
   		{
   			Digital_Asset__c testEnglishArticle = (Digital_Asset__c)GLOBAL_Library.createObj('Digital_Asset__c', null);
	   		testEnglishArticle.Status__c = 'Published';
	   		testEnglishArticle.Language__c = 'English';
	   		testEnglishArticle.Asset_Type__c = 'Publication';
	   		testEnglishArticle.Parent_Slug_Id__c = null;
	   		insert testEnglishArticle;
   			
   			Digital_Asset__c testEnglishArticleAfterInsert = [select Id, Headline_Long__c, Published_URL_Formula__c 
   																from Digital_Asset__c 
   																where Id =: testEnglishArticle.Id];
   			
   			system.debug('DEBUG:: after insert: ' + testEnglishArticleAfterInsert);
   			
   			string result = DA_Create_Translation.TranslationCopy(testEnglishArticle);
   			system.assert(result.contains('The Translation Asset has been created and assigned to you'));
   			
   			Digital_Asset__c testFrenchArticle = [select Id, Parent_Headline__c, Language__c, Published_URL_Formula__c, Headline_Long__c
   													from Digital_Asset__c 
   													where Parent_Headline__c =: testEnglishArticle.Id limit 1];
   			system.assertEquals('French', testFrenchArticle.Language__c);

			//system.debug('DEBUG:: url for french is: ' + testFrenchArticle.Published_URL_Formula__c);  http://iipdigital.usembassy.gov/st/french.html 		 
   			system.debug('DEBUG:: url for english is: ' + testEnglishArticle.Published_URL__c);
   			
   			Digital_Asset__c testEnglishArticleForTranslation = (Digital_Asset__c)GLOBAL_Library.createObj('Digital_Asset__c', null);
	   		testEnglishArticleForTranslation.Status__c = 'Published';
	   		testEnglishArticleForTranslation.Language__c = 'English';
	   		testEnglishArticleForTranslation.Parent_Slug_Id__c = null;
	   		testEnglishArticleForTranslation.MC_Headline_1__c = testEnglishArticleAfterInsert.Headline_Long__c;
	   		testEnglishArticleForTranslation.MC_URL_1__c = testEnglishArticleAfterInsert.Published_URL_Formula__c;
	   		testEnglishArticleForTranslation.MC_Headline_2__c = testEnglishArticleAfterInsert.Headline_Long__c;
	   		testEnglishArticleForTranslation.MC_URL_2__c = testEnglishArticleAfterInsert.Published_URL_Formula__c;
	   		testEnglishArticleForTranslation.MC_Headline_3__c = testEnglishArticleAfterInsert.Headline_Long__c;
	   		testEnglishArticleForTranslation.MC_URL_3__c = testEnglishArticleAfterInsert.Published_URL_Formula__c;
	   		testEnglishArticleForTranslation.MC_Headline_4__c = testEnglishArticleAfterInsert.Headline_Long__c;
	   		testEnglishArticleForTranslation.MC_URL_4__c = testEnglishArticleAfterInsert.Published_URL_Formula__c;
	   		testEnglishArticleForTranslation.MC_Headline_5__c = testEnglishArticleAfterInsert.Headline_Long__c;
	   		testEnglishArticleForTranslation.MC_URL_5__c = testEnglishArticleAfterInsert.Published_URL_Formula__c;
	   		insert testEnglishArticleForTranslation;

   			string result2 = DA_Create_Translation.TranslationCopy(testEnglishArticleForTranslation);
   			system.assert(result2.contains('The Translation Asset has been created and assigned to you'));
   		
   			Digital_Asset__c testFrenchArticle2 = [select Id, Parent_Headline__c, Language__c, Published_URL_Formula__c, Headline_Long__c,
   														MC_URL_1__c, MC_Headline_1__c
   													from Digital_Asset__c 
   													where Parent_Headline__c =: testEnglishArticleForTranslation.Id limit 1];
   													
   			system.assertEquals('French', testFrenchArticle2.Language__c);
   			system.assertEquals(testFrenchArticle2.MC_URL_1__c, testFrenchArticle.Published_URL_Formula__c);
   			system.assertEquals(testFrenchArticle2.MC_Headline_1__c, testFrenchArticle.Headline_Long__c);
   		
   		}
		test.stopTest();
    	
    }
    
    
    static testmethod void testPrettifyURL()
    {
    	string prettyURL = DA_Create_Translation.prettifyURL('www.google.com');
    	system.Assert(prettyURL.contains('http://'));
    }
    

    
    /*static testmethod void Test_TranslationCopy()
	{
      string retVal;
      Digital_Asset__c testAsset = new Digital_Asset__c();

      //testAsset. = da.Annunciator__c;
      testAsset.Article_Body__c = 'This is a tribute to the greatest article in the world';
      testAsset.Asset_Date_Time__c = datetime.now();
      testAsset.Subheadline__c = 'Test subheadline';
      testAsset.Communities__c = '';
      testAsset.Translation_Source__c = '';
      testAsset.Asset_Package__c = '';
      testAsset.Asset_Subtype__c = '';
      testAsset.Asset_Theme__c = '';
      testAsset.Asset_Type__c = 'Article';
      testAsset.Author__c = 'Kent Hitathng';
      testAsset.Author_Job_Title__c = 'stormtrooper';
      testAsset.Comment_Permission__c = false;
      //testAsset. = da.Content_Footer__c;
      //testAsset. = da.Content_Header__c;
      testAsset.Content_Requested_By__c = '';
      testAsset.Content_Teaser__c = '';
      testAsset.Name = 'such a super cool headline';
      testAsset.Headline_Long__c = 'such a super cool headline';
      testAsset.Include_Byline__c = false;
      testAsset.Include_in_RSS_Feed__c = false;
      testAsset.Language__c = '';
      testAsset.MC_Headline_1__c = '';
      testAsset.MC_URL_1__c = '';
      testAsset.Microblog__c = '';
      testAsset.Mobile_Blurb__c = '';
      testAsset.Mobile_Headline__c = '';
      testAsset.Multimedia_URL__c = '';
      testAsset.Parent_Slug_ID__c = null;
      testAsset.Photo_1_Alt_Text__c = '';
      testAsset.Photo_1_Caption__c = '';
      testAsset.Photo_1_Credit__c = '';
      testAsset.Photo_1_Location__c = '';
      testAsset.Photo_1_URL__c = '';
      //testAsset. = da.Proclamation__c;
      testAsset.Regional_Feeds__c = '';
      testAsset.Search_Keywords__c = 'testasset deleteme';
      testAsset.Social_Media_Blurb__c = 'such an amazing article';
      //testAsset. = da.Source__c;
      testAsset.Staff_Use_Only__c = true;
      testAsset.Status__c = 'Published';
      testAsset.Thumbnail_Alt_Tag__c = '';
      testAsset.Thumbnail_Credit__c = '';
      testAsset.Thumbnail_URL__c = '';
      testAsset.Top__c = '';
      testAsset.ToC_SubHeading__c = '';
      //testAsset. = da.Translation_Requested_By__c;

      //tests the incorrect object state
      retVal = DA_Create_Translation.TranslationCopy(testAsset);
      
      testAsset.Republish_ID__c = '123456789';
      retVal = DA_Create_Translation.TranslationCopy(testAsset);
      
      testAsset.Parent_Slug_ID__c = '12345';
      retVal = DA_Create_Translation.TranslationCopy(testAsset);
      
      testAsset.Status__c = 'In Work';
      retVal = DA_Create_Translation.TranslationCopy(testAsset);
   }*/
}
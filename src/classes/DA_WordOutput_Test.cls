/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition..
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
private class DA_WordOutput_Test {
   
   public static final string teststring = '<body><br>blakal&ndash;adl</br><div>fkjasdfjlkadslf</div>kjasdg&mdash;flksjd</body>'; 
    
   public static Digital_Asset__c createTestAsset(String language)
   {
   	  Digital_Asset__c testasset = new Digital_Asset__c();
      
      testasset.Asset_Date_Time__c = datetime.now();
      testasset.Language__c = language;
      testasset.Asset_Comments__c = 'this is a comment';
      testAsset.Asset_Type__c = 'Audio';
      testAsset.Asset_Subtype__c = 'Internal Use Only';
      testasset.Name = 'a really awesome headline';
      testasset.Headline_Long__c = 'a really awesome headline';
      testasset.subheadline__c = 'a subheadline';
      /*testasset.ToC_SubHeading__c = 'a toc subheading';
      testasset.ToC_Blurb__c = 'a toc blurb';
      testasset.Author__c = 'Jane Author';
      testasset.Author_Job_Title__c = 'a job title';
      testasset.Content_Teaser__c = 'so awesome check the headline';
      testasset.Top__c = '';
      testasset.Article_Body__c = 'an article about awesome stuff';
      testasset.Search_Keywords__c = 'awesome great amazing';
      testasset.Social_Media_Blurb__c = '';
      testasset.Microblog__c = '';
      testasset.MC_Headline_1__c = 'super awesome site';
      testasset.MC_Headline_2__c = 'super great site';
      testasset.MC_Headline_3__c = '';
      testasset.MC_Headline_4__c = '';
      testasset.MC_Headline_5__c = '';
      testasset.Photo_1_Caption__c = 'photo of awesome';
      testasset.Photo_1_Credit__c = 'Joe Photographer';
      testasset.Photo_1_Alt_Text__c = 'totally awesome stuff in this photo';
      testasset.Photo_2_Caption__c = '';
      testasset.Photo_2_Caption__c = '';
      testasset.Photo_2_Alt_Text__c = '';
      testasset.Photo_3_Caption__c = '';
      testasset.Photo_3_Credit__c = '';
      testasset.Photo_3_Alt_Text__c = '';
      testasset.Photo_4_Caption__c = '';
      testasset.Photo_4_Credit__c = '';
      testasset.Photo_4_Alt_Text__c = '';
      testasset.Photo_5_Caption__c = '';
      testasset.Photo_5_Credit__c = '';
      testasset.Photo_5_Alt_Text__c = '';
      testasset.Photo_6_Caption__c = '';
      testasset.Photo_6_Credit__c = '';
      testasset.Photo_6_Alt_Text__c = '';
      testasset.Multimedia_URL__c = 'http://someurl.test.test';*/
      
      return testasset;
   }
   
   static testmethod void testCleanFieldContents()
   {
      //string teststring = '<body>blakal&ndash;adl<div>fkjasdfjlkadslf</div>kjasdg&mdash;flksjd</body>';
      string result = DA_WordOutput.CleanFieldContents(teststring);
      system.assert(!result.contains('<div>'));
   }
   static testmethod void testStripHTML()
   {  
      string result = DA_WordOutput.StripHTML(teststring);
      system.assert(!result.contains('<body>'));
   }
   static testmethod void testPrettifyLanguage()
   {  
	  string result = DA_WordOutput.prettifyLanguage(teststring);
	  system.assert(!result.contains('&ndash;'));
	  system.assert(!result.contains('&mdash;'));
   }
   
   static testmethod void testCleanFieldContentsImport()
   {
		string result = DA_WordOutput.CleanFieldContentsImport(teststring);
   		system.assert(!result.contains('<br>'));
   }
   
   static testmethod void testTextOutput()
   {
   	Digital_Asset__c testasset = createTestAsset('English');
   	insert testasset;
   	
   	PageReference pageRef = Page.DA_Edit;
   	Test.setCurrentPage(pageRef);
	   	
   	// Add parameters 
	pageRef.getParameters().put('id', testasset.Id);
   	//GenerateTextOutput(testasset.id);
   	string results = DA_WordOutput.getTextOutput();
   	system.assertNotEquals('', results);
       
    Digital_Asset__c testasset2 = createTestAsset('Chinese');
   	insert testasset2;
   	
   	PageReference pageRef2 = Page.DA_Edit;
   	Test.setCurrentPage(pageRef2);
	   	
   	// Add parameters 
	pageRef2.getParameters().put('id', testasset2.Id);
   	//GenerateTextOutput(testasset.id);
   	string resultsA = DA_WordOutput.getTextOutput();
   	system.assertNotEquals('', resultsA);
   }
   
   static testmethod void testWordImport()
   {
   	Digital_Asset__c testasset = createTestAsset('English'); 
    testasset.Headline_long__c = 'Testing Word Import';
    insert testasset;
       
    string forImport = DA_WordOutput.GenerateWordOutput(testasset.id, 'yes');
    
    PageReference pageRef = Page.DA_WordInput;
   	Test.setCurrentPage(pageRef);
	DA_WordOutput controller = new DA_WordOutput(new ApexPages.StandardController(testasset));   	
   	// Add parameters 
	pageRef.getParameters().put('importId', testasset.Id);
	pageRef.getParameters().put('importText', forImport);
	
	controller.WordImport();
	
	Digital_Asset__c result = [select Id, Headline_Long__c from Digital_Asset__c where Id =: testasset.Id];
	//system.assertEquals('Testing Word Import',result.Headline_long__c);
   }
   
   static testmethod void testgetLanguage()
   {
	Digital_Asset__c testasset = createTestAsset('English'); 
    testasset.Headline_long__c = 'Testing Word Import';
    insert testasset;
       
    string forImport = DA_WordOutput.GenerateWordOutput(testasset.id, 'yes');
    
    PageReference pageRef = Page.DA_WordInput;
   	Test.setCurrentPage(pageRef);
	DA_WordOutput controller = new DA_WordOutput(new ApexPages.StandardController(testasset));   	
   	// Add parameters 
	pageRef.getParameters().put('Lang', 'English');

	string result = DA_WordOutput.getLanguage();
	system.assertEquals('English',result);

   }
   
   
   static testmethod void TestDigitalAssetFunctions()
   {
   	Digital_Asset__c testasset = createTestAsset('English');
   	insert testasset;
   	testasset.Headline_long__c = testasset.Name + 'test &amp; test test test test test test test test test test test' + 
   												+ ' test test test test &Aacute; test test test test test test test';
   	update testasset;

    PageReference pageRef = Page.DA_Edit;
   	Test.setCurrentPage(pageRef);
	   	
   	// Add parameters 
	pageRef.getParameters().put('id', testasset.Id);
	
	//coverage for vf page fields/functions
   	DA_WordOutput.getassetName();
   	DA_WordOutput.getWordOutput();
	
   }
    
   private static testmethod void testWordOutput()
   {
      Digital_Asset__c testasset = createTestAsset('English');
      insert testasset;
      string result = DA_WordOutput.GenerateWordOutput(testasset.id, 'yes'); //with brackets
      string result2 = DA_WordOutput.GenerateWordOutput(testasset.id, 'no'); //without brackets
      system.assert(result.contains('[['));
      system.assert(!result2.contains('[['));
       
      Digital_Asset__c testasset2 = createTestAsset('Chinese');
      insert testasset2;
      string resultA = DA_WordOutput.GenerateWordOutput(testasset2.id, 'yes'); //with brackets
      string result2A = DA_WordOutput.GenerateWordOutput(testasset2.id, 'no'); //without brackets
      system.assert(resultA.contains('[['));
      system.assert(!result2A.contains('[['));
   }
   
   private static testmethod void testAddElement()
   {
    string testVal = '';
    string checkVal = '';
    
    checkVal = '[[[[ 121-TEST LINE (do not delete this line)]]]]<br>some contents<br><br>';
    testVal = DA_WordOutput.addElement(
       '121', 'TEST LINE', 'some contents');   
    system.assertequals(testVal, checkval);
   }
   
/* should not need to test import this way because we can export a digital asset and then import; which should be closer to the
	actual end-user process..
   private static testmethod void TestWordInput()
   {
      Digital_Asset__c testasset = createTestAsset();
      
      insert testAsset;
      
      string testAssetID = testAsset.Id;
      string Text2Import = 
      	'[[[[ 0-EDITORIAL COMMENTS (do not delete this line)]]]] For EUR region/js tps' + 
	  	'[[[[ 1-HEADLINE (do not delete this line)]]]] Obama’s Call to French President Sarkozy' +
		'[[[[ 2-SUBHEAD (do not delete this line)]]]] Obama’s Call to French President Sarkozy' + 
		'[[[[ 3-ToC SECTION HEADLINE (do not delete this line)]]]] Obama’s Call to French President Sarkozy ' + 
		'[[[[ 4-ToC BLURB (do not delete this line)]]]] Obama’s Call to French President Sarkozy' + 
		'[[[[ 5-AUTHOR (do not delete this line)]]]] Obama’s Call to French President Sarkozy' + 
		'[[[[ 6-AUTHOR TITLE (do not delete this line)]]]] Obama’s Call to French President Sarkozy ' + 
		'[[[[ 7-TOP (do not delete this line)]]]] this is the top'+
		'[[[[ 8-ARTICLE BODY (do not delete this line)]]]] THE WHITE HOUSE Office of the Press Secretary'+
		'[[[[ 9-SEARCH KEYWORDS (do not delete this line)]]]] France; Nicolas Sarkozy; President Obama;'+
		'[[[[ 10-TEASER (do not delete this line)]]]] President Obama called President Nicolas Sarkozy of France to thank him for his strong leadership, friendship and partnership in challenging times.'+
		'[[[[ 11-SOCIAL MEDIA BLURB (do not delete this line)]]]]'+
		'[[[[ 12-MICROBLOG (do not delete this line)]]]]'+
		'[[[[ 13-MOBILE HEADLINE (do not delete this line)]]]]'+
		'[[[[ 14-MOBILE BLURB (do not delete this line)]]]] some mobile blurb'+
		'[[[[ 15-MORE COVERAGE HEADLINE 1 (do not delete this line)]]]] Clinton at Partnership Meeting on Combating Wildlife Trafficking'+
		'[[[[ 16-MORE COVERAGE URL 1 (do not delete this line)]]]] http://iipdigital.usembassy.gov/st/english/texttrans/2012/11/20121108138454.html'+
		'[[[[ 17-MORE COVERAGE HEADLINE 2 (do not delete this line)]]]] Clinton Interview with NDTV at La Martiniere School for Girls'+
		'[[[[ 18-MORE COVERAGE URL 2 (do not delete this line)]]]]http://iipdigital.usembassy.gov/st/english/texttrans/2012/05/201205075192.html'+
		'[[[[ 19-MORE COVERAGE HEADLINE 3 (do not delete this line)]]]] Clinton on Building Sustainable Partnerships in Africa'+
		'[[[[ 20-MORE COVERAGE URL 3 (do not delete this line)]]]]http://iipdigital.usembassy.gov/st/english/texttrans/2012/08/20120801117221.html'+
		'[[[[ 21-MORE COVERAGE HEADLINE 4 (do not delete this line)]]]]'+
		'[[[[ 22-MORE COVERAGE URL 4 (do not delete this line)]]]]'+
		'[[[[ 23-MORE COVERAGE HEADLINE 5 (do not delete this line)]]]]'+
		'[[[[ 24-MORE COVERAGE URL 5 (do not delete this line)]]]]'+
		'[[[[ 25-IMAGE 1 CAPTION (do not delete this line)]]]]hello world'+
		'[[[[ 26-IMAGE 1 CREDIT (do not delete this line)]]]]credit is due'+
		'[[[[ 27-IMAGE 1 ALT TAG (do not delete this line)]]]]a photo'+
		'[[[[ 28-IMAGE 2 CAPTION (do not delete this line)]]]]'+
		'[[[[ 29-IMAGE 2 CREDIT (do not delete this line)]]]]'+
		'[[[[ 30-IMAGE 2 ALT TAG (do not delete this line)]]]]'+
		'[[[[ 31-IMAGE 3 CAPTION (do not delete this line)]]]]'+
		'[[[[ 32-IMAGE 3 CREDIT (do not delete this line)]]]]'+
		'[[[[ 33-IMAGE 3 ALT TAG (do not delete this line)]]]]'+
		'[[[[ 34-IMAGE 4 CAPTION (do not delete this line)]]]]'+
		'[[[[ 35-IMAGE 4 CAPTION (do not delete this line)]]]]'+
		'[[[[ 36-IMAGE 4 ALT TAG (do not delete this line)]]]]'+
		'[[[[ 37-IMAGE 5 CAPTION (do not delete this line)]]]]'+
		'[[[[ 38-IMAGE 5 CREDIT (do not delete this line)]]]]'+
		'[[[[ 39-IMAGE 5 ALT TAG (do not delete this line)]]]]'+
		'[[[[ 40-IMAGE 6 CAPTION (do not delete this line)]]]]'+
		'[[[[ 41-IMAGE 6 CREDIT (do not delete this line)]]]]'+
		'[[[[ 42-IMAGE 6 ALT TAG (do not delete this line)]]]]'+
		'[[[[ 43-THUMBNAIL CREDIT (do not delete this line)]]]]some thumb credit'+
		'[[[[ 44-THUMBNAIL ALT TAG (do not delete this line)]]]]some thumb alt tag'+
		'[[[[ 45-THUMBNAIL URL (do not delete this line)]]]]http://photos.state.gov'+
		'[[[[ 46-MULTIMEDIA URL (do not delete this line)]]]]http://photos.state.gov';
      
      DA_WordOutput dimport = new DA_WordOutput(new Apexpages.StandardController(testAsset));  
      dimport.ReallyWordImport(testAssetId, Text2Import);
   }
*/    
    
}
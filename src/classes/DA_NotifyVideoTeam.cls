public with sharing class DA_NotifyVideoTeam
{

    public DA_NotifyVideoTeam(ApexPages.StandardController controller) {
		getNotifyVideoMessage();
    }

   public static string getNotifyVideoMessage()
   {
      PageReference pageRef = ApexPages.currentPage();
      Map<String, String> parameters = pageRef.getParameters();
      string pId = parameters.get('id');
      
      return GenerateNotifyVideoMessage(pId);
   }
   
   public static string GenerateNotifyVideoMessage(string pId)
   {
      string retVal = '';
      Digital_Asset__c generateAsset =
         [Select d.Name, d.Published_URL__c, d.Article_Body__c, d.Copy_Editor_1__c, d.Headline_Long__c,
            d.Copy_Editor_1__r.FirstName, d.Copy_Editor_1__r.LastName
          from Digital_Asset__c d
          where d.Id = :pId LIMIT 1];
      
      if(generateAsset.Copy_Editor_1__c != null)
      {
         retVal = 'Transcript reviewed by ' + generateAsset.Copy_Editor_1__r.FirstName + ' ' + 
            generateAsset.Copy_Editor_1__r.LastName+ '<br><br>';
      }
      
      retVal += 'Headline: ' + generateAsset.Headline_Long__c + '<br><br>';
      retVal += 'will be available soon at:<br><br>';
      retVal += 'URL: ' + generateAsset.Published_URL__c + '<br><br>';
      retVal += 'This English transcript should be loaded into the captions section of ' +
         'the Brightcove server:<br><br>';
      retVal += '======================================<br><br>';
      retVal += 'TRANSCRIPT IN FULL:<br><br>';
      
      if(generateAsset.Article_Body__c != null)
      {
         retVal += generateAsset.Article_Body__c + '<br><br>';
      }
      
      return retVal;
   }
   /*
   private static testmethod void TestGenerateNotifyVideoMessage()
   {
      Digital_Asset__c testasset = new Digital_Asset__c();
      
      testasset.Asset_Date_Time__c = datetime.now();
      testasset.Asset_Type__c = 'Audio';
      testasset.Asset_Subtype__c = 'Internal Use Only';
      testasset.Language__c = 'English';
      testasset.Name = 'Some weird testing asset';
      testasset.Headline_Long__c = 'Some weird testing asset';
      testasset.Search_Keywords__c = 'test weird silly';
      testasset.Article_Body__c = 'supercalifragilisticespialidocious and other stuff that is not null';
      testasset.Author__c = 'some crazy russian';
      
      insert testasset;
      
      DA_NotifyVideoTeam.GenerateNotifyVideoMessage(testasset.id);
   }*/
}
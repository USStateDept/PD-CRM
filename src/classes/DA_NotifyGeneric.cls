public with sharing class DA_NotifyGeneric
{

    public DA_NotifyGeneric(ApexPages.StandardController controller) {
		getNotifyGenericMessage();
    }

   public static string getNotifyGenericMessage()
   {
      PageReference pageRef = ApexPages.currentPage();
      Map<String, String> parameters = pageRef.getParameters();
      string pId = parameters.get('id');
      
      return GenerateNotifyGenericMessage(pId);
   }
   
   public static string GenerateNotifyGenericMessage(string pId)
   {
      string retVal = '';
      Digital_Asset__c generateAsset =
         [Select d.Name,d.IIP_Digital_Link__c, d.Parent_IIP_Digital_Link__c, d.Social_Media_Blurb__c, d.Microblog__c
          from Digital_Asset__c d
          where d.Id = :pId LIMIT 1];
      
      if(generateAsset!=null)
      {
         retVal = 'Headline: ' +replaceNulls(generateAsset.Name) + '<br><br>';
      }
      
      
      retVal += 'will be available soon at: ' + replaceNulls(generateAsset.IIP_Digital_Link__c) + '<br><br>';
      System.Debug('DEBUG:: parent link: ' + generateAsset.Parent_IIP_Digital_Link__c.stripHtmlTags());
      if(generateAsset.Parent_IIP_Digital_Link__c.stripHtmlTags() != '' && generateAsset.Parent_IIP_Digital_Link__c.stripHtmlTags() != null)
      {
      	retVal += 'The Parent IIP Digital Link: ' + replaceNulls(generateAsset.Parent_IIP_Digital_Link__c) + '<br><br>';
      }
      retVal += 'FACEBOOK: ' + replaceNulls(generateAsset.Social_Media_Blurb__c) + '<br><br>';
      retVal += 'TWITTER: ' + replaceNulls(generateAsset.Microblog__c) + '<br><br>';
      retVal += 'Thank you,<br>';
      retVal += UserInfo.getName()+ '<br><br>';
      
      return retVal;
   }
   
   private static string replaceNulls(String replacethis)
   {
   	String clean = '';
   	
   	if(replacethis != null)
   		clean = replacethis;
   			
   	return clean;
   }
   
   
   
}
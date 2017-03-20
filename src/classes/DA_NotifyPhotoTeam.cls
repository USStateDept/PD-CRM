public with sharing class DA_NotifyPhotoTeam 
{

    public DA_NotifyPhotoTeam(ApexPages.StandardController controller) {
		getNotifyPhotoMessage();
    }

   public static string getNotifyPhotoMessage()
   {
      PageReference pageRef = ApexPages.currentPage();
      Map<String, String> parameters = pageRef.getParameters();
      string pId = parameters.get('id');
      
      return GenerateNotifyPhotoMessage(pId);
   }
   
   public static string GenerateNotifyPhotoMessage(string pId)
   {
      string retVal = '';
      Digital_Asset__c generateAsset =
         [Select d.Asset_Type__c, d.Photo_1_Location__c, d.Photo_1_Credit__c, d.Photo_1_Alt_Text__c, d.Photo_1_URL__c, d.Photo_1_Caption__c,
         	d.Photo_2_Location__c, d.Photo_2_Credit__c, d.Photo_2_Alt_Text__c, d.Photo_2_URL__c, d.Photo_2_Caption__c, d.Name
          from Digital_Asset__c d
          where d.Id = :pId LIMIT 1];
      
      if(generateAsset!=null)
      {
         retVal = 'Request for a photo URL: ' + '<br><br>';
      }
      
      
      retVal += 'Asset Type: ' + replaceNulls(generateAsset.Asset_Type__c) + '<br><br>';
      retVal += 'Photo 1: <br>';
      retVal += 'Location: ' + replaceNulls(generateAsset.Photo_1_Location__c) + '<br>';
      retVal += 'Credit: ' + replaceNulls(generateAsset.Photo_1_Credit__c) + '<br>';
      retVal += 'Alt Tag: ' + replaceNulls(generateAsset.Photo_1_Alt_Text__c) + '<br>';
      retVal += 'Photo Caption: ' + replaceNulls(generateAsset.Photo_1_Caption__c) + '<br><br>';
      retVal += 'Photo 2: <br>';
      retVal += 'Location: ' + replaceNulls(generateAsset.Photo_2_Location__c) + '<br>';
      retVal += 'Credit: ' + replaceNulls(generateAsset.Photo_2_Credit__c) + '<br>';
      retVal += 'Alt Tag: ' + replaceNulls(generateAsset.Photo_2_Alt_Text__c) + '<br>';
      retVal += 'Photo Caption: ' + replaceNulls(generateAsset.Photo_2_Caption__c) + '<br><br>';
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
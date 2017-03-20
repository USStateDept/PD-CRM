global class DA_PublishArticle
{
   webservice static string publish(string AssetID)
   {
      Digital_Asset__c parentAsset = null;
      Digital_Asset__c publishingAsset = 
         [Select d.OwnerID, d.Status__c, d.XML_Output__c, d.Asset_Version__c, d.Article_Rejected__c, d.Copy_Editor_1__c,
            d.Copy_Editor_2__c, d.Parent_Slug_ID__c, d.Translator__c, d.Asset_Creator__c, d.Date_of_First_Publish__c,
            d.Name, d.Published_URL__c, d.Social_Media_Blurb__c, d.Microblog__c, d.Language__c, d.Asset_Date_Time__c,
            d.Asset_Type__c, d.Publication_Title__c, d.Arabic_URL__c, d.Chinese_URL__c, d.English_URL__c,
            d.French_URL__c, d.Persian_URL__c, d.Portuguese_URL__c, d.Russian_URL__c, d.Spanish_URL__c, d.Turkish_URL__c, d.Urdu_URL__c
          from Digital_Asset__c d where d.Id = :AssetID LIMIT 1];
       
      User pub_dump = 
         [Select u.ID from User u where u.Username LIKE 'pubdump@somewhere.com%' LIMIT 1];
      
      if(publishingAsset.Parent_Slug_ID__c == null)
      {
         DA_PublishArticle.InsertLanguageLink(publishingAsset, publishingAsset.Language__c,
            publishingAsset.Published_URL__c);
      }
      else
      {
         string parentId = publishingAsset.Parent_Slug_ID__c;
         parentAsset = [Select x.Arabic_URL__c, x.Chinese_URL__c, x.English_URL__c, x.French_URL__c,
            x.Persian_URL__c, x.Portuguese_URL__c, x.Russian_URL__c, x.Spanish_URL__c, x.Turkish_URL__c, x.Urdu_URL__c
            from Digital_Asset__c x where (x.Slug_ID__c = :parentId) OR (x.Republish_ID__c = :parentId) LIMIT 1];
         
         if(parentAsset != null)
         {
           DA_PublishArticle.InsertLanguageLink(parentAsset, publishingAsset.Language__c,
              publishingAsset.Published_URL__c);
         }
      }

      return DA_PublishArticle.ActuallyPublish(publishingAsset, pub_dump, parentAsset);
   }
   
   
   public static string ActuallyPublish(Digital_Asset__c publishingAsset, User u, Digital_Asset__c parentAsset) 
   {
      string Success = 'Did not execute';
      
      if((publishingAsset.Status__c == 'Copy Desk') ||
         (publishingAsset.Status__c == 'Approved Not Published') ||
         (publishingAsset.Status__c == 'In Translation'))
      {
         if((PublishingAsset.Language__c == 'English') && (publishingAsset.Parent_Slug_ID__c == null) ||
            (PublishingAsset.Language__c != 'English'))
         {
            if(publishingAsset.OwnerID == UserInfo.getUserId())
            {
               String xml = DA_ArticleToXML.generateXML(publishingAsset.id);
               try
               {
               	Success = DA_PublishArticle.sendXml(xml);
               }
               catch(System.QueryException e)
               {
               	Success = 'System Error: No Endpoint specified in custom settings.  Please contact your system admin for assistance.';
               }
               
                //if (xml.length() <=20000){
               		publishingAsset.XML_Output__c = xml;
                //}else{
                    //ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'The XML Output exceeds 200,000 characters.');
                   // ApexPages.addMessage(myMsg);
                //}
               if(Success != null){
                   
                  if((Success.startsWith('201')) || (Success.startsWith('404'))){
                     publishingAsset.Post_Date__c = datetime.now();
                     publishingAsset.Status__c = 'Published';
                     publishingAsset.Article_Rejected__c = 'Not Rejected';
                     publishingAsset.Asset_Version__c = publishingAsset.Asset_Version__c + 1;
                     publishingAsset.Notify_Message__c = DA_PublishArticle.GenerateNotifyMessage(publishingAsset);
                      
                     if(publishingAsset.Date_of_First_Publish__c == null){
                        publishingAsset.Date_of_First_Publish__c = datetime.now();
                     }
                     if(publishingAsset.Asset_Date_Time__c == null){
                        publishingAsset.Asset_Date_Time__c = datetime.now();
                     }
                     if(publishingAsset.Parent_Slug_ID__c == null){
                        if((publishingAsset.Copy_Editor_1__c == null) || (publishingAsset.Copy_Editor_1__c == publishingAsset.OwnerID)){
                           publishingAsset.Copy_Editor_1__c = publishingAsset.OwnerID;
                        }
                        else{
                           publishingAsset.Copy_Editor_2__c = publishingAsset.OwnerID;
                        }
                     }
                  }
                  else
                  {
                     publishingAsset.Translator__c = publishingAsset.OwnerID;
                  }
                  publishingAsset.OwnerID = u.ID;

                  update publishingAsset;
                  if(parentAsset != null) { update parentAsset; }
               }
            }
            else
            {
               Success = 'You must be the owner of this asset to perform this operation';
            }
         }
         else
         {
            Success = 'You cannot publish an asset in english that has a parent';
         }
         
      }
      else
      {
         Success = 'Asset must be in either the \"copy desk\" or \"approved not published\" state to be published';
      }
      
      return Success;
   }
   
   public static void InsertLanguageLink(Digital_Asset__c Destination, string Language, string Link)
   {
      string[] LanguageArray = new string[] 
         {'English', 'Arabic', 'Chinese', 'French', 'Persian', 'Portuguese', 'Russian', 'Spanish', 'Turkish', 'Urdu'};

      if(Language == 'Arabic') {Destination.Arabic_URL__c = Link; }
      else if(Language == 'Chinese') {Destination.Chinese_URL__c = Link; }
      else if(Language == 'English') {Destination.English_URL__c = Link; }
      else if(Language == 'French') {Destination.French_URL__c = Link; }
      else if(Language == 'Persian') {Destination.Persian_URL__c = Link;}
      else if(Language == 'Portuguese') {Destination.Portuguese_URL__c = Link; }
      else if(Language == 'Russian') {Destination.Russian_URL__c = Link; }
      else if(Language == 'Spanish') {Destination.Spanish_URL__c = Link; }
      else if(Language == 'Turkish') {Destination.Turkish_URL__c = Link; }
      else if(Language == 'Urdu') {Destination.Urdu_URL__c = Link; }
      else { /* Do Nothing */ }
   }
    
   // This allows the sendXml method to run async, disabled for anon testing 
   //@future (callout=true)
   public static String sendXml(String xml)
   {
      HttpRequest req = new HttpRequest();
      HttpResponse res = new HttpResponse();
      Http http = new Http();
      String response;
      
      Global_Variable__c gvc1 = [SELECT value__c FROM Global_Variable__c WHERE name = 'XML Publishing Password'];
	  String password = gvc1.value__c;
      
      Global_Variable__c gvc2 = [SELECT value__c FROM Global_Variable__c WHERE name = 'XML Publishing URL'];
	  String url = gvc2.value__c;
	  
	  Global_Variable__c gvc3 = [SELECT value__c FROM Global_Variable__c WHERE name = 'XML Publishing User ID'];
	  String userID = gvc3.value__c;
      
      //req.setEndpoint( 'http://' + userID + ':' + password + '@' + url );
      
      req.setEndpoint( 'https://' + url );

	  Blob headerValue = Blob.valueOf( userID + ':' + password );
	  String authorizationHeader = 'BASIC ' +
	  EncodingUtil.base64Encode(headerValue);
	  req.setHeader('Authorization', authorizationHeader);
      
      req.setMethod('POST');
      req.setHeader('Content-Type','application/x-www-form-urlencoded');
      req.setBody('xml=' + EncodingUtil.urlEncode(xml, 'UTF-8'));
      //req.setBody(EncodingUtil.urlEncode(xml, 'UTF-8'));
      //req.setCompressed(true); // otherwise we hit a limit of 32000

      try
      {
         res = http.send(req);
         response = res.getStatusCode() + ':' + res.getBody();
      }
      catch(System.CalloutException e)
      {
         System.debug('Callout error: '+ e);
         System.debug(res.toString());
      }
      return response;
   }
   
   public static String GetTags(String body)
   {
      HttpRequest req = new HttpRequest();
      HttpResponse res = new HttpResponse();
      Http http = new Http();
      String response;
      
      Global_Variable__c gvc1 = [SELECT value__c FROM Global_Variable__c WHERE name = 'XML Publishing Password'];
	  String password = gvc1.value__c;
      
      Global_Variable__c gvc2 = [SELECT value__c FROM Global_Variable__c WHERE name = 'XML Publishing Tag URL'];
	  String url = gvc2.value__c;
	  
	  Global_Variable__c gvc3 = [SELECT value__c FROM Global_Variable__c WHERE name = 'XML Publishing User ID'];
	  String userID = gvc3.value__c;
      
      req.setEndpoint( 'http://' + userID + ':' + password + '@' + url );
      
      req.setMethod('POST');
      //req.setHeader('Content-Type','plain/text');
      req.setBody(EncodingUtil.urlEncode(body, 'UTF-8'));
      //req.setBody(EncodingUtil.urlEncode(xml, 'UTF-8'));
      //req.setCompressed(true); // otherwise we hit a limit of 32000

      try
      {
         res = http.send(req);
         response = res.getStatusCode() + ':' + res.getBody();
      }
      catch(System.CalloutException e)
      {
         System.debug('Callout error: '+ e);
         System.debug(res.toString());
      }
      return response;
   }
   
   public static string GenerateNotifyMessage(Digital_Asset__c NotifyAsset)
   {
      String retVal = '';

      retVal += 'Headline: ' + NotifyAsset.Name + '<br><br>';
      retVal += 'will be available soon at:<br>';
      retVal += NotifyAsset.Published_URL__c + '<br><br>';
      if(NotifyAsset.Social_Media_Blurb__c != NULL)
      {
         retVal += 'FACEBOOK: ' + NotifyAsset.Social_Media_Blurb__c + '<br><br>';
      }
      else
      {
         retVal += 'FACEBOOK: <br><br>';
      }
      
      if(NotifyAsset.Microblog__c != NULL)
      {
         retVal += 'TWITTER: ' + NotifyAsset.Microblog__c + '<br>';
      }
      else
      {
         retVal += 'TWITTER: <br>';
      }

      return retVal;
   }
   
   
}
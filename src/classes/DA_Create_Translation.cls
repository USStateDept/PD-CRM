global class DA_Create_Translation
{
   //spring 2013 enhancements: added Subheadline__c, Translation_Source__c, Communities__c
   webservice static string LoadAsset2Translate(string ParentAsset)
   {
      Digital_Asset__c da = [Select
      	 d.Subheadline__c, d.Translation_Source__c, d.Communities__c,
         d.Annunciator__c, d.Article_Body__c, d.Asset_Date_Time__c, Asset_Package__c,
         d.Asset_Subtype__c, d.Asset_Theme__c, d.Asset_Type__c, d.Author__c,
         d.Author_Job_Title__c, d.Comment_Permission__c, d.Content_Footer__c,
         d.Content_Header__c, d.Content_Requested_By__c, d.Content_Teaser__c,
         d.Slug_ID__c, d.Include_Byline__c, d.Include_in_RSS_Feed__c, d.Language__c,
         d.MC_Headline_1__c, d.MC_Headline_2__c, d.MC_Headline_3__c,
         d.MC_Headline_4__c, d.MC_Headline_5__c, d.MC_URL_1__c, d.MC_URL_2__c,
         d.MC_URL_3__c, d.MC_URL_4__c, d.MC_URL_5__c, d.Microblog__c, d.Mobile_Blurb__c,
         d.Mobile_Headline__c, d.Multimedia_URL__c, d.Parent_Slug_ID__c,
         d.Photo_1_Alt_Text__c, d.Photo_1_Caption__c, d.Photo_1_Credit__c,
         d.Photo_1_Location__c, d.Photo_1_URL__c, d.Photo_2_Alt_Text__c,
         d.Photo_2_Caption__c, d.Photo_2_Credit__c, d.Photo_2_Location__c,
         d.Photo_2_URL__c, d.Photo_3_Alt_Text__c, d.Photo_3_Caption__c,
         d.Photo_3_Credit__c, d.Photo_3_Location__c, d.Photo_3_URL__c,
         d.Proclamation__c, d.Regional_Feeds__c, d.Search_Keywords__c,
         d.Social_Media_Blurb__c, d.Source__c, d.Staff_Use_Only__c, d.Status__c,
         d.Thumbnail_Alt_Tag__c, d.Thumbnail_Credit__c, d.Thumbnail_URL__c,
         d.Top__c, d.Translation_Requested_By__c, d.Name, Parent_Headline__c,
         d.Republish_ID__c, d.Headline_Long__c, d.ToC_Subheading__c,
         d.Photo_4_Location__c, d.Photo_4_Credit__c, d.Photo_4_Caption__c, 
         d.Photo_4_Alt_Text__c, d.Photo_4_URL__c,
         d.Photo_5_Location__c, d.Photo_5_Credit__c, d.Photo_5_Caption__c, 
         d.Photo_5_Alt_Text__c, d.Photo_5_URL__c,
         d.Photo_6_Location__c, d.Photo_6_Credit__c, d.Photo_6_Caption__c, 
         d.Photo_6_Alt_Text__c, d.Photo_6_URL__c
         from Digital_Asset__c d where d.Id = :ParentAsset LIMIT 1];
         
    return TranslationCopy(da);
   }
   
   public static string TranslationCopy(Digital_Asset__c da)
   {
      String tempstr = '';
      String errorMessage = '';
      PageReference pageRef = Page.Publishing_PublishAsset;
      Digital_Asset__c New_Asset = new Digital_Asset__c();

      if((da.Status__c != 'Published') && (da.Status__c != 'Approved Not Published'))
      {
         errorMessage = 'This operation can only be performed on assets in the Published state.';
      }
      else if (da.Parent_Slug_ID__c != null)
      {
         errorMessage = 'This operation must be performed from the base object';
      }
      else
      {
         //New_Asset. = da.Annunciator__c;
         New_Asset.Subheadline__c = da.Subheadline__c; 
         New_Asset.Translation_Source__c = da.Translation_Source__c; 
         New_Asset.Communities__c = da.Communities__c;
         New_Asset.Article_Body__c = da.Article_Body__c;
         New_Asset.Asset_Date_Time__c = da.Asset_Date_Time__c;
         New_Asset.Asset_Package__c = da.Asset_Package__c;
         New_Asset.Asset_Subtype__c = da.Asset_Subtype__c;
         New_Asset.Asset_Theme__c = da.Asset_Theme__c;
         New_Asset.Asset_Type__c = da.Asset_Type__c;
         New_Asset.Author__c = da.Author__c;
         New_Asset.Author_Job_Title__c = da.Author_Job_Title__c;
         New_Asset.Comment_Permission__c = da.Comment_Permission__c;
         //New_Asset. = da.Content_Footer__c;
         //New_Asset. = da.Content_Header__c;
         New_Asset.Content_Requested_By__c = da.Content_Requested_By__c;
         New_Asset.Content_Teaser__c = da.Content_Teaser__c;
         New_Asset.Parent_Headline__c = da.Id;
         New_Asset.ToC_Subheading__c = da.ToC_Subheading__c;

         tempstr = da.Headline_Long__c + ' TRANSLATION';
         New_Asset.Headline_Long__c = tempstr;
         
         if(tempstr.length() > 80)
         {
            New_Asset.Name = tempstr.substring(0,79);
         }
         else
         {
            New_Asset.Name = tempstr;
         }
         
         New_Asset.Include_Byline__c = da.Include_Byline__c;
         New_Asset.Include_in_RSS_Feed__c = da.Include_in_RSS_Feed__c;
         
         //spring 2013 phase 2; default Language and MC based on translation language
         New_Asset.OwnerID = UserInfo.getUserId();
         Map<Id,String> mapUserToLang = new Map<Id,String>();
         //get the default language for the translator
         String sLanguage = da.Language__c;
         for (User u: [select Id,Default_Translation_Language__c from User where Id =: UserInfo.getUserId()])
         {
         	mapUserToLang.put(u.Id,u.Default_Translation_Language__c);
         }
         if(mapUserToLang.get(UserInfo.getUserId())!= null)
         {
         	sLanguage = mapUserToLang.get(UserInfo.getUserId());
         	New_Asset.Language__c = sLanguage;	
         }
         else
         {
         	New_Asset.Language__c = sLanguage;
         }
         system.debug('DEBUG:: language' + sLanguage);
         
         Map<Integer,String> mapMCOrderURLs = new Map<Integer,String>();
         Map<Integer,Id> mapMCOrderIds = new Map<Integer,Id>();
         Map<Id,Digital_Asset__c> mapOrigMCs = new Map<Id,Digital_Asset__c>();
         Map<Id,Digital_Asset__c> mapTransMCs = new Map<Id,Digital_Asset__c>();
         Set<String> setMCUrl = new Set<String>();
         Set<String> setMCId = new Set<String>();
         
         String MC1;
         String MC2;
         String MC3;
         String MC4;
         String MC5;
         
         if(da.MC_URL_1__c != null && da.MC_URL_1__c != '')
         {
         	MC1 = prettifyURL(da.MC_URL_1__c);
         	setMCUrl.add(MC1);
         }
         else
         {
         	MC1 = '';
         }
         
         if(da.MC_URL_2__c != null && da.MC_URL_2__c != '')
         {
         	MC2 = prettifyURL(da.MC_URL_2__c);
         	setMCUrl.add(MC2);
         }
         else
         {
         	MC2 = '';
         }
         
         if(da.MC_URL_3__c != null && da.MC_URL_3__c != '')
         {
         	MC3 = prettifyURL(da.MC_URL_3__c);
         	setMCUrl.add(MC3);
         }
         else
         {
         	MC3 = '';
         }
         
         if(da.MC_URL_4__c != null && da.MC_URL_4__c != '')
         {
         	MC4 = prettifyURL(da.MC_URL_4__c);
         	setMCUrl.add(MC4);
         }
         else
         {
         	MC4 = '';
         }
         
         if(da.MC_URL_5__c != null && da.MC_URL_5__c != '')
         {
         	MC5 = prettifyURL(da.MC_URL_5__c);
         	setMCUrl.add(MC5);
         }
         else
         {
         	MC5 = '';
         }
         
         mapMCOrderURLs.put(1,MC1);
         mapMCOrderURLs.put(2,MC2);
         mapMCOrderURLs.put(3,MC3);
         mapMCOrderURLs.put(4,MC4);
         mapMCOrderURLs.put(5,MC5);
         //system.debug('DEBUG:: mapMCOrderURLs ' + mapMCOrderURLs);
         //system.debug('DEBUG:: setMCUrl: ' + setMCUrl);
         //phase2.1: change Name to Headline_long__c when populating MC Headline fields on translation
         //get a collection of the more coverage records; also collect the id and order     
         for(Digital_Asset__c da_orig: ([select Id, Name, Headline_long__c, Parent_Headline__c, Published_URL__c from Digital_Asset__c where Published_URL_Formula__c in: setMCUrl]))
         {
         	mapOrigMCs.put(da_orig.Id, da_orig);
         	setMCId.add(da_orig.Id);
         	/*system.debug('DEBUG:: mapOrigMCs' + mapOrigMCs);
         	system.debug('DEBUG:: da_orig.Published_URL__c: ' + da_orig.Published_URL__c);
         	system.debug('DEBUG:: mapMCOrderURLs.get(1): ' + mapMCOrderURLs.get(1));*/
         	//we need to make uniform the URL because some URL contain the http, others do not
         	if(mapMCOrderURLs.get(1) != null)
         	{
	         	if(prettifyURL(da_orig.Published_URL__c) == prettifyURL(mapMCOrderURLs.get(1)))
	         		mapMCOrderIds.put(1,da_orig.Id);
         	}
         	if(mapMCOrderURLs.get(2) != null)
         	{
	         	if(prettifyURL(da_orig.Published_URL__c) == prettifyURL(mapMCOrderURLs.get(2)))
	         		mapMCOrderIds.put(2,da_orig.Id);
         	}
         	if(mapMCOrderURLs.get(3) != null)
         	{
	         	if(prettifyURL(da_orig.Published_URL__c) == prettifyURL(mapMCOrderURLs.get(3)))
	         		mapMCOrderIds.put(3,da_orig.Id);
         	}
         	if(mapMCOrderURLs.get(4) != null)
         	{
	         	if(prettifyURL(da_orig.Published_URL__c) == prettifyURL(mapMCOrderURLs.get(4)))
	         		mapMCOrderIds.put(4,da_orig.Id);
         	}
         	if(mapMCOrderURLs.get(5) != null)
         	{
	         	if(prettifyURL(da_orig.Published_URL__c) == prettifyURL(mapMCOrderURLs.get(5)))
	         		mapMCOrderIds.put(5,da_orig.Id);
         	}  	
         }
         
         //system.debug('DEBUG:: mapMCOrderIds' + mapMCOrderIds);
         
         //get a collection of the more coverage records whose parents are the collection above (these are the translations)
         for(Digital_Asset__c da_mc: ([select Id, Name, Headline_long__c, Parent_Headline__c, Published_URL_Formula__c from Digital_Asset__c where Parent_Headline__c in: setMCId and Language__c =: sLanguage]))
         {
         	mapTransMCs.put(da_mc.Parent_Headline__c, da_mc);
         }
         //system.debug('DEBUG:: mapTransMCs' + mapTransMCs);
         
         //update the MC fields using the translated MC for the language
         if(mapTransMCs.get(mapMCOrderIds.get(1))!=null)
         {
         	New_Asset.MC_Headline_1__c = mapTransMCs.get(mapMCOrderIds.get(1)).Headline_long__c;
         	New_Asset.MC_URL_1__c = mapTransMCs.get(mapMCOrderIds.get(1)).Published_URL_Formula__c;
         }
         if(mapTransMCs.get(mapMCOrderIds.get(2))!=null)
         {
         	New_Asset.MC_Headline_2__c = mapTransMCs.get(mapMCOrderIds.get(2)).Headline_long__c;     
			New_Asset.MC_URL_2__c = mapTransMCs.get(mapMCOrderIds.get(2)).Published_URL_Formula__c;
         }
         if(mapTransMCs.get(mapMCOrderIds.get(3))!=null)
         {
         	New_Asset.MC_Headline_3__c = mapTransMCs.get(mapMCOrderIds.get(3)).Headline_long__c;
			New_Asset.MC_URL_3__c = mapTransMCs.get(mapMCOrderIds.get(3)).Published_URL_Formula__c;
         }
         if(mapTransMCs.get(mapMCOrderIds.get(4))!=null)
         {
         	New_Asset.MC_Headline_4__c = mapTransMCs.get(mapMCOrderIds.get(4)).Headline_long__c;
			New_Asset.MC_URL_4__c = mapTransMCs.get(mapMCOrderIds.get(4)).Published_URL_Formula__c;
         }
         if(mapTransMCs.get(mapMCOrderIds.get(5))!=null)
         {
         	New_Asset.MC_Headline_5__c = mapTransMCs.get(mapMCOrderIds.get(5)).Headline_long__c;
      		New_Asset.MC_URL_5__c = mapTransMCs.get(mapMCOrderIds.get(5)).Published_URL_Formula__c;
         }
         
         /*
         New_Asset.MC_Headline_1__c = da.MC_Headline_1__c;
         New_Asset.MC_Headline_2__c = da.MC_Headline_2__c;
         New_Asset.MC_Headline_3__c = da.MC_Headline_3__c;
         New_Asset.MC_Headline_4__c = da.MC_Headline_4__c;
         New_Asset.MC_Headline_4__c = da.MC_Headline_4__c;
         New_Asset.MC_Headline_5__c = da.MC_Headline_5__c;
         New_Asset.MC_URL_1__c = da.MC_URL_1__c;
         New_Asset.MC_URL_2__c = da.MC_URL_2__c;
         New_Asset.MC_URL_3__c = da.MC_URL_3__c;
         New_Asset.MC_URL_4__c = da.MC_URL_4__c;
         New_Asset.MC_URL_5__c = da.MC_URL_5__c;*/
         //end Spring 2013 ph 2 enhancement
         
         New_Asset.Microblog__c = da.Microblog__c;
         New_Asset.Mobile_Blurb__c = da.Mobile_Blurb__c;
         New_Asset.Mobile_Headline__c = da.Mobile_Headline__c;
         New_Asset.Multimedia_URL__c = da.Multimedia_URL__c;
         
         //if there is a republish ID in the parent this needs to be passed on to the child
         if(da.Republish_ID__c != null)
         { New_Asset.Parent_Slug_ID__c = da.Republish_ID__c; }
         else
         { New_Asset.Parent_Slug_ID__c = da.Slug_ID__c; }
         New_Asset.Parent_Headline__c = da.Id;
         
         New_Asset.Photo_1_Alt_Text__c = da.Photo_1_Alt_Text__c;
         New_Asset.Photo_1_Caption__c = da.Photo_1_Caption__c;
         New_Asset.Photo_1_Credit__c = da.Photo_1_Credit__c;
         New_Asset.Photo_1_Location__c = da.Photo_1_Location__c;
         New_Asset.Photo_1_URL__c = da.Photo_1_URL__c;
         New_Asset.Photo_2_Alt_Text__c = da.Photo_2_Alt_Text__c;
         New_Asset.Photo_2_Caption__c = da.Photo_2_Caption__c;
         New_Asset.Photo_2_Credit__c = da.Photo_2_Credit__c;
         New_Asset.Photo_2_Location__c = da.Photo_2_Location__c;
         New_Asset.Photo_2_URL__c = da.Photo_2_URL__c;
         New_Asset.Photo_3_Alt_Text__c = da.Photo_3_Alt_Text__c;
         New_Asset.Photo_3_Caption__c = da.Photo_3_Caption__c;
         New_Asset.Photo_3_Credit__c = da.Photo_3_Credit__c;
         New_Asset.Photo_3_Location__c = da.Photo_3_Location__c;
         New_Asset.Photo_3_URL__c = da.Photo_3_URL__c;
         
         New_Asset.Photo_4_Location__c = da.Photo_4_Location__c;
         New_Asset.Photo_4_Credit__c = da.Photo_4_Credit__c;
         New_Asset.Photo_4_Caption__c = da.Photo_4_Caption__c;
         New_Asset.Photo_4_Alt_Text__c = da.Photo_4_Alt_Text__c;
         New_Asset.Photo_4_URL__c = da.Photo_4_URL__c;
         New_Asset.Photo_5_Location__c = da.Photo_5_Location__c;
         New_Asset.Photo_5_Credit__c = da.Photo_5_Credit__c;
         New_Asset.Photo_5_Caption__c = da.Photo_5_Caption__c;
         New_Asset.Photo_5_Alt_Text__c = da.Photo_5_Alt_Text__c;
         New_Asset.Photo_5_URL__c = da.Photo_5_URL__c;
         New_Asset.Photo_6_Location__c = da.Photo_6_Location__c;
         New_Asset.Photo_6_Credit__c = da.Photo_6_Credit__c;
         New_Asset.Photo_6_Caption__c = da.Photo_6_Caption__c;
         New_Asset.Photo_6_Alt_Text__c = da.Photo_6_Alt_Text__c;
         New_Asset.Photo_6_URL__c = da.Photo_6_URL__c;
         
         //New_Asset. = da.Proclamation__c;
         New_Asset.Regional_Feeds__c = da.Regional_Feeds__c;
         New_Asset.Search_Keywords__c = da.Search_Keywords__c;
         New_Asset.Social_Media_Blurb__c = da.Social_Media_Blurb__c;
         //New_Asset. = da.Source__c;
         New_Asset.Staff_Use_Only__c = da.Staff_Use_Only__c;
         New_Asset.Status__c = 'In Translation';
         New_Asset.Thumbnail_Alt_Tag__c = da.Thumbnail_Alt_Tag__c;
         New_Asset.Thumbnail_Credit__c = da.Thumbnail_Credit__c;
         New_Asset.Thumbnail_URL__c = da.Thumbnail_URL__c;
         New_Asset.Top__c = da.Top__c;
         //New_Asset. = da.Translation_Requested_By__c;
         
         New_Asset.OwnerID = UserInfo.getUserId();
         
         errorMessage = 'The Translation Asset has been created and assigned to you.';
         
         try 
         {
            insert New_Asset; 
         }
         catch (Exception ex)
         {
            errorMessage = 'There was an error in inserting this object: \n \n' + ex.getMessage();
         }
      }
      
      return New_Asset.Id + '&&' + errorMessage;
   }
   
   public static String prettifyURL(String inputURL)
   {
		string retVal = inputURL;
		if(inputURL!= '')
		{
			if(inputURL.indexOf('http://')<0)
				retVal = 'http://'+inputURL;
		}	
		return retVal;
   }
   
   
}
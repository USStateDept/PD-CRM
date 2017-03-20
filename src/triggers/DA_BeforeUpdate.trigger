trigger DA_BeforeUpdate on Digital_Asset__c (before insert, before update)
{
   //Spring 2013 Ph2.1 enhancement: create exclusion for copy desk from notification email
   private static final Id CDPermissionSetId = '0PS30000000PJpD';
   private static final Id CDProfileId = '00e30000001MEo5';
   
   Integer iCDPermission = 0;
   List<PermissionSetAssignment> listCopyDeskPermissionSetAssignees = new List<PermissionSetAssignment>([SELECT AssigneeId,Assignee.Name,Id,PermissionSetId,PermissionSet.Name FROM PermissionSetAssignment where PermissionSetId =: CDPermissionSetId AND AssigneeId =: UserInfo.getUserId()]);
   
   if(listCopyDeskPermissionSetAssignees.size()>0)
   	iCDPermission += 1;
   
   if(UserInfo.getProfileId()== CDProfileId)
   	iCDPermission += 1;
   
   
   
   string tempstr = '';
   //Spring 2013 Ph2 enhancment: fetch the copy desk queue and editor info for use in the copy desk notification email
   Map<string,Id> mapCDQNameId = new Map<string,Id>();
   for(QueueSobject q: [SELECT QueueId, Queue.Name FROM QueueSobject  WHERE Queue.Name = 'Copy Desk Queue' LIMIT 1])
   {
		mapCDQNameId.put(q.Queue.Name, q.QueueId);	
   }
   
   Map<Id,String> mapUserIdName = new Map<Id,String>();
   for(User u: [SELECT Id, Name FROM User])
   {
		mapUserIdName.put(u.Id, u.Name);
   }
   
   for(Digital_Asset__c X : Trigger.new)
   {
      //Spring 2013 Ph2 enhancement:
      //variables here so we don't have to wordcount again for the Translation_Word_Count__c
      //X.Article_Body_Word_Count__c = DA_ArticleToXML.WordCount(X.Article_Body__c);
      //X.Top_Word_Count__c = DA_ArticleToXML.WordCount(X.Top__c);
      //X.Headline_Word_Count__c = DA_ArticleToXML.WordCount(X.Headline_Long__c);
      //X.Published_URL__c = DA_ArticleToXML.GenerateURL(X);
      
      //Set all word count fields
      	X.Microblog_Word_Count__c = DA_ArticleToXML.WordCount(X.Microblog__c, X.language__c);
		X.Author_Job_Title_Word_Count__c = DA_ArticleToXML.WordCount(X.Author_Job_Title__c, X.language__c);
		X.Content_Teaser_Word_Count__c = DA_ArticleToXML.WordCount(X.Content_Teaser__c, X.language__c);
		X.Social_Media_Blurb_Word_Count__c = DA_ArticleToXML.WordCount(X.Social_Media_Blurb__c, X.language__c);
		X.Search_Keywords_Word_Count__c = DA_ArticleToXML.WordCount(X.Search_Keywords__c, X.language__c);
		X.Photo_1_Caption_Word_Count__c = DA_ArticleToXML.WordCount(X.Photo_1_Caption__c, X.language__c);
		X.Photo_2_Caption_Word_Count__c = DA_ArticleToXML.WordCount(X.Photo_2_Caption__c, X.language__c);
		X.Photo_3_Caption_Word_Count__c = DA_ArticleToXML.WordCount(X.Photo_3_Caption__c, X.language__c);
		X.Photo_4_Caption_Word_Count__c = DA_ArticleToXML.WordCount(X.Photo_4_Caption__c, X.language__c);
		X.Photo_5_Caption_Word_Count__c = DA_ArticleToXML.WordCount(X.Photo_5_Caption__c, X.language__c);
		X.Photo_6_Caption_Word_Count__c = DA_ArticleToXML.WordCount(X.Photo_6_Caption__c, X.language__c);
		X.Thumbnail_Alt_Tag_Word_Count__c = DA_ArticleToXML.WordCount(X.Thumbnail_Alt_Tag__c, X.language__c);
      
      Integer headCount = DA_ArticleToXML.WordCount(X.Headline_Long__c, X.language__c);
      Integer artBodyCount = DA_ArticleToXML.WordCount(X.Article_Body__c, X.language__c);
      //X.Asset_comments__c = artBodyCount + '';//added for debugging tw
      X.Headline_Word_Count__c = headCount;
      X.Article_Body_Word_Count__c = artBodyCount;
      X.Top_Word_Count__c = DA_ArticleToXML.WordCount(X.Top__c, X.language__c);
      X.Published_URL__c = DA_ArticleToXML.GenerateURL(X);
       
      X.Translation_Word_Count__c = headCount +
      								artBodyCount +
      								DA_ArticleToXML.WordCount(X.Content_Teaser__c, X.language__c) +
      								DA_ArticleToXML.WordCount(X.Social_Media_Blurb__c, X.language__c) +
      								DA_ArticleToXML.WordCount(X.Microblog__c, X.language__c) +
      								DA_ArticleToXML.WordCount(X.Search_Keywords__c, X.language__c) +
      								DA_ArticleToXML.WordCount(X.Photo_1_Alt_Text__c, X.language__c) +
      								DA_ArticleToXML.WordCount(X.Photo_1_Caption__c, X.language__c) +
      								DA_ArticleToXML.WordCount(X.Photo_2_Alt_Text__c, X.language__c) +
      								DA_ArticleToXML.WordCount(X.Photo_2_Caption__c, X.language__c) +
      								DA_ArticleToXML.WordCount(X.Photo_3_Alt_Text__c, X.language__c) +
      								DA_ArticleToXML.WordCount(X.Photo_3_Caption__c, X.language__c) +
      								DA_ArticleToXML.WordCount(X.Photo_4_Alt_Text__c, X.language__c) +
      								DA_ArticleToXML.WordCount(X.Photo_4_Caption__c, X.language__c) +
      								DA_ArticleToXML.WordCount(X.Photo_5_Alt_Text__c, X.language__c) +
      								DA_ArticleToXML.WordCount(X.Photo_5_Caption__c, X.language__c) +
      								DA_ArticleToXML.WordCount(X.Photo_6_Alt_Text__c, X.language__c) +
      								DA_ArticleToXML.WordCount(X.Photo_6_Caption__c, X.language__c);
      
      
      //Spring 2013 enhancements: modified the following CleanFieldContents calls to only run if the contents have changed
      //if(X.Article_Body__c != null) { X.Article_Body__c = DA_WordOutput.CleanFieldContents(X.Article_Body__c); }
      //if(X.Top__c != null) { X.Top__c = DA_WordOutput.CleanFieldContents(X.Top__c); }
      //if(X.Content_Teaser__c != null) { X.Content_Teaser__c = DA_WordOutput.CleanFieldContents(X.Content_Teaser__c); }
      if(X.Article_Body__c != null) 
        { 
            if (Trigger.isUpdate)
            {
                if (Trigger.oldMap.get(X.Id).Article_Body__c != Trigger.newMap.get(X.Id).Article_Body__c)
                    X.Article_Body__c = DA_WordOutput.CleanFieldContents(X.Article_Body__c);
            } 
            if (Trigger.isInsert)
                X.Article_Body__c = DA_WordOutput.CleanFieldContents(X.Article_Body__c);
        }
      if(X.Top__c != null) 
        {
            if (Trigger.isUpdate)
            {
                if (Trigger.oldMap.get(X.Id).Top__c != Trigger.newMap.get(X.Id).Top__c)
                    X.Top__c = DA_WordOutput.CleanFieldContents(X.Top__c); 
            }
            if (Trigger.isInsert)
                X.Top__c = DA_WordOutput.CleanFieldContents(X.Top__c);
        }
        if(X.Content_Teaser__c != null) 
        {
            if (Trigger.isUpdate)
            {
                if (Trigger.oldMap.get(X.Id).Content_Teaser__c != Trigger.newMap.get(X.Id).Content_Teaser__c)
                    X.Content_Teaser__c = DA_WordOutput.CleanFieldContents(X.Content_Teaser__c); 
            }
            if (Trigger.isInsert)
                X.Content_Teaser__c = DA_WordOutput.CleanFieldContents(X.Content_Teaser__c);
        }
        //end spring 2013 changes
        
      //spring 2013 ph 2 change: email alert to copy desk when the owner is changed to copy desk queue
      if(Trigger.isUpdate)
      {
      	System.Debug('DEBUG:: before trigger queue name: ' + mapCDQNameId.get('Copy Desk Queue'));
      	System.Debug('DEBUG:: before trigger X new val: ' + Trigger.newMap.get(X.Id).OwnerId);
      	System.Debug('DEBUG:: before trigger X old val: ' + Trigger.oldMap.get(X.Id).OwnerId);
      	String editor = 'No Editor';
      	if(mapUserIdName.get(X.Editor__c)!=null)
      		editor = mapUserIdName.get(X.Editor__c);
      	if((iCDPermission < 1) && (Trigger.oldMap.get(X.Id).OwnerId != Trigger.newMap.get(X.Id).OwnerId) && (Trigger.newMap.get(X.Id).OwnerId == mapCDQNameId.get('Copy Desk Queue')))
      		DA_Email_Triggers.sendNotificationEmail(X, editor);
      }
        
        
      
      //spring 2013 change: fields are not required in Draft Status but are required in 'In Work' status
      if (X.Status__c == 'In Work')
      {
        if(X.Language__c == '' || X.Language__c == null)
            X.adderror('Language: You must enter a value');
        if(X.Asset_Type__c == '' || X.Asset_Type__c == null)
            X.adderror('Asset Type: You must enter a value');
        if(X.Asset_Subtype__c == '' || X.Asset_Subtype__c == null)
            X.adderror('Asset SubType: You must enter a value');
        if(X.Search_Keywords__c == '' || X.Search_Keywords__c == null)
            X.adderror('Search Keywords: You must enter a value');
      }
      
      if((X.Status__c == 'In Work') &&
         ((X.Language__c != null) && (X.Language__c != '') && (X.Language__c != 'English') && (X.Language__c != 'Non English') && (X.Language__c != 'Non English RTL')))
      {
         System.Debug('DEBUG:: X_Language__c is : ' + X.Language__c);
         X.Status__c = 'In Translation'; 
      }
      
      if(X.Asset_Type__c == 'Table of Contents')
      {
         X.Article_Body__c = DA_TableOfContents.RecompileTOCBody(X);
      }
      
//      tempstr = X.Headline_Long__c;
//      if(tempstr.length() > 80)
//      { X.Name = tempstr.substring(0,79); }
//      else
//      { X.Name = tempstr; }


//      if(X.Article_Body__c != null)
//      { X.Article_Body__c = DA_TranslateData.UpdateBodyURLs(X.Article_Body__c); }
//      if(X.Top__c != null)
//      { X.Top__c = DA_TranslateData.UpdateBodyURLs(X.Top__c); }
//      
//      if(X.MC_URL_1__c != null)
//      { X.MC_URL_1__c = DA_TranslateData.UpdateURL(X.MC_URL_1__c); }
//      if(X.MC_URL_2__c != null)
//      { X.MC_URL_2__c = DA_TranslateData.UpdateURL(X.MC_URL_2__c); }
//      if(X.MC_URL_3__c != null)
//      { X.MC_URL_3__c = DA_TranslateData.UpdateURL(X.MC_URL_3__c); }
//      if(X.MC_URL_4__c != null)
//      { X.MC_URL_4__c = DA_TranslateData.UpdateURL(X.MC_URL_4__c); }
//      if(X.MC_URL_5__c != null)
//      { X.MC_URL_5__c = DA_TranslateData.UpdateURL(X.MC_URL_5__c); }
   }
}
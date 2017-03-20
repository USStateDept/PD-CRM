global without sharing class DA_TableOfContents
{
   public static string RecompileTOCBody(Digital_Asset__c TOC)
   {
      integer counter;
      string tempBody = '';
      string tempstr = '';
      boolean found;
      
      if(TOC.ToC_Hidden__c != null)
      {
         string[] hiddenfield = TOC.ToC_Hidden__c.split('##');

         Digital_Asset__c[] Chapters = [Select d.Published_URL__c, d.ToC_Blurb__c, d.Name,
            d.Headline_Long__c, d.Slug_ID__c, d.ToC_Subheading__c
            from Digital_Asset__c d where d.Publication_Title__c = :TOC.Id]; 
      
         for(counter = 0; counter < hiddenfield.size(); counter++)
         {
            found = false;
            for(Digital_Asset__c X : Chapters)
            {
               if(X.Slug_ID__c == hiddenfield[counter])
               {
                  if(X.ToC_SubHeading__c != null)
                  {
                     tempbody += '<p><b>' + X.ToC_SubHeading__c + '</b></p>';
                  }
                  if(X.ToC_Blurb__c == null)
                  {
                     found = true;
                     tempbody += '<p><a href=\"' + X.Published_URL__c + '\">' + X.Headline_Long__c + '</a><br></p>';
                  }
                  else
                  {
                     tempstr = X.ToC_Blurb__c;
                     tempstr = tempstr.replaceAll('\\<p.*?\\>', '<p>');
                     tempstr = tempstr.replaceFirst('\\<p\\>', '');
                     found = true;
                     tempbody += '<p><a href=\"' + X.Published_URL__c + '\">' + X.Headline_Long__c + '</a><br>' + 
                        tempstr + '</p>';
                  }
               }
            }
            if(found == false)
            {
               tempBody += '<p>Slug ID: ' + hiddenfield[counter] + 'IS NOT ASSOCIATED WITH THIS TOC<br>' +
                  ' Please reorder the chapters to repair';
            }
         }
      }
      
      return tempBody; 
   }
   
   public static void AddAssetTOC(string slugID, string pubID)
   {
      Digital_Asset__c TOC = [Select d.ToC_Hidden__c from Digital_Asset__c d where d.Id = :pubID LIMIT 1];
      
      if(TOC != null)
      {
         TOC.ToC_Hidden__c = DA_TableOfContents.ReallyAddAssetTOC(slugID, TOC.ToC_Hidden__c);
         update TOC;
      }
   }
   
   public static void AddTitleTOC(string SlugID, string pubTitle, string SearchWords,
      string Language, string subtype, boolean force)
   {
      Digital_Asset__c TOC = null;
      
      try
      {
         TOC = [Select d.ToC_Hidden__c, d.Asset_Type__c
            from Digital_Asset__c d where d.Headline_long__c = :pubTitle LIMIT 1];
         
         TOC.ToC_Hidden__c = DA_TableOfContents.ReallyAddAssetTOC(SlugID, TOC.ToC_Hidden__c);
         update TOC;
      }
      catch (System.QueryException i)
      {
         if(force)
         {
            TOC = new Digital_Asset__c();
            
            TOC.Headline_long__c = pubTitle;
            if(pubTitle.length() > 79) { TOC.Name = pubTitle.substring(0, 79);}
            else { TOC.Name = pubTitle; }
            
            TOC.Search_Keywords__c = SearchWords;
            TOC.Language__c = Language;
            TOC.Asset_Type__c = 'Table of Contents';
            TOC.Asset_Subtype__c = Subtype;
            
            insert TOC;
         }
         else {throw i;}
      }
   }
   
   public static string ReallyAddAssetTOC(string slugID, string BodyText)
   {
      string tempBody = BodyText;
      
      if((tempBody == '') || (tempBody == null))
      {
         tempBody = slugID;
      }
      else if(!tempBody.contains(slugID))
      {
         tempBody += '##' + slugID;
      }
      
      return tempBody; 
   }
   
   webservice static string PublishTOC(Digital_Asset__c publishingAsset, User u)
   {
      String tempstr = '###' + publishingAsset.Id + '###';
      Digital_Asset__c parentAsset = null;
      Digital_Asset__c[] parentChapters = new Digital_Asset__c[] {};
      Digital_Asset__c[] TOC_Chapters = 
         [Select d.OwnerID, d.Status__c, d.XML_Output__c, d.Asset_Version__c, d.Article_Rejected__c,
            d.Copy_Editor_1__c, d.Copy_Editor_2__c, d.Parent_Slug_ID__c, d.Translator__c, d.Asset_Creator__c,
            d.Date_of_First_Publish__c, d.Name, d.Published_URL__c, d.Social_Media_Blurb__c, d.Microblog__c,
            d.Language__c, d.Asset_Date_Time__c, d.Publication_Title__c,
            d.Arabic_URL__c, d.Chinese_URL__c, d.English_URL__c, d.French_URL__c, d.Persian_URL__c,
            d.Portuguese_URL__c, d.Russian_URL__c, d.Spanish_URL__c, d.Turkish_URL__c, d.Urdu_URL__c
          from Digital_Asset__c d
          where d.Publication_Title__c = :publishingAsset.Id];
      User pub_dump = 
         [Select u.ID from User u where u.Username LIKE 'pubdump@somewhere.com%' LIMIT 1];
      
      if(publishingAsset.Parent_Slug_ID__c == null)
      {
         DA_PublishArticle.InsertLanguageLink(publishingAsset, publishingAsset.Language__c,
            publishingAsset.Published_URL__c);
            
         for(Digital_Asset__c X : TOC_Chapters)
         {
            DA_PublishArticle.InsertLanguageLink(X, X.Language__c, X.Published_URL__c);
            
            tempstr += DA_PublishArticle.ActuallyPublish(X, pub_dump, parentAsset);
         }
         tempstr += DA_PublishArticle.ActuallyPublish(publishingAsset, pub_dump, parentAsset);
      }
      else
      {
         string parentID = publishingAsset.Parent_Slug_ID__c;
         parentAsset = [Select x.Arabic_URL__c, x.Chinese_URL__c, x.English_URL__c, x.French_URL__c,
            x.Persian_URL__c, x.Portuguese_URL__c, x.Russian_URL__c, x.Spanish_URL__c, x.Turkish_URL__c, x.Urdu_URL__c from Digital_Asset__c x
            where (X.Slug_ID__c = :parentID) OR (X.republish_ID__c = :parentID) LIMIT 1];
         if(parentAsset != null)
         {
            DA_PublishArticle.InsertLanguageLink(parentAsset, publishingAsset.Language__c,
               publishingAsset.Published_URL__c);
            
            parentChapters = [select y.Arabic_URL__c, y.Chinese_URL__c, y.English_URL__c, y.French_URL__c,
               y.Persian_URL__c, y.Portuguese_URL__c, y.Russian_URL__c, y.Spanish_URL__c, y.Turkish_URL__c, y.Urdu_URL__c,
               y.Slug_ID__c, y.republish_ID__c from Digital_Asset__c y
               where y.publication_Title__c = :parentAsset.Id];
            
            boolean found = false;
            
            for(Digital_Asset__c Child : TOC_Chapters)
            {
               for(Digital_Asset__c Parent : parentChapters)
               {
                  if((Child.Parent_Slug_ID__c == Parent.republish_ID__c) || (Child.Parent_Slug_ID__c == Parent.Slug_ID__c))
                  {
                     found = true;
                     DA_PublishArticle.InsertLanguageLink(Parent, Child.Language__c, Child.Published_URL__c);
                     tempstr += DA_PublishArticle.ActuallyPublish(Child, pub_dump, Parent);
                  }
               }
               if(found == false)
               {
                  DA_PublishArticle.InsertLanguageLink(Child, Child.Language__c, Child.Published_URL__c);
                  tempstr += DA_PublishArticle.ActuallyPublish(Child, pub_dump, null);
               }
               found = false;
            }
            
            tempstr += DA_PublishArticle.ActuallyPublish(publishingAsset, pub_dump, parentAsset);
         }
         else
         {
            for(Digital_Asset__c X : TOC_Chapters)
            {
               DA_PublishArticle.InsertLanguageLink(X, X.Language__c, X.published_URL__c);
               
               tempstr += DA_PublishArticle.ActuallyPublish(X, pub_dump, parentAsset);
            }
            tempstr += DA_PublishArticle.ActuallyPublish(publishingAsset, pub_dump, parentAsset);
         }
      }
      
      return tempstr;
   }
   

}
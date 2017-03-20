global with sharing class DA_ArticleToXML
{
    //Stephanie P. (5/29/14) - added global variable to look up proposed url
    public static final String PROPOSED_URL = 'Proposed URL';
    
    //spring 2013 enhancements: added Subheadline__c
   public static String getXML()
   {
      PageReference pageRef = ApexPages.currentPage();
      Map<String, String> parameters = pageRef.getParameters();
      String pId = parameters.get('id');
      
      return generateXML(pId);
   }

   public static String generateXML(String pId) 
   {
      String XML_Stream;
      String PublicationTitle;
      datetime mydate = datetime.now();
      User u;
      
      Digital_Asset__c da = [Select d.Name, d.Subheadline__c, d.Annunciator__c, d.Article_Body__c,
        d.CreatedDate, d.LastModifiedDate, d.Translation_Requested_By__c,
        d.Asset_Date_Time__c, d.Asset_Package__c, d.Asset_Subtype__c, d.Asset_Theme__c,
        d.Asset_Type__c, d.Asset_Version__c, d.Author__c, d.Author_Job_Title__c,
        d.Comment_Permission__c, d.Content_Footer__c, d.Content_Header__c,
        d.Content_Teaser__c, d.Slug_ID__c, d.Include_Byline__c, 
        d.Include_in_RSS_Feed__c, d.Asset_Creator__c, d.CreatedById,
        d.Language__c, d.MC_Headline_1__c, d.MC_Headline_2__c, d.MC_Headline_3__c,
        d.MC_Headline_4__c, d.MC_Headline_5__c, d.MC_URL_1__c, d.MC_URL_2__c,
        d.MC_URL_3__c, d.MC_URL_4__c, d.MC_URL_5__c, d.Microblog__c, 
        d.Mobile_Blurb__c, d.IIP_Internal_Use_Only__c,
        d.Mobile_Headline__c, d.Multimedia_URL__c, d.Parent_Slug_ID__c,
        d.Photo_1_Alt_Text__c, d.Photo_1_Caption__c, d.Photo_1_Credit__c,
        d.Photo_1_URL__c, d.Photo_2_Alt_Text__c, d.Photo_2_Caption__c,
        d.Photo_2_Credit__c, d.Photo_2_URL__c, d.Photo_3_Alt_Text__c, 
        d.Photo_3_Caption__c, d.Photo_3_Credit__c, d.Photo_3_URL__c,
        d.Publication_Title__c, d.Regional_Feeds__c, d.Search_Keywords__c,
        d.Social_Media_Blurb__c, d.Source__c, d.Staff_Use_Only__c,
        d.Thumbnail_Alt_Tag__c, d.Thumbnail_Credit__c, d.Thumbnail_URL__c,
        d.Top__c, Total_Word_Count__c, d.Date_of_First_Publish__c,
        d.Republish_ID__c, d.Test_Asset__c, d.Display_MC_1__c, d.Display_MC_2__c,
        d.Display_MC_3__c, d.Display_MC_4__c, d.Display_MC_5__c, d.Headline_Long__c, Communities__c,
        d.Youtube_ID__c                     
        from Digital_Asset__c d where d.Id = :pId LIMIT 1];

      if(da.Asset_Creator__c != null)
      {
        u = [Select u.Name, u.Title, u.Email from User u where u.id = :da.Asset_Creator__c LIMIT 1];
      }
      else
      {
        u = [Select u.Name, u.Title, u.Email from User u where u.id = :da.CreatedById LIMIT 1];
      }
      
      if(da.Publication_Title__c != null)
      {
         Digital_Asset__c pub = [Select d.Name, d.Subheadline__c, d.Headline_Long__c, d.Asset_Date_Time__c 
            from Digital_Asset__c d 
            where d.Id = :da.Publication_Title__c LIMIT 1];
         
         if(pub != null)
         {
            if(pub.Asset_Date_Time__c == null)
            { PublicationTitle = mydate.format('yyyy.MM') + '.' + pub.Name; }
            else
            { PublicationTitle = pub.Asset_Date_Time__c.format('yyyy.MM') + '.' + pub.Name; }
         }
      }
      else if(da.Asset_Type__c == 'Table of Contents')
      {
         if(da.Asset_Date_Time__c == null)
         { PublicationTitle = mydate.format('yyyy.MM') + '.' + da.Name; }
         else
         { PublicationTitle = da.Asset_Date_Time__c.format('yyyy.MM') + '.' + da.Name; }
      }
      
      XML_Stream = translate(da, u, PublicationTitle);
      
      //return the xml output from the article
      return XML_Stream;
   }

    
    public static Integer wordCount(String Text2Count, String language){
      //public static String[] wordCount(String Text2Count, String language){
      Integer word_count = 0;
      Integer space_count = 0;
      Integer punc_count = 0;
      String temp = Text2Count;  //make a copy to parse through
          //string[] tempArray;//need to comment this out, just for testing for now
        
        if (temp != null){
            if(language.equalsIgnoreCase('Chinese')){
                
                //Remove Chinese punctuation (not contained in standard punctuation set using regex)
                	temp = temp.replaceAll('\\u3002', ''); // period
                	temp = temp.replaceAll('\\uff1f', ''); // question mark
                	temp = temp.replaceAll('\\uff01', ''); // exclamation mark
                	temp = temp.replaceAll('\\uff1a', ''); // full-width colon
                	temp = temp.replaceAll('\\u301c', ''); // wave dash
                	temp = temp.replaceAll('\\u3001', ''); // enumeration comma
                	temp = temp.replaceAll('\\uff0c', ''); // standard comma
                	temp = temp.replaceAll('\\u00b7', ''); // mid-height dot
                	temp = temp.replaceAll('\\u2022', ''); // between-character black filled circle
                	temp = temp.replaceAll('\\uff02', ''); // double-quote
                    temp = temp.replaceAll('\\uff08', ''); // open paren
                    temp = temp.replaceAll('\\uff09', ''); // closing paren
                    temp = temp.replaceAll('\\u300a', ''); // open double angle bracket
                    temp = temp.replaceAll('\\u300b', ''); // closing double angle bracket
                    temp = temp.replaceAll('\\u201c', ''); // open short double quote
                    temp = temp.replaceAll('\\u201d', ''); // closed short double quote
                    temp = temp.replaceAll('\\u002f', ''); // forward slash
                	temp = temp.replaceAll('\\uff1b', ''); // semi-colon
                	temp = temp.replaceAll('\\u300c', ''); // open corner single quote
               		temp = temp.replaceAll('\\u300d', ''); // closing corner single quote
               		temp = temp.replaceAll('\\u300e', ''); // open corner double quote
                	temp = temp.replaceAll('\\u300f', ''); // closing corner double quote
                	temp = temp.replaceAll('\\u3000', ''); // space
                	temp = temp.replaceAll('•', ''); // bullet point inserted by user, not using the <ul> function inside the text area
                    //Detect English and add to count
                    //String englishString = temp;
                
                //Remove all HTML tags
                	temp = temp.replaceAll('<.*?>', ' ');
                
                //Remove all standard punctuation and numbers
                	temp = temp.replaceAll('[\\p{Punct}|\\d]+', '');
                 
                //What does this do?
                    temp = temp.replaceAll('^\\p{P}+$', '');
                
                String englishString = temp;
                
                
              
                
                string[] tempEnglishArray = englishString.split(' ', 0);
               
                
                //Replace all English with null to eliminate the characters from the clean Chinese String
                	List<String> englishAlphabet = new List<String> {'a','b','c','d','e','f','g','h','i','j','k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 
                        'w', 'x', 'y', 'z', 'A','B','C','D','E','F','G','H','I','J','K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z'};
                    
                    //WORKING, DO NOT DELETE
                    List<String> cleanedEnglishArray = new List<String>();
                		for (String s: tempEnglishArray){
                    	//System.debug('English word: ' + s);
                            
                            for (String letter: englishAlphabet){
                    			if(s.contains(letter)){
                        			cleanedEnglishArray.add(s);
                                    //System.debug('clean English: ' +s);
                                    break;
                    			}
                            }

                		}

                	
                
                	//Get English word count
                List<String> normalizedList = new List<String>();
                //String normalized = '';
                for (String s: cleanedEnglishArray){
                    //System.debug('Original clean string: ' + s);
                    String normalized = '';
                    
                    for(integer i=0; i<s.length(); i++){
                        boolean isEnglish = false;
                        for (String l: englishAlphabet){
                            if(s.substring(i,i+1).equalsIgnoreCase(l)){
                                isEnglish = true;
                            	normalized+= 'E';
                                break;
                        	}
                        }
                        if (!isEnglish){
                            //System.debug(s.substring(i,i+1) + ' is not ENGLISH');
                            normalized += ' ';
                        }
                    }
					
                    //System.debug('Normalized string: ' + normalized);
                    normalizedList.add(normalized);
                }
               
                integer engCount = 0;
                for (String s: normalizedList){
                    String[] tempSplit = s.split(' ',0);
                    for (String e: tempSplit){
                        if(e.contains('E')){
                            engCount++;
                        }
                       //System.debug('E: ' + e);
                    }
                }
               
				System.debug ('Englishword count: ' + engCount);
               
                
                
                	
                	//Print array with only items that contain English words
                	/*
                	for(String s: cleanedEnglishArray){
                        for(String letter: englishAlphabet){
                            if (s.substring(s.length()-1, s.length()).equals(letter)){
                                System.debug('2: ' +s);
                                 break;
                            }
                           
                        }	
            		}
                
                */
                
                
                        for(String l: englishAlphabet){
                            temp = temp.replaceAll(l, '');
                        }
                		
                    
                    //Remove all whitespace
                	temp = temp.replaceAll(' ', '');
                
               
                //System.debug('***FINAL clean Chinese string: ' + temp);
                word_count = temp.length() + engCount; //Get number of remaining characters after text has been cleaned + English words
               
        	}else {//for any other language, if specified (same as code in method below)
            	
           		//Remove all HTML tags
                temp = temp.replaceAll('<.*?>', '');
                
                // Clean up non-standarad punctuation, pay attention to replacement as null or single space (important!)
                temp = temp.replaceAll('<', '');
                temp = temp.replaceAll('…', '');
                temp = temp.replaceAll('…', '');
                temp = temp.replaceAll('–', '');
                temp = temp.replaceAll('―', '');
                temp = temp.replaceAll(' ― ',' ');
                temp = temp.replaceAll('•', '');
                temp = temp.replaceAll('«', ''); //delete these small double angle brackets, not attached to word (eliminates false word in French)
                temp = temp.replaceAll('»', ''); // same as above, for closing brackets
                temp = temp.replaceAll('"', '');
                temp = temp.replaceAll(' ۔', ''); //delete small dash, not attached to word (eliminates false word in Urdu)
                temp = temp.replaceall('\\&gt;','');
				temp = temp.replaceall('\\&lt;','');
                
           		//Remove all standard punctuation and numbers
              		temp = temp.replaceAll('[\\p{Punct}|\\d]+', ' ');
                                    
            	//Remove all whitespace
                	temp = temp.replaceAll('[\\p{Space}]+', ' ');
                
                //What does this do?
                	temp = temp.replaceAll('^\\p{P}+$', ' ');
                
                string[] tempArray = temp.split(' ', 0);
              
               
                
                	word_count = 0;
                	for (String t: tempArray){
                    	if (!t.isNumeric()){
                       	 word_count++;
                        	System.debug('Eng: ' + t);
                    	}else{
                        	//System.debug(t + ' is numeric!');
                    	}
                	}
                System.debug('Non-Chinese word count: ' + word_count);
                
            }
      } // end if string !null
      return word_count;
      //return tempArray;
   }
    
   public static integer WordCount(string Text2Count)
   {
      integer word_count = 0;
      string temp = Text2Count;  //make a copy to parse through

      if(Text2Count != null)
      {
         //remove all HTML tags
         temp = temp.replaceAll('<.*?>', ' ');
         
         //remove all punctuation and numbers
         temp = temp.replaceAll('[\\p{Punct}|\\d]+', ' ');

         //replace all whitespace chars with single spaces
         temp = temp.replaceAll('[\\p{Space}]+', ' ');
      
         string[] tempArray = temp.split(' ', 0);
      
         word_count = tempArray.size();
      }
      return word_count;
   }
   
   public static string GenerateURL(Digital_Asset__c dAsset)
   {
      //string AssetURL = 'http://iipdigital.usembassy.gov/st';
      
	  string AssetURL = '';
      string temp;
      
       //Stephanie P. (5/29/14) - The proposed_url value should be changed
       //when moving to fullcopy or production
      Global_Variable__c proposedUrl_c = Global_Variable__c.getValues(PROPOSED_URL);
      if(proposedUrl_c != null)
          AssetURL = proposedUrl_c.value__c;
       
      temp = dAsset.Language__c + '';
      temp = temp.toLowerCase();
      AssetURL += '/' + temp;

      if(dAsset.Asset_Type__c == 'Article')
      {AssetURL += '/article';}
      else if(dAsset.Asset_Type__c == 'Audio')
      {AssetURL += '/audio';}
      else if((dAsset.Asset_Type__c == 'Publication') || (dAsset.Asset_Type__c == 'Table of Contents'))
      {AssetURL += '/publication';}
      else if(dAsset.Asset_Type__c == 'In Brief')
      {AssetURL += '/inbrief';}
      else if(dAsset.Asset_Type__c == 'Photo Gallery')
      {AssetURL += '/gallery';}
      else if(dAsset.Asset_Type__c == 'Text or Transcript')
      {AssetURL += '/texttrans';}
      else if(dAsset.Asset_Type__c == 'Video')
      {AssetURL += '/video';}
      else if(dAsset.Asset_Type__c == 'Pamphlet')
      {AssetURL += '/pamphlet';}
      else if(dAsset.Asset_Type__c == 'Note to Posts')
      {AssetURL += '/none';}

      if(dAsset.Republish_ID__c != null)
      {
         AssetURL += '/' + dAsset.Republish_ID__c.substring(0,4);
         AssetURL += '/' + dAsset.Republish_ID__c.substring(4,6);
         AssetURL += '/' + dAsset.Republish_ID__c;
      }
      else if(dAsset.Slug_ID__c != null)
      {
         AssetURL += '/' + dAsset.Slug_ID__c.substring(0,4);
         AssetURL += '/' + dAsset.Slug_ID__c.substring(4,6);
         AssetURL += '/' + dAsset.Slug_ID__c;
      } 

      AssetURL += '.html';
      
      return AssetURL;
   }
   
   public static String translate(Digital_Asset__c dAsset, User u, string pub)
   {
      XmlStreamWriter w = new XmlStreamWriter();
      string tempstr = '';
      datetime mydate = datetime.now();
      integer counter = 0;
      
      w.writeStartDocument('UTF-8', '1.0');
      
      w.writeStartElement(null, 'IIP_ARTICLE', null);
        w.writeStartElement(null, 'TEMPLATE_VERSION', null);
          w.writeCharacters('4.02');
//          w.writeCharacters('4.00');
        w.writeEndElement();
        
        w.writeStartElement(null, 'LANGUAGE', null);
          w.writeCharacters(dAsset.Language__c);
        w.writeEndElement();
        
        w.writeStartElement(null, 'POSTING_INFO', null);
          w.writeStartElement(null, 'POST_DATE', null);
            w.writeCData(mydate.format('MM/dd/yyyy'));
          w.writeEndElement();
          
          w.writeStartElement(null, 'POST_TIME', null);
            w.writeCData(mydate.format('HH:mm:ss'));
          w.writeEndElement();
        w.writeEndElement();


        w.writeStartElement(null, 'DOCUMENT', null);
          w.writeStartElement(null, 'ARTICLE_DATE', null);
            if(dAsset.Asset_Date_Time__c != null)
            {
               mydate = dAsset.Asset_Date_Time__c;
               w.writeCData(mydate.format('MM/dd/yyyy'));
            }
            else
            {
               mydate = datetime.now();
               w.writeCData(mydate.format('MM/dd/yyyy'));
            }
          w.writeEndElement();
          w.writeStartElement(null, 'ARTICLE_TIME', null);
            if(dAsset.Asset_Date_Time__c != null)
            {
               w.writeCData(dAsset.Asset_Date_Time__c.format('HH:mm:ss'));
            }
            else
            {
                mydate = datetime.now();
                w.writeCData(mydate.format('HH:mm:ss'));
            }
          w.writeEndElement();
          
          w.writeStartElement(null, 'ARTICLE_DATE_IN_LANGUAGE', null);
             if(dAsset.Asset_Date_Time__c != null)
             {
                w.writeCData(DA_TranslateData.TranslateDate(dAsset.Asset_Date_Time__c, dAsset.Language__c));
             }
             else
             {
                mydate = datetime.now();
                w.writeCData(DA_TranslateData.TranslateDate(mydate, dAsset.Language__c));
             }
          w.writeEndElement();
          
          w.writeStartElement(null, 'CONTENT_REQUESTED_BY', null);
            //add something here
          w.writeEndElement();
          
          w.writeStartElement(null, 'TRANSLATION_REQUESTED_BY', null);
            if(dAsset.Translation_Requested_By__c != null)
            { w.writeCharacters(dAsset.Translation_Requested_By__c); }
          w.writeEndElement();
          
          w.writeStartElement(null, 'AUTHORING_INFO', null);
            w.writeStartElement(null, 'CREATE_DATE', null);
              if(dAsset.CreatedDate != null) {w.writeCData(dAsset.CreatedDate.format('yyyy/MM/dd'));}
            w.writeEndElement();
            w.writeStartElement(null, 'ORIGINAL_DATE_OF_PUBLISHING', null);
              if(dAsset.Date_of_First_Publish__c != null) {w.writeCharacters(dAsset.Date_of_First_Publish__c.format('yyyy/MM/dd')); }
            w.writeEndElement();
            w.writeStartElement(null, 'LAST_REVISION_DATE', null);
              if(dAsset.LastModifiedDate != null) {w.writeCData(dAsset.LastModifiedDate.format('yyyy/MM/dd'));}
            w.writeEndElement();
            
            w.writeStartElement(null, 'AUTHOR', null);
              w.writeStartElement(null, 'AUTHOR_NAME', null);
                if(dAsset.Author__c != null) {w.writeCharacters(dAsset.Author__c);}
              w.writeEndElement();
              w.writeStartElement(null, 'AUTHOR_TITLE', null);
                if(dAsset.Author_Job_Title__c != null)
                  {w.writeCharacters(dAsset.Author_Job_Title__c);}
              w.writeEndElement();
              w.writeStartElement(null, 'AUTHOR_EMAIL_ADDRESS', null);
                if(u.Email != null) {w.writeCData(u.Email);}
              w.writeEndElement();
            w.writeEndElement();
          w.writeEndElement();
          
          w.writeStartElement(null, 'WORD_COUNT', null);
            tempstr = dAsset.Total_Word_Count__c + '';
            w.writeCharacters(tempstr);
          w.writeEndElement();
          
          w.writeStartElement(null, 'DOC_TYPE', null);
            if(DAsset.Asset_Subtype__c != null) {w.writeCharacters(dAsset.Asset_Subtype__c);}
          w.writeEndElement();
          
          w.writeStartElement(null, 'ANNUNCIATOR', null);
            if(dAsset.Annunciator__c != null) {w.writeCData(dAsset.Annunciator__c);}
          w.writeEndElement();
          
          w.writeStartElement(null, 'HEADLINE', null);
            if(dAsset.Headline_Long__c != null) { w.writeCData(dAsset.Headline_Long__c); }
          w.writeEndElement();
          
          w.writeStartElement(null, 'SUBHEADLINE', null);
            if(dAsset.Subheadline__c != null) { w.writeCData(dAsset.Subheadline__c); }
          w.writeEndElement();
          
          w.writeStartElement(null, 'SUMMARY', null);
            if(dAsset.Top__c != null) {w.writeCData(GLOBAL_Library.jitScrub(dAsset.Top__c));}
          w.writeEndElement();
          
          w.writeStartElement(null, 'CONTENT_HEADER', null);
            if(dAsset.Content_Header__c != null) {w.writeCData(dAsset.Content_Header__c);}
          w.writeEndElement();
          
          w.writeStartElement(null, 'CONTENT_BODY', null);
            tempstr = '';
            if(dAsset.Include_Byline__c == true)
            {
               if(dAsset.Author__c != null)
               {
                  if(dAsset.Language__c == 'English')
                  { tempstr = 'By '; }
                  else if ((dAsset.Language__c == 'Spanish') || (dAsset.Language__c == 'Portuguese'))
                  { tempstr = 'Por '; }
                  else if (dAsset.Language__c == 'French')
                  { tempstr = 'Par '; }
                  tempstr += dAsset.Author__c + '<BR>';
                  if(dAsset.Author_Job_Title__c != null)
                  {
                     tempstr += dAsset.Author_Job_Title__c + '<BR><BR>';
                  }
               }
            }
            if(dAsset.Article_Body__c != null)
            {
               tempstr += GLOBAL_Library.jitScrub(dAsset.Article_Body__c);
               w.writeCData(tempstr);
            }
          w.writeEndElement();
          
          w.writeStartElement(null, 'CONTENT_FOOTER', null);
            if(dAsset.Content_Footer__c != null) {w.writeCData(dAsset.Content_Footer__c);}
          w.writeEndElement();
          
          w.writeStartElement(null, 'PROCLAMATION', null);
            w.writeCData(
               DA_TranslateData.DetermineProclamation(
                  dAsset.Asset_Type__c, dAsset.Asset_Subtype__c));
          w.writeEndElement();
          
          w.writeStartElement(null, 'CONTENT_TEASER', null);
            if(dAsset.Content_Teaser__c != null) {w.writeCData(GLOBAL_Library.jitScrub(dAsset.Content_Teaser__c));}
          w.writeEndElement();
          
          w.writeStartElement(null, 'CONTENT_FACEBOOK', null);
            if(dAsset.Social_Media_Blurb__c != null) {w.writeCData(dAsset.Social_Media_Blurb__c);}
          w.writeEndElement();
          
          w.writeStartElement(null, 'CONTENT_TWITTER', null);
            if(dAsset.Microblog__c != null) {w.writeCData(dAsset.Microblog__c);}
          w.writeEndElement();
          
          w.writeStartElement(null, 'CONTENT_MOBILE_HEADLINE', null);
            if(dAsset.Mobile_Headline__c != null) {w.writeCData(dAsset.Mobile_Headline__c);}
          w.writeEndElement();
          
          w.writeStartElement(null, 'CONTENT_MOBILE_BLURB', null);
            if(dAsset.Mobile_Blurb__c != null) {w.writeCData(GLOBAL_Library.jitScrub(dAsset.Mobile_Blurb__c));}
          w.writeEndElement();
        w.writeEndElement();
        
        w.writeStartElement(null, 'PUBLISHING_INFO', null);
          w.writeStartElement(null, 'DO_NOT_DISTRIBUTE_ANYWHERE', null);
            if(dAsset.IIP_Internal_Use_Only__c) {w.writeCharacters('1');}
            else {w.writeCharacters('0');}
          w.writeEndElement();
          
          w.writeStartElement(null, 'STAFF_USE_ONLY', null);
            if((dAsset.Asset_Type__c == 'Note to Posts') ||
               (dAsset.Asset_Subtype__c == 'Internal Use Only') ||
               (dAsset.Asset_Subtype__c == 'Discretionary Diplomatic Distribution'))
            {w.writeCharacters('1');}
            else {w.writeCharacters('0');}
          w.writeEndElement();
          
          w.writeStartElement(null, 'INCLUDE_IN_RSS', null);
            if(dAsset.Include_in_RSS_Feed__c) { w.writeCharacters('1'); }
            else{ w.writeCharacters('0'); }
          w.writeEndElement();
          
          w.writeStartElement(null, 'VERSION', null);
            tempstr = dAsset.Asset_Version__c + '';
            w.writeCharacters(tempstr);
          w.writeEndElement();
          
          w.writeStartElement(null, 'SLUG_ID', null);
            if(dAsset.Test_Asset__c == true) {/* Leave it blank on purpose */}
            else if(dAsset.Republish_ID__c != null) {w.writeCData(dAsset.Republish_ID__c);}
            else if(dAsset.Slug_ID__c != null) {w.writeCData(dAsset.Slug_ID__c);}
          w.writeEndElement();
          
          w.writeStartElement(null, 'ROOT_SLUG_ID', null);
            if(dAsset.Parent_Slug_ID__c != null) {w.writeCData(dAsset.Parent_Slug_ID__c);}
          w.writeEndElement();
          
          w.writeStartElement(null, 'PRODUCT_ID', null);
            if(dAsset.Asset_Type__c == 'Article')
            { w.writeCharacters('ARTICLE'); }
            else if(dAsset.Asset_Type__c == 'Text or Transcript')
            { w.writeCharacters('TEXTTRANS'); }
            else if((dAsset.Asset_Type__c == 'Publication') || (dAsset.Asset_Type__c == 'Table of Contents'))
            { w.writeCharacters('PUBLICATION'); }
            else if(dAsset.Asset_Type__c == 'Video')
            { w.writeCharacters('VIDEO'); }
            else if(dAsset.Asset_Type__c == 'Audio')
            { w.writeCharacters('AUDIO'); }
            else if(dAsset.Asset_Type__c == 'Photo Gallery')
            { w.writeCharacters('GALLERY'); }
            else if(dAsset.Asset_Type__c == 'In Brief')
            { w.writeCharacters('INBRIEF'); }
            else if(dAsset.Asset_Type__c == 'Pamphlet')
            { w.writeCharacters('PAMPHLET'); }
            else if(dAsset.Asset_Type__c == 'Note to Posts')
            { w.writeCharacters('NONE'); }
            else
            { w.writeCData('THIS SHOULD NEVER HAPPEN'); }
          w.writeEndElement();
          
          //need to doublecheck this one
          w.writeStartElement(null, 'PRODUCT_ID_NAME', null);
            w.writeCData(dAsset.Asset_Type__c);
          w.writeEndElement();
          
          w.writeStartElement(null, 'IIP_THEME_CODE', null);
            if(dAsset.Asset_Theme__c == 'Democracy/Democratic Institutions')
            {  w.writeCharacters('DEMOC'); }
            else if(dAsset.Asset_Theme__c == 'Regional Stability and Security')
            {  w.writeCharacters('SECURITY'); }
            else if(dAsset.Asset_Theme__c == 'Energy and Environment')
            {  w.writeCharacters('ENERGY'); }
            else if(dAsset.Asset_Theme__c == 'Economic Growth and Development')
            {  w.writeCharacters('ECON'); }
            else if(dAsset.Asset_Theme__c == 'All About America')
            {  w.writeCharacters('AMERICA'); }
            else if(dAsset.Asset_Theme__c == 'Special Initiatives')
            {  w.writeCharacters('SPECIAL'); }
            else
            {  /*No theme was selected so there is nothing to write here*/ }
          w.writeEndElement();
          
          w.writeStartElement(null, 'IIP_THEME_NAME', null);
            if(dAsset.Asset_Theme__c != null) {w.writeCData(dAsset.Asset_Theme__c);}
          w.writeEndElement();
          
          w.writeStartElement(null, 'PACKAGE_TITLE', null);
            if(dAsset.Asset_Package__c != null) {w.writeCData(dAsset.Asset_Package__c.substring(8));}
          w.writeEndElement();
          
          w.writeStartElement(null, 'PACKAGE_TITLE_WITH_YEARMONTH', null);
            if(dAsset.Asset_Package__c != null) {w.writeCData(dAsset.Asset_Package__c);}
          w.writeEndElement();
          
          // This is so that CouchDB will have this value for later
          w.writeStartElement( null, 'EJ_DEPARTMENT', null );
            if (dAsset.Communities__c != null)  { w.writeCData( dAsset.Communities__c ); }
          w.writeEndElement();
          
          for(counter = 0; counter < 30; counter++)
          {
            tempstr = DA_TranslateData.ReturnCategory(counter, dAsset.Regional_Feeds__c, dAsset.Language__c);
            
            if(tempstr == '')
            {
               break;
            }
            
            w.writeStartElement(null, 'CATEGORY' + (counter + 1), null);
              w.writeCData(tempstr);
            w.writeEndElement();
          }
          
          w.writeStartElement(null, 'COUNT_OF_CATEGORIES', null);
            w.writeCharacters(''+ counter);
          w.writeEndElement();
          
          w.writeStartElement(null, 'PUBLICATION_TITLE', null);
            if((pub != null) && (pub != ''))
            { w.writeCharacters(pub.substring(8)); }
          w.writeEndElement();
          
          w.writeStartElement(null, 'PUBLICATION_TITLE_WITH_YEARMONTH', null);
            if((pub != null) && (pub != ''))
            { w.writeCharacters(pub); }
          w.writeEndElement();
          
          w.writeStartElement(null, 'PUBLICATION_TABLE_OF_CONTENTS', null);
            if(dAsset.Asset_Type__c == 'Table of Contents')
            { w.writeCharacters('True'); }
            else
            { w.writeCharacters('False'); }
          w.writeEndElement();
        w.writeEndElement();
        
        w.writeStartElement(null, 'SEARCH_ENGINE_KEYWORDS', null);
          if(dAsset.Search_Keywords__c != null) {w.writeCData(dAsset.Search_Keywords__c);}
        w.writeEndElement();
        
        w.writeStartElement(null, 'MORE_COVERAGE_HEADLINE_1', null);
          if((dAsset.MC_Headline_1__c != null) && (dAsset.Display_MC_1__c == true))
            {w.writeCData(dAsset.MC_Headline_1__c);}
        w.writeEndElement();
        w.writeStartElement(null, 'MORE_COVERAGE_URL_1', null);
          if((dAsset.MC_URL_1__c != null) && (dAsset.Display_MC_1__c == true))
            {w.writeCData(dAsset.MC_URL_1__c);}
        w.writeEndElement();
        
        w.writeStartElement(null, 'MORE_COVERAGE_HEADLINE_2', null);
          if((dAsset.MC_Headline_2__c != null) && (dAsset.Display_MC_2__c == true))
            {w.writeCData(dAsset.MC_Headline_2__c);}
        w.writeEndElement();
        w.writeStartElement(null, 'MORE_COVERAGE_URL_2', null);
          if((dAsset.MC_URL_2__c != null) && (dAsset.Display_MC_2__c == true))
            {w.writeCData(dAsset.MC_URL_2__c);}
        w.writeEndElement();
        
        w.writeStartElement(null, 'MORE_COVERAGE_HEADLINE_3', null);
          if((dAsset.MC_Headline_3__c != null) && (dAsset.Display_MC_3__c == true))
            {w.writeCData(dAsset.MC_Headline_3__c);}
        w.writeEndElement();
        w.writeStartElement(null, 'MORE_COVERAGE_URL_3', null);
          if((dAsset.MC_URL_3__c != null) && (dAsset.Display_MC_3__c == true))
            {w.writeCData(dAsset.MC_URL_3__c);}
        w.writeEndElement();
        
        w.writeStartElement(null, 'MORE_COVERAGE_HEADLINE_4', null);
          if((dAsset.MC_Headline_4__c != null) & (dAsset.Display_MC_4__c == true))
            {w.writeCData(dAsset.MC_Headline_4__c);}
        w.writeEndElement();
        w.writeStartElement(null, 'MORE_COVERAGE_URL_4', null);
          if((dAsset.MC_URL_4__c != null) & (dAsset.Display_MC_4__c == true))
            {w.writeCData(dAsset.MC_URL_4__c);}
        w.writeEndElement();
        
        w.writeStartElement(null, 'MORE_COVERAGE_HEADLINE_5', null);
          if((dAsset.MC_Headline_5__c != null) & (dAsset.Display_MC_5__c == true))
            {w.writeCData(dAsset.MC_Headline_5__c);}
        w.writeEndElement();
        w.writeStartElement(null, 'MORE_COVERAGE_URL_5', null);
          if((dAsset.MC_URL_5__c != null) && (dAsset.Display_MC_5__c == true))
            {w.writeCData(dAsset.MC_URL_5__c);}
        w.writeEndElement();
        
        w.writeStartElement(null, 'SmallPhotoURL1', null);
          if(dAsset.Photo_1_URL__c != null) {w.writeCData(dAsset.Photo_1_URL__c);}
        w.writeEndElement();
        w.writeStartElement(null, 'SmallPhotoCaption1', null);
          if(dAsset.Photo_1_Caption__c != null) {w.writeCData(dAsset.Photo_1_Caption__c);}
        w.writeEndElement();
        w.writeStartElement(null, 'PhotoCredit1', null);
          if(dAsset.Photo_1_Credit__c != null) {w.writeCData(dAsset.Photo_1_Credit__c);}
        w.writeEndElement();
        w.writeStartElement(null, 'PhotoAltText1', null);
          if(dAsset.Photo_1_Alt_Text__c != null) {w.writeCData(dAsset.Photo_1_Alt_Text__c);}
        w.writeEndElement();
        w.writeStartElement(null, 'EnlargedPhotoURL1', null);
          //This field was removed
        w.writeEndElement();
        w.writeStartElement(null, 'EnlargedPhotoCaption1', null);
          //This field was removed
        w.writeEndElement();
        
        w.writeStartElement(null, 'SmallPhotoURL2', null);
          if(dAsset.Photo_2_URL__c != null) {w.writeCData(dAsset.Photo_2_URL__c);}
        w.writeEndElement();
        w.writeStartElement(null, 'SmallPhotoCaption2', null);
          if(dAsset.Photo_2_Caption__c != null) {w.writeCData(dAsset.Photo_2_Caption__c);}
        w.writeEndElement();
        w.writeStartElement(null, 'PhotoCredit2', null);
          if(dAsset.Photo_2_Credit__c != null) {w.writeCData(dAsset.Photo_2_Credit__c);}
        w.writeEndElement();
        w.writeStartElement(null, 'PhotoAltText2', null);
          if(dAsset.Photo_2_Alt_Text__c != null) {w.writeCData(dAsset.Photo_2_Alt_Text__c);}
        w.writeEndElement();
        w.writeStartElement(null, 'EnlargedPhotoURL2', null);
          //This field was removed
        w.writeEndElement();
        w.writeStartElement(null, 'EnlargedPhotoCaption2', null);
          //This field was removed
        w.writeEndElement();
        
        w.writeStartElement(null, 'MULTIMEDIA_PAYLOAD', null);
          w.writeStartElement(null, 'URL', null);
            if(dAsset.Multimedia_URL__c != null) {w.writeCData(dAsset.Multimedia_URL__c);}
          w.writeEndElement();
       //Stephanie P.(5/29/14) - Need to re-add, the code was updated last Fri. (5/23/14)
       //was not exist in some reason
          w.writeStartElement(null, 'YOUTUBE_ID', null);
            if(dAsset.Youtube_ID__c != null) {w.writeCData(dAsset.Youtube_ID__c);}
          w.writeEndElement();
          w.writeStartElement(null, 'THUMBNAIL_URL', null);
            if(dAsset.Thumbnail_URL__C != null) {w.writeCData(dAsset.Thumbnail_URL__C);}
          w.writeEndElement();
          w.writeStartElement(null, 'THUMBNAIL_CREDIT', null);
            if(dAsset.Thumbnail_Credit__c != null) {w.writeCData(dAsset.Thumbnail_Credit__c);}
          w.writeEndElement();
          w.writeStartElement(null, 'THUMBNAIL_ALT_TAG', null);
            if(dAsset.Thumbnail_Alt_Tag__c != null) {w.writeCData(dAsset.Thumbnail_Alt_Tag__c);}
          w.writeEndElement();
        w.writeEndElement();
      w.writeEndElement();
      
      String xmlOutput = w.getXmlString();

      w.close();
      return xmlOutput.trim();
   }

   public static Digital_Asset__c XMLImport(string XML)
   {
      XmlStreamReader datastream = new XmlStreamReader(XML);
      Digital_Asset__c newAsset = new Digital_Asset__c();
      string tempstr = '';
      
      while(datastream.hasNext())
      {
         if(datastream.getEventType() == XmlTag.START_ELEMENT)
         {
            tempstr = datastream.getText();
            if(tempstr == 'value1')
            {}
            else if(tempstr == 'value2')
            {}
            else
            {//some kind of error
            }
         }
         datastream.next();
      }
      
      return newAsset;
   }
}
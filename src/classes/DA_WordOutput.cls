global with sharing class DA_WordOutput
{
   public DA_WordOutput(ApexPages.StandardController stdController)
   {
	messageDisplayed = false;
   }
   public DA_WordOutput()
   {
   	
   }
   public static boolean messageDisplayed {get;set;}
   
   /*public string bom {
get {
return EncodingUtil.base64decode('77u/').tostring();
}
}*/
   
   public static string getassetName()
   {
      String retVal = '';
      PageReference pageRef = ApexPages.currentPage();
      Map<String, String> parameters = pageRef.getParameters();
      string pId = parameters.get('id');
      Digital_Asset__c asset = [Select d.Name from Digital_Asset__c d where d.Id =: pId LIMIT 1];
      retVal = asset.Name;
      retVal = retVal.replaceAll('!','');
      retVal = retVal.replaceAll('\\*','');
      retVal = retVal.replaceAll('\'','');
      retVal = retVal.replaceAll('\\(','');
      retVal = retVal.replaceAll('\\)','');
      retVal = retVal.replaceAll(';','');
      retVal = retVal.replaceAll(':','');
      retVal = retVal.replaceAll('@','');
      retVal = retVal.replaceAll('&','');
      retVal = retVal.replaceAll('=','');
      retVal = retVal.replaceAll('$','');
      retVal = retVal.replaceAll(',','');
      retVal = retVal.replaceAll('/','');
      retVal = retVal.replaceAll('\\?','');
      retVal = retVal.replaceAll('%','');
      retVal = retVal.replaceAll('#','');
      retVal = retVal.replaceAll('\\[','');
      retVal = retVal.replaceAll('\\]','');
      String encoded = EncodingUtil.urlEncode(retVal, 'UTF-8'); //this is being used in the export page to properly display multibyte languages like persian, chinese, etc
      // ! * ' ( ) ; : @ & = + $ , / ? % # [ ] 
      
      
      //String retValFinal = prettifyLanguage(escaped);
      return encoded;
   }
   
   public static string getWordOutput()
   {
      PageReference pageRef = ApexPages.currentPage();
      Map<String, String> parameters = pageRef.getParameters();
      string pId = parameters.get('id');
      string pWithMacro = parameters.get('macro');
      
      if(pWithMacro == null || pWithMacro == '')
      	pwithMacro = 'yes'; //default to include the macro unless it is explicitly rejected
      
      return GenerateWordOutput(pId, pWithMacro);
   }
   
   public pageReference WordImport()
   {
      System.Debug('DEBUG:: wordimport starting..');
      string id = Apexpages.currentPage().getParameters().get('importId'); 
      string text = Apexpages.currentPage().getParameters().get('importText');
      System.Debug('DEBUG:: import text: ' + text);
      System.Debug('DEBUG:: import id: ' + id);
      ReallyWordImport(id, text);
      
	  return null;
   }
   
   public static string CleanFieldContentsImport(string field)
   {
      string retVal = field;
   	  if(retVal != '')
   	  {
   	  	retVal = CleanFieldContents(retVal);
   	  	//adding these for import process cleanup
      	//retVal = retVal.replaceAll('<br.*?>','');
	  	//retVal = retVal.replaceAll('<*?br>','');  
	  	//retVal = retVal.trim();
	  	//retVal = retVal.replaceAll('(\\s+)', ' ');
      	//retVal = retVal.replace('\n', '').replace('\r', '');
      	retVal = retVal.replaceAll('(\\s*<[Bb][Rr]\\s*/?>)+\\s*$', '');
      	retVal = retVal.replace('<p>&nbsp;</p>','');
      	retVal = retVal.replace('<p> </p>','');
      	retVal = retVal.replace('<p>\\s*</p>|<p/>','');
      	retVal = retVal.trim();
   	  }
   	  return retVal;
   }

   
   public static string CleanFieldContents(string field)
   {
      string retVal = field;
      integer temp;

      
      //System.Debug('DEBUG:: input string retVal:' + retVal);
      
      //remove all additional formatting from the div tag
      retVal = retVal.replaceAll('\\<div.*?\\>','<div>');
      
      //System.Debug('DEBUG:: input string retVal1:' + retVal);
      
      //replace all the <div></div> with <p></p>
      retVal = retVal.replaceAll('\\<div\\>','<p>');
      retVal = retVal.replaceAll('\\</div\\>','</p>');
      
      //System.Debug('DEBUG:: input string retVal2:' + retVal);
      
      //remove extra formatting from p tags
      retVal = retVal.replaceAll('\\<p.*?\\>', '<p>');
      
      //System.Debug('DEBUG:: input string retVal3:' + retVal);

      //Kill all font tags
      retVal = retVal.replaceAll('\\</?font.*?\\>', '');
      
      //System.Debug('DEBUG:: input string retVal4:' + retVal);

      //remove all span tags //commenting out to allow ICE plugin in TINYMCE.  Will strip out at publishing.
      //retVal = retVal.replaceAll('\\</?span\\>', '');
      
      //System.Debug('DEBUG:: input string retVal5:' + retVal);

      //remove all information before the leading <p> tag
      temp = retVal.indexOf('<p>');
      if(temp > -1)
      {
      	retVal = retVal.substring(temp);
      	//System.Debug('DEBUG:: input string retVal5a:' + retVal);
      }
      
      //System.Debug('DEBUG:: input string retVal5:' + retVal);
      
      //remove all information following the last </p> tag
      temp = retVal.lastIndexOf('</p>');
      if(temp >= 0)
      {
         if(retVal.substring(0,temp+4).length() >= retVal.length()-4) //spring 2013 ph2: added because the last /p may not be at the end of paragraph
         	retVal = retVal.substring(0, temp + 4);//spring 2013 enhancements: changed this from 3 to 4 due to observation during logging
      }
      
      //System.Debug('DEBUG:: input string retVal6:' + retVal);
      
      //replace all the non breaking spaces with spaces
      retVal = retVal.replaceAll('\\u00a0', ' ');
      
      //System.Debug('DEBUG:: input string retVal7:' + retVal);
      
      //spring 2013 enhancements: simplified regex to save errors through api.  Updates through the ui do not throw error, unless the update is using the soap/ajax kit, which is using the api.
      //replace all empty paragraph tags
      //retVal = retVal.replaceAll('\\<p.*?\\>[\\s\n\r\t\\u00a0]*?\\</p\\>', ''); //orig line that throws error
      //retVal = retVal.replaceAll('\\<p.*?\\>[\\s]*?\\</p\\>', ''); //variant 2, throws error
      retVal = retVal.replaceAll('<p>\\s*</p>|<p/>', ''); //simplified that does not throw error
      
      
      //System.Debug('DEBUG:: input string retVal8:' + retVal);

      return retVal;
   }
   
   public static string StripHTML(string field)
   {
      string retVal = field;
      
      //remove all HTML tags
      retVal = retVal.replaceAll('<.*?>', ' ');
      
      //remove all non breaking spaces
      retVal = retVal.replaceAll('\\u00a0', '');
      

      
      return retVal;
   }
   
   public static string prettifyLanguage(string field)
   {
   	 	//this function is used by the import process to change html codes to characters for display
   	 	//source: http://www.thesauruslex.com/typo/eng/enghtml.htm
   	 	string retVal = field;
   	    //remove extra BR
		retVal = retVal.replaceAll('<br.*?>','');
		retVal = retVal.replaceAll('<*?br>','');
		//replace html code with actual chars
   	 	retVal = retVal.replaceall('\\&ndash;','–');
		retVal = retVal.replaceall('\\&mdash;','—');
		retVal = retVal.replaceall('\\&iexcl;','¡');
		retVal = retVal.replaceall('\\&iquest;','¿');
		retVal = retVal.replaceall('\\&quot;','"');
		retVal = retVal.replaceall('\\&ldquo;','“');
		retVal = retVal.replaceall('\\&rdquo;','”');
		retVal = retVal.replaceall('\\&lsquo;','‘');
		retVal = retVal.replaceall('\\&rsquo;','’');
		retVal = retVal.replaceall('\\&laquo;','«');
		retVal = retVal.replaceall('\\&raquo;','»');
		retVal = retVal.replaceall('\\&nbsp;','  ');
		retVal = retVal.replaceall('\\&amp;','&');
		retVal = retVal.replaceall('\\&cent;','¢');
		retVal = retVal.replaceall('\\&copy;','©');
		retVal = retVal.replaceall('\\&divide;','÷');
		retVal = retVal.replaceall('\\&gt;','>');
		retVal = retVal.replaceall('\\&lt;','<');
		retVal = retVal.replaceall('\\&micro;','µ');
		retVal = retVal.replaceall('\\&middot;','·');
		retVal = retVal.replaceall('\\&para;','¶');
		retVal = retVal.replaceall('\\&plusmn;','±');
		retVal = retVal.replaceall('\\&euro;','€');
		retVal = retVal.replaceall('\\&pound;','£');
		retVal = retVal.replaceall('\\&reg;','®');
		retVal = retVal.replaceall('\\&sect;','§');
		retVal = retVal.replaceall('\\&trade;','™');
		retVal = retVal.replaceall('\\&yen;','¥');
		
		retVal = retVal.replaceall('\\&bull;','•');
		retVal = retVal.replaceall('\\&dagger;','†');
		retVal = retVal.replaceall('\\&permil;','‰');
		
		
		retVal = retVal.replaceall('\\&ordf;','ª');
		retVal = retVal.replaceall('\\&ordm;','º');
		
		retVal = retVal.replaceall('\\&aacute;','á');
		retVal = retVal.replaceall('\\&Aacute;','Á');
		retVal = retVal.replaceall('\\&agrave;','à');
		retVal = retVal.replaceall('\\&Agrave;','À');
		retVal = retVal.replaceall('\\&acirc;','â');
		retVal = retVal.replaceall('\\&Acirc;','Â');
		retVal = retVal.replaceall('\\&aring;','å');
		retVal = retVal.replaceall('\\&Aring;','Å');
		retVal = retVal.replaceall('\\&atilde;','ã');
		retVal = retVal.replaceall('\\&Atilde;','Ã');
		retVal = retVal.replaceall('\\&auml;','ä');
		retVal = retVal.replaceall('\\&Auml;','Ä');
		retVal = retVal.replaceall('\\&aelig;','æ');
		retVal = retVal.replaceall('\\&AElig;','Æ');
		retVal = retVal.replaceall('\\&ccedil;','ç');
		retVal = retVal.replaceall('\\&Ccedil;','Ç');
		retVal = retVal.replaceall('\\&eacute;','é');
		retVal = retVal.replaceall('\\&Eacute;','É');
		retVal = retVal.replaceall('\\&egrave;','è');
		retVal = retVal.replaceall('\\&Egrave;','È');
		retVal = retVal.replaceall('\\&ecirc;','ê');
		retVal = retVal.replaceall('\\&Ecirc;','Ê');
		retVal = retVal.replaceall('\\&euml;','ë');
		retVal = retVal.replaceall('\\&Euml;','Ë');
		retVal = retVal.replaceall('\\&iacute;','í');
		retVal = retVal.replaceall('\\&Iacute;','Í');
		retVal = retVal.replaceall('\\&igrave;','ì');
		retVal = retVal.replaceall('\\&Igrave;','Ì');
		retVal = retVal.replaceall('\\&icirc;','î');
		retVal = retVal.replaceall('\\&Icirc;','Î');
		retVal = retVal.replaceall('\\&iuml;','ï');
		retVal = retVal.replaceall('\\&Iuml;','Ï');
		retVal = retVal.replaceall('\\&ntilde;','ñ');
		retVal = retVal.replaceall('\\&Ntilde;','Ñ');
		retVal = retVal.replaceall('\\&oacute;','ó');
		retVal = retVal.replaceall('\\&Oacute;','Ó');
		retVal = retVal.replaceall('\\&ograve;','ò');
		retVal = retVal.replaceall('\\&Ograve;','Ò');
		retVal = retVal.replaceall('\\&ocirc;','ô');
		retVal = retVal.replaceall('\\&Ocirc;','Ô');
		retVal = retVal.replaceall('\\&oelig;','œ');
		retVal = retVal.replaceall('\\&OElig;','Œ');
		
		retVal = retVal.replaceall('\\&oslash;','ø');
		retVal = retVal.replaceall('\\&Oslash;','Ø');
		retVal = retVal.replaceall('\\&otilde;','õ');
		retVal = retVal.replaceall('\\&Otilde;','Õ');
		retVal = retVal.replaceall('\\&ouml;','ö');
		retVal = retVal.replaceall('\\&Ouml;','Ö');
		retVal = retVal.replaceall('\\&szlig;','ß');
		retVal = retVal.replaceall('\\&uacute;','ú');
		retVal = retVal.replaceall('\\&Uacute;','Ú');
		retVal = retVal.replaceall('\\&ugrave;','ù');
		retVal = retVal.replaceall('\\&Ugrave;','Ù');
		retVal = retVal.replaceall('\\&ucirc;','û');
		retVal = retVal.replaceall('\\&Ucirc;','Û');
		retVal = retVal.replaceall('\\&uuml;','ü');
		retVal = retVal.replaceall('\\&Uuml;','Ü');
		retVal = retVal.replaceall('\\&yuml;','ÿ');
		retVal = retVal.replaceall('\\&#376;','Ÿ');

     return retVal;
   }
   
   
   //spring 2013 Enhancements - enable plain text export without [[[]]] brackets
   public static string getTextOutput()
   {
      PageReference pageRef = ApexPages.currentPage();
      Map<String, String> parameters = pageRef.getParameters();
      string pId = parameters.get('id');
      
      return GenerateTextOutput(pId);
   }
   
   public static string getLanguage()
   {
      PageReference pageRef = ApexPages.currentPage();
      Map<String, String> parameters = pageRef.getParameters();
      string lang = parameters.get('lang');
      
      return lang;
   }
   
   public static Digital_Asset__c fetchAsset(string pId)
   {
   	 Digital_Asset__c asset = 
   	 		[Select d.Asset_Comments__c, d.Language__c, d.Content_Teaser__c, d.Top__c, d.Top_Word_Count__c,
         	d.subheadline__c, d.ToC_SubHeading__c, d.ToC_Blurb__c, d.Author__c, d.Author_Job_Title__c,
            d.Article_Body__c, d.Article_Body_Word_Count__c, d.Search_Keywords__c, d.Social_Media_Blurb__c,
            d.Microblog__c, d.Name, d.Headline_Word_Count__c, d.MC_Headline_1__c, 
            d.MC_Headline_2__c, d.MC_Headline_3__c, d.MC_Headline_4__c, d.MC_Headline_5__c, 
            d.Photo_1_Caption__c, d.Photo_1_Alt_Text__c, d.Photo_1_Credit__c,
            d.Photo_2_Caption__c, d.Photo_2_Alt_Text__c, d.Photo_2_Credit__c,
            d.Photo_3_Caption__c, d.Photo_3_Alt_Text__c, d.Photo_3_Credit__c,
            d.Photo_4_Caption__c, d.Photo_4_Alt_Text__c, d.Photo_4_Credit__c,
            d.Photo_5_Caption__c, d.Photo_5_Alt_Text__c, d.Photo_5_Credit__c,
            d.Photo_6_Caption__c, d.Photo_6_Alt_Text__c, d.Photo_6_Credit__c,
            d.Mobile_Headline__c, d.Mobile_Blurb__c, d.Multimedia_URL__c,
            d.MC_URL_1__c, d.MC_URL_2__c, d.MC_URL_3__c, d.MC_URL_4__c, d.MC_URL_5__c,
            d.Thumbnail_Credit__c, d.headline_long__c, d.Thumbnail_Alt_Tag__c, d.Thumbnail_URL__c,
            d.Author_Job_Title_Word_Count__c, Microblog_Word_Count__c, d.Content_Teaser_Word_Count__c,
            d.Social_Media_Blurb_Word_Count__c, d.Search_Keywords_Word_Count__c, d.Photo_1_Caption_Word_Count__c,
            d.Photo_2_Caption_Word_Count__c, d.Photo_3_Caption_Word_Count__c,
			d.Photo_4_Caption_Word_Count__c, d.Photo_5_Caption_Word_Count__c, d.Photo_6_Caption_Word_Count__c,
			d.Thumbnail_Alt_Tag_Word_Count__c
          from Digital_Asset__c d
          where d.Id = :pId LIMIT 1];
       
       
   	 System.debug(asset.Id + ': ' + asset.Headline_long__c);
   	 return asset;
   }
   
   
   //spring 2013 Enhancements - enable plain text export without [[[]]] brackets
   public static string GenerateTextOutput(string pId)
   {
      String retVal = '';
      Digital_Asset__c asset = fetchAsset(pId);
      
      retVal += DA_WordOutput.addElementText(asset.Headline_Long__c);
      retVal += DA_WordOutput.addElementText(asset.subheadline__c);
      retVal += DA_WordOutput.addElementText(asset.ToC_SubHeading__c);
      retVal += DA_WordOutput.addElementText(asset.ToC_Blurb__c);
      retVal += DA_WordOutput.addElementText(asset.Author__c);
      retVal += DA_WordOutput.addElementText(asset.Author_Job_Title__c);
      retVal += DA_WordOutput.addElementText(asset.Top__c);
      retVal += DA_WordOutput.addElementText(asset.Article_Body__c);
      retVal += DA_WordOutput.addElementText(asset.Content_Teaser__c);
      retVal += DA_WordOutput.addElementText(asset.Social_Media_Blurb__c);
      retVal += DA_WordOutput.addElementText(asset.Microblog__c);
      retVal += DA_WordOutput.addElementText(asset.Search_Keywords__c);
      retVal += DA_WordOutput.addElementText(asset.Photo_1_Caption__c);
      retVal += DA_WordOutput.addElementText(asset.Photo_1_Credit__c); 
      retVal += DA_WordOutput.addElementText(asset.Photo_1_Alt_Text__c);  
      retVal += DA_WordOutput.addElementText(asset.Photo_2_Caption__c);
      retVal += DA_WordOutput.addElementText(asset.Photo_2_Credit__c);
      retVal += DA_WordOutput.addElementText(asset.Photo_2_Alt_Text__c);
      retVal += DA_WordOutput.addElementText(asset.Photo_3_Caption__c);
      retVal += DA_WordOutput.addElementText(asset.Photo_3_Credit__c);
      retVal += DA_WordOutput.addElementText(asset.Photo_3_Alt_Text__c);
      retVal += DA_WordOutput.addElementText(asset.Photo_4_Caption__c);
      retVal += DA_WordOutput.addElementText(asset.Photo_4_Credit__c);
      retVal += DA_WordOutput.addElementText(asset.Photo_4_Alt_Text__c);
      retVal += DA_WordOutput.addElementText(asset.Photo_5_Caption__c);
      retVal += DA_WordOutput.addElementText(asset.Photo_5_Credit__c);
      retVal += DA_WordOutput.addElementText(asset.Photo_5_Alt_Text__c);
      retVal += DA_WordOutput.addElementText(asset.Photo_6_Caption__c);
      retVal += DA_WordOutput.addElementText(asset.Photo_6_Credit__c);
      retVal += DA_WordOutput.addElementText(asset.Photo_6_Alt_Text__c);
      retVal += DA_WordOutput.addElementText(asset.Thumbnail_Credit__c);
      retVal += DA_WordOutput.addElementText(asset.Thumbnail_Alt_Tag__c);
      retVal += DA_WordOutput.addElementText(asset.Multimedia_URL__c);
      if(asset.language__c.equalsIgnoreCase('English')){
      	retVal += '<br><br>' + showWordCountSummary(asset);     
      }

      return retVal;
   }
    
    public static String showWordCountSummary(Digital_Asset__c anAsset){
        Digital_Asset__c asset = anAsset;
        String summary = '<strong> Word count summary:</strong>' + '<br>';
        //Headline
        //Author job title
        //Top
        //Body
        //Content teaser
        //Search keywords
        //Photo captions (photo 1 - 6)
        //Photo credits (photo 1-6)
        //Photo alt text (photo 1-6)
        //Thumbnail alt tag
        if (asset.Headline_Word_Count__c > 0){
            summary += '<br>' + 'Headline: ' + asset.Headline_Word_Count__c;
        }
        if (asset.Author_Job_Title_Word_Count__c > 0){
            summary += '<br>' + 'Author title: ' + asset.Author_Job_Title_Word_Count__c;
        }
        if (asset.Top_Word_Count__c > 0){
            summary += '<br>' + 'Top: ' + asset.Top_Word_Count__c;
        }
        if (asset.Article_Body_Word_Count__c > 0){
            summary += '<br>' + 'Body: ' + asset.Article_Body_Word_Count__c;
        }
        if (asset.Content_Teaser_Word_Count__c > 0){
            summary += '<br>' + 'Content teaser: ' + asset.Content_Teaser_Word_Count__c;
        }
        if (asset.Search_Keywords_Word_Count__c > 0){
            summary += '<br>' + 'Search keywords: ' + asset.Search_Keywords_Word_Count__c;
        }
        
        //Photo captions
        Decimal photoCaptions = asset.Photo_1_Caption_Word_Count__c + asset.Photo_2_Caption_Word_Count__c + asset.Photo_3_Caption_Word_Count__c + 
            asset.Photo_4_Caption_Word_Count__c + asset.Photo_5_Caption_Word_Count__c + asset.Photo_6_Caption_Word_Count__c;
        
        if (photoCaptions > 0){
            summary += '<br>' + 'Photo captions: ' + photoCaptions;
        }
       
        //Photo credits
        Decimal photoCredits = DA_ArticleToXML.wordCount(asset.Photo_1_Credit__c, asset.language__c) + DA_ArticleToXML.wordCount(asset.Photo_2_Credit__c, asset.language__c) +
            DA_ArticleToXML.wordCount(asset.Photo_3_Credit__c, asset.language__c) + DA_ArticleToXML.wordCount(asset.Photo_4_Credit__c, asset.language__c) +
            DA_ArticleToXML.wordCount(asset.Photo_5_Credit__c, asset.language__c) + DA_ArticleToXML.wordCount(asset.Photo_6_Credit__c, asset.language__c);
        
        if (photoCredits > 0){
            summary += '<br>' + 'Photo credits: ' + photoCredits;
        }
        
        //Photo alt text
        Decimal photoAltText = DA_ArticleToXML.wordCount(asset.Photo_1_Alt_Text__c, asset.language__c) + DA_ArticleToXML.wordCount(asset.Photo_2_Alt_Text__c, asset.language__c) +
            DA_ArticleToXML.wordCount(asset.Photo_3_Alt_Text__c, asset.language__c) + DA_ArticleToXML.wordCount(asset.Photo_4_Alt_Text__c, asset.language__c) +
            DA_ArticleToXML.wordCount(asset.Photo_5_Alt_Text__c, asset.language__c) + DA_ArticleToXML.wordCount(asset.Photo_6_Alt_Text__c, asset.language__c);
        if (photoAltText > 0){
            summary += '<br>' + 'Photo alt text: ' + photoAltText;
        }
        if (asset.Thumbnail_Alt_Tag_Word_Count__c > 0){
            summary += '<br>' + 'Thumbnail alt tag: ' + asset.Thumbnail_Alt_Tag_Word_Count__c;
        }
        return summary;
    }
   
   public static string addElementText(string content)
   {
      string retVal = '';
      if(content != NULL)
      {
         retVal += content;
         retVal += '<br><br>';
      }      
      retVal = retVal.replaceAll('','');
      return retVal;
   }
   
   
   
   public static string GenerateWordOutput(string pId, string pWithMacro)
   {
      String retVal = '';
      Digital_Asset__c asset = fetchAsset(pId);
      
      if(pWithMacro == 'no')
      {
	      retVal += DA_WordOutput.addElementText(asset.Asset_Comments__c);
	      retVal += DA_WordOutput.addElementText(asset.Headline_Long__c);
	      retVal += DA_WordOutput.addElementText(asset.subheadline__c);
	      retVal += DA_WordOutput.addElementText(asset.ToC_SubHeading__c);
	      retVal += DA_WordOutput.addElementText(asset.ToC_Blurb__c);
	      retVal += DA_WordOutput.addElementText(asset.Author__c);           
          retVal += DA_WordOutput.addElementText(asset.Author_Job_Title__c);
	      retVal += DA_WordOutput.addElementText(asset.Top__c);
	      retVal += DA_WordOutput.addElementText(asset.Article_Body__c);
	      retVal += DA_WordOutput.addElementText(asset.Search_Keywords__c);
	      retVal += DA_WordOutput.addElementText(asset.Content_Teaser__c);
	      retVal += DA_WordOutput.addElementText(asset.Social_Media_Blurb__c);
	      retVal += DA_WordOutput.addElementText(asset.Microblog__c);
	      retVal += DA_WordOutput.addElementText(asset.Mobile_Headline__c);
	      retVal += DA_WordOutput.addElementText(asset.Mobile_Blurb__c);
	      retVal += DA_WordOutput.addElementText(asset.MC_Headline_1__c);
	      retVal += DA_WordOutput.addElementText(asset.MC_URL_1__c);
	      retVal += DA_WordOutput.addElementText(asset.MC_Headline_2__c);
	      retVal += DA_WordOutput.addElementText(asset.MC_URL_2__c);
	      retVal += DA_WordOutput.addElementText(asset.MC_Headline_3__c);
	      retVal += DA_WordOutput.addElementText(asset.MC_URL_3__c);
	      retVal += DA_WordOutput.addElementText(asset.MC_Headline_4__c);
	      retVal += DA_WordOutput.addElementText(asset.MC_URL_4__c);
	      retVal += DA_WordOutput.addElementText(asset.MC_Headline_5__c);
	      retVal += DA_WordOutput.addElementText(asset.MC_URL_5__c);
	      retVal += DA_WordOutput.addElementText(asset.Photo_1_Caption__c);
	      retVal += DA_WordOutput.addElementText(asset.Photo_1_Credit__c);
	      retVal += DA_WordOutput.addElementText(asset.Photo_1_Alt_Text__c);	      	      
	      retVal += DA_WordOutput.addElementText(asset.Photo_2_Caption__c);
	      retVal += DA_WordOutput.addElementText(asset.Photo_2_Credit__c);
	      retVal += DA_WordOutput.addElementText(asset.Photo_2_Alt_Text__c);	      	      
	      retVal += DA_WordOutput.addElementText(asset.Photo_3_Caption__c);
	      retVal += DA_WordOutput.addElementText(asset.Photo_3_Credit__c);
	      retVal += DA_WordOutput.addElementText(asset.Photo_3_Alt_Text__c);	      	      
	      retVal += DA_WordOutput.addElementText(asset.Photo_4_Caption__c);
	      retVal += DA_WordOutput.addElementText(asset.Photo_4_Credit__c);
	      retVal += DA_WordOutput.addElementText(asset.Photo_4_Alt_Text__c);	      	      
	      retVal += DA_WordOutput.addElementText(asset.Photo_5_Caption__c);
	      retVal += DA_WordOutput.addElementText(asset.Photo_5_Credit__c);
	      retVal += DA_WordOutput.addElementText(asset.Photo_5_Alt_Text__c);	      	      
	      retVal += DA_WordOutput.addElementText(asset.Photo_6_Caption__c);
	      retVal += DA_WordOutput.addElementText(asset.Photo_6_Credit__c);
	      retVal += DA_WordOutput.addElementText(asset.Photo_6_Alt_Text__c);	      	      
	      retVal += DA_WordOutput.addElementText(asset.Thumbnail_Credit__c);
	      retVal += DA_WordOutput.addElementText(asset.Thumbnail_Alt_Tag__c);
	      retVal += DA_WordOutput.addElementText(asset.Thumbnail_URL__c);
	      retVal += DA_WordOutput.addElementText(asset.Multimedia_URL__c);
          if(asset.language__c.equalsIgnoreCase('English')){
      			retVal += '<br><br>' + showWordCountSummary(asset);     
      		}
      }
      else
      {
          retVal += DA_WordOutput.addElement('0', 'EDITORIAL COMMENTS', asset.Asset_Comments__c);
	      retVal += DA_WordOutput.addElement('1', 'HEADLINE', asset.Headline_Long__c);
	      retVal += DA_WordOutput.addElement('2', 'SUBHEAD', asset.subheadline__c);
	      retVal += DA_WordOutput.addElement('3', 'ToC SECTION HEADLINE', asset.ToC_SubHeading__c);
	      retVal += DA_WordOutput.addElement('4', 'ToC BLURB', asset.ToC_Blurb__c);
	      retVal += DA_WordOutput.addElement('5', 'AUTHOR', asset.Author__c);
          retVal += DA_WordOutput.addElement('6', 'AUTHOR TITLE', asset.Author_Job_Title__c);
	      retVal += DA_WordOutput.addElement('7', 'TOP', asset.Top__c);
	      retVal += DA_WordOutput.addElement('8', 'ARTICLE BODY', asset.Article_Body__c);
	      retVal += DA_WordOutput.addElement('9', 'SEARCH KEYWORDS', asset.Search_Keywords__c);
	      retVal += DA_WordOutput.addElement('10', 'TEASER', asset.Content_Teaser__c);
	      retVal += DA_WordOutput.addElement('11', 'SOCIAL MEDIA BLURB', asset.Social_Media_Blurb__c);
	      retVal += DA_WordOutput.addElement('12', 'MICROBLOG', asset.Microblog__c);
	      retVal += DA_WordOutput.addElement('13', 'MOBILE HEADLINE', asset.Mobile_Headline__c);
	      retVal += DA_WordOutput.addElement('14', 'MOBILE BLURB', asset.Mobile_Blurb__c);
	      retVal += DA_WordOutput.addElement('15', 'MORE COVERAGE HEADLINE 1', asset.MC_Headline_1__c);
	      retVal += DA_WordOutput.addElement('16', 'MORE COVERAGE URL 1', asset.MC_URL_1__c);
	      retVal += DA_WordOutput.addElement('17', 'MORE COVERAGE HEADLINE 2', asset.MC_Headline_2__c);
	      retVal += DA_WordOutput.addElement('18', 'MORE COVERAGE URL 2', asset.MC_URL_2__c);
	      retVal += DA_WordOutput.addElement('19', 'MORE COVERAGE HEADLINE 3', asset.MC_Headline_3__c);
	      retVal += DA_WordOutput.addElement('20', 'MORE COVERAGE URL 3', asset.MC_URL_3__c);
	      retVal += DA_WordOutput.addElement('21', 'MORE COVERAGE HEADLINE 4', asset.MC_Headline_4__c);
	      retVal += DA_WordOutput.addElement('22', 'MORE COVERAGE URL 4', asset.MC_URL_4__c);
	      retVal += DA_WordOutput.addElement('23', 'MORE COVERAGE HEADLINE 5', asset.MC_Headline_5__c);
	      retVal += DA_WordOutput.addElement('24', 'MORE COVERAGE URL 5', asset.MC_URL_5__c);
	      retVal += DA_WordOutput.addElement('25', 'IMAGE 1 CAPTION', asset.Photo_1_Caption__c);
	      retVal += DA_WordOutput.addElement('26', 'IMAGE 1 CREDIT', asset.Photo_1_Credit__c );
	      retVal += DA_WordOutput.addElement('27', 'IMAGE 1 ALT TAG', asset.Photo_1_Alt_Text__c);	      
	      retVal += DA_WordOutput.addElement('28', 'IMAGE 2 CAPTION', asset.Photo_2_Caption__c);
	      retVal += DA_WordOutput.addElement('29', 'IMAGE 2 CREDIT', asset.Photo_2_Credit__c);
	      retVal += DA_WordOutput.addElement('30', 'IMAGE 2 ALT TAG', asset.Photo_2_Alt_Text__c);	      
	      retVal += DA_WordOutput.addElement('31', 'IMAGE 3 CAPTION', asset.Photo_3_Caption__c);
	      retVal += DA_WordOutput.addElement('32', 'IMAGE 3 CREDIT', asset.Photo_3_Credit__c);
	      retVal += DA_WordOutput.addElement('33', 'IMAGE 3 ALT TAG', asset.Photo_3_Alt_Text__c);	      
	      retVal += DA_WordOutput.addElement('34', 'IMAGE 4 CAPTION', asset.Photo_4_Caption__c);
	      retVal += DA_WordOutput.addElement('35', 'IMAGE 4 CREDIT', asset.Photo_4_Credit__c);
	      retVal += DA_WordOutput.addElement('36', 'IMAGE 4 ALT TAG', asset.Photo_4_Alt_Text__c);	      
	      retVal += DA_WordOutput.addElement('37', 'IMAGE 5 CAPTION', asset.Photo_5_Caption__c);
	      retVal += DA_WordOutput.addElement('38', 'IMAGE 5 CREDIT', asset.Photo_5_Credit__c);
	      retVal += DA_WordOutput.addElement('39', 'IMAGE 5 ALT TAG', asset.Photo_5_Alt_Text__c);	      
	      retVal += DA_WordOutput.addElement('40', 'IMAGE 6 CAPTION' , asset.Photo_6_Caption__c);
	      retVal += DA_WordOutput.addElement('41', 'IMAGE 6 CREDIT', asset.Photo_6_Credit__c);
	      retVal += DA_WordOutput.addElement('42', 'IMAGE 6 ALT TAG', asset.Photo_6_Alt_Text__c);	      
	      retVal += DA_WordOutput.addElement('43', 'THUMBNAIL CREDIT', asset.Thumbnail_Credit__c);
	      retVal += DA_WordOutput.addElement('44', 'THUMBNAIL ALT TAG', asset.Thumbnail_Alt_Tag__c);
	      retVal += DA_WordOutput.addElement('45', 'THUMBNAIL URL', asset.Thumbnail_URL__c);
	      retVal += DA_WordOutput.addElement('46', 'MULTIMEDIA URL', asset.Multimedia_URL__c);
      }
      
      return retVal;
   }
   
   public static string addElement(string lineNum, string title, string content)
   {
      string retVal = '';
      
      retVal += '[[[[ ' + lineNum + '-';
      retVal += title;
      retVal += ' (do not delete this line)]]]]<br>';
      if(content != NULL)
      {
         retVal += content;
      }
      retVal += '<br><br>';
      
      /*MDRISCOLL 29-March-2013: commented out this block of char substitutions to allow for special chars to be displayed in Word 2007
      //clean the output
	
      retVal = retVal.replaceAll('\\u2014', '—'); //em dash
      retVal = retVal.replaceAll('\\u2019', '\''); //single quote
      retVal = retVal.replaceAll('\\u201c', '"'); //left double quote
      retVal = retVal.replaceAll('\\u201d', '"'); //right double quote
      */
      retVal = retVal.replaceAll('',''); 
      retVal = retVal.trim();   

      return retVal;
   }
   
   public void ReallyWordImport(string assetId, string Text2Import)
   {
      string tempstr = '';
      Digital_Asset__c importAsset = fetchAsset(assetId);

      string[] importArray;
      integer counter = 0;
      integer lastseen = -1;
      
      if(importAsset != null)
      {
         //System.Debug('DEBUG:: orig text: ' + Text2Import);
         importArray = Text2Import.split('\\[\\[\\[\\[|\\]\\]\\]\\]');
         //System.Debug('DEBUG:: importArray:  ' + importArray);
      	 //System.Debug('DEBUG:: importArray.size() ' + importArray.size());
         for(counter = 0; counter < (importArray.size()); counter ++)
         {
            if(importArray[counter].equalsIgnoreCase(' 0-editorial comments (do not delete this line)'))
            { lastseen = 0; }
            else if(importArray[counter].equalsIgnoreCase(' 1-headline (do not delete this line)'))
            { lastseen = 1; }          
            else if(importArray[counter].equalsIgnoreCase(' 2-subhead (do not delete this line)'))
            { lastseen = 2; }
            else if(importArray[counter].equalsIgnoreCase(' 3-toc section headline (do not delete this line)'))
            { lastseen = 3; }
            else if(importArray[counter].equalsIgnoreCase(' 4-toc blurb (do not delete this line)'))
            { lastseen = 4; }
            else if(importArray[counter].equalsIgnoreCase(' 5-author (do not delete this line)'))
            { lastseen = 5; }
            else if(importArray[counter].equalsIgnoreCase(' 6-author title (do not delete this line)'))
            { lastseen = 6; }           
            else if(importArray[counter].equalsIgnoreCase(' 7-top (do not delete this line)'))
            { lastseen = 7; }
            else if(importArray[counter].equalsIgnoreCase(' 8-article body (do not delete this line)'))
            { lastseen = 8; }
            else if(importArray[counter].equalsIgnoreCase(' 9-search keywords (do not delete this line)'))
            { lastseen = 9; }
            else if(importArray[counter].equalsIgnoreCase(' 10-teaser (do not delete this line)'))
            { lastseen = 10; }
            else if(importArray[counter].equalsIgnoreCase(' 11-social media blurb (do not delete this line)'))
            { lastseen = 11; }
            else if(importArray[counter].equalsIgnoreCase(' 12-microblog (do not delete this line)'))
            { lastseen = 12; }
            else if(importArray[counter].equalsIgnoreCase(' 13-mobile headline (do not delete this line)'))
            { lastseen = 13; }
            else if(importArray[counter].equalsIgnoreCase(' 14-mobile blurb (do not delete this line)'))
            { lastseen = 14; }
            else if(importArray[counter].equalsIgnoreCase(' 15-more coverage headline 1 (do not delete this line)'))
            { lastseen = 15; }
            else if(importArray[counter].equalsIgnoreCase(' 16-more coverage url 1 (do not delete this line)'))
            { lastseen = 16; }
            else if(importArray[counter].equalsIgnoreCase(' 17-more coverage headline 2 (do not delete this line)'))
            { lastseen = 17; }
            else if(importArray[counter].equalsIgnoreCase(' 18-more coverage url 2 (do not delete this line)'))
            { lastseen = 18; }
            else if(importArray[counter].equalsIgnoreCase(' 19-more coverage headline 3 (do not delete this line)'))
            { lastseen = 19; }
            else if(importArray[counter].equalsIgnoreCase(' 20-more coverage url 3 (do not delete this line)'))
            { lastseen = 20; }
            else if(importArray[counter].equalsIgnoreCase(' 21-more coverage headline 4 (do not delete this line)'))
            { lastseen = 21; }
            else if(importArray[counter].equalsIgnoreCase(' 22-more coverage url 4 (do not delete this line)'))
            { lastseen = 22; }
            else if(importArray[counter].equalsIgnoreCase(' 23-more coverage headline 5 (do not delete this line)'))
            { lastseen = 23; }
            else if(importArray[counter].equalsIgnoreCase(' 24-more coverage url 5 (do not delete this line)'))
            { lastseen = 24; }
            else if(importArray[counter].equalsIgnoreCase(' 25-image 1 caption (do not delete this line)'))
            { lastseen = 25; }
            else if(importArray[counter].equalsIgnoreCase(' 26-image 1 credit (do not delete this line)'))
            { lastseen = 26; }
            else if(importArray[counter].equalsIgnoreCase(' 27-image 1 alt tag (do not delete this line)'))
            { lastseen = 27; }
            else if(importArray[counter].equalsIgnoreCase(' 28-image 2 caption (do not delete this line)'))
            { lastseen = 28; }
            else if(importArray[counter].equalsIgnoreCase(' 29-image 2 credit (do not delete this line)'))
            { lastseen = 29; }
            else if(importArray[counter].equalsIgnoreCase(' 30-image 2 alt tag (do not delete this line)'))
            { lastseen = 30; }
            else if(importArray[counter].equalsIgnoreCase(' 31-image 3 caption (do not delete this line)'))
            { lastseen = 31; }
            else if(importArray[counter].equalsIgnoreCase(' 32-image 3 credit (do not delete this line)'))
            { lastseen = 32; }
            else if(importArray[counter].equalsIgnoreCase(' 33-image 3 alt tag (do not delete this line)'))
            { lastseen = 33; }
            else if(importArray[counter].equalsIgnoreCase(' 34-image 4 caption (do not delete this line)'))
            { lastseen = 34; }
            else if(importArray[counter].equalsIgnoreCase(' 35-image 4 credit (do not delete this line)'))
            { lastseen = 35; }
            else if(importArray[counter].equalsIgnoreCase(' 36-image 4 alt tag (do not delete this line)'))
            { lastseen = 36; }
            else if(importArray[counter].equalsIgnoreCase(' 37-image 5 caption (do not delete this line)'))
            { lastseen = 37; }
            else if(importArray[counter].equalsIgnoreCase(' 38-image 5 credit (do not delete this line)'))
            { lastseen = 38; }
            else if(importArray[counter].equalsIgnoreCase(' 39-image 5 alt tag (do not delete this line)'))
            { lastseen = 39; }
            else if(importArray[counter].equalsIgnoreCase(' 40-image 6 caption (do not delete this line)'))
            { lastseen = 40; }
            else if(importArray[counter].equalsIgnoreCase(' 41-image 6 credit (do not delete this line)'))
            { lastseen = 41; }
            else if(importArray[counter].equalsIgnoreCase(' 42-image 6 alt tag (do not delete this line)'))
            { lastseen = 42; }
            else if(importArray[counter].equalsIgnoreCase(' 43-thumbnail credit (do not delete this line)'))
            { lastseen = 43; }
            else if(importArray[counter].equalsIgnoreCase(' 44-thumbnail alt tag (do not delete this line)'))
            { lastseen = 44; }
            else if(importArray[counter].equalsIgnoreCase(' 45-thumbnail url (do not delete this line)'))
            { lastseen = 45; }
            else if(importArray[counter].equalsIgnoreCase(' 46-multimedia url (do not delete this line)'))
            { lastseen = 46; }
            else
            {
               if(lastseen == 0) { importAsset.Asset_Comments__c = CleanFieldContentsImport(importArray[counter]); }
               else if(lastseen == 1)
               {
                  tempstr= StripHTML(prettifyLanguage(importArray[counter]));
                  //System.Debug('DEBUG:: tempstr:  ' + tempstr);
                  if(tempstr.length() > 200)
                  { importAsset.Headline_Long__c = tempstr.substring(0,199); }
                  else
                  { importAsset.Headline_Long__c = tempstr; }
                  
                  if(tempstr.length() > 80)
                  { importAsset.Name = tempstr.substring(0,79); }
                  else
                  { importAsset.Name = tempstr; }
               }
               else if(lastseen == 2) { importAsset.subheadline__c = StripHTML(prettifyLanguage(importArray[counter])); }
               else if(lastseen == 3) { importAsset.ToC_SubHeading__c = StripHTML(prettifyLanguage(importArray[counter])); }
               else if(lastseen == 4) { importAsset.ToC_Blurb__c = CleanFieldContentsImport(importArray[counter]); }
               else if(lastseen == 5) { importAsset.Author__c = StripHTML(prettifyLanguage(importArray[counter])); }
               else if(lastseen == 6) { importAsset.Author_Job_Title__c = StripHTML(prettifyLanguage(importArray[counter])); }           
               else if(lastseen == 7) { importAsset.Top__c = CleanFieldContentsImport(importArray[counter]); }
               else if(lastseen == 8) { importAsset.Article_Body__c = CleanFieldContentsImport(importArray[counter]); }
               else if(lastseen == 9) { importAsset.Search_Keywords__c = StripHTML(prettifyLanguage(importArray[counter])); }
               else if(lastseen == 10) { importAsset.Content_Teaser__c = CleanFieldContentsImport(importArray[counter]); }
               else if(lastseen == 11) { importAsset.Social_Media_Blurb__c = StripHTML(prettifyLanguage(importArray[counter])); }
               else if(lastseen == 12) { importAsset.Microblog__c = StripHTML(prettifyLanguage(importArray[counter])); }
               else if(lastseen == 13) { importAsset.Mobile_Headline__c = StripHTML(prettifyLanguage(importArray[counter])); }
               else if(lastseen == 14) { importAsset.Mobile_Blurb__c = StripHTML(prettifyLanguage(importArray[counter])); }
               else if(lastseen == 15) { importAsset.MC_Headline_1__c = StripHTML(prettifyLanguage(importArray[counter])); }
               else if(lastseen == 16) { importAsset.MC_URL_1__c = StripHTML(importArray[counter]); }
               else if(lastseen == 17) { importAsset.MC_Headline_2__c = StripHTML(prettifyLanguage(importArray[counter])); }
               else if(lastseen == 18) { importAsset.MC_URL_2__c = StripHTML(importArray[counter]); }
               else if(lastseen == 19) { importAsset.MC_Headline_3__c = StripHTML(prettifyLanguage(importArray[counter])); }
               else if(lastseen == 20) { importAsset.MC_URL_3__c = StripHTML(importArray[counter]); }
               else if(lastseen == 21) { importAsset.MC_Headline_4__c = StripHTML(prettifyLanguage(importArray[counter])); }
               else if(lastseen == 22) { importAsset.MC_URL_4__c = StripHTML(importArray[counter]); }
               else if(lastseen == 23) { importAsset.MC_Headline_5__c = StripHTML(prettifyLanguage(importArray[counter])); }
               else if(lastseen == 24) { importAsset.MC_URL_5__c = StripHTML(importArray[counter]); }
               else if(lastseen == 25) { importAsset.Photo_1_Caption__c = StripHTML(prettifyLanguage(importArray[counter])); }
               else if(lastseen == 26) { importAsset.Photo_1_Credit__c = StripHTML(prettifyLanguage(importArray[counter])); }
               else if(lastseen == 27) { importAsset.Photo_1_Alt_Text__c = StripHTML(prettifyLanguage(importArray[counter])); }
               else if(lastseen == 28) { importAsset.Photo_2_Caption__c = StripHTML(prettifyLanguage(importArray[counter])); }
               else if(lastseen == 29) { importAsset.Photo_2_Credit__c = StripHTML(prettifyLanguage(importArray[counter])); }
               else if(lastseen == 30) { importAsset.Photo_2_Alt_Text__c = StripHTML(prettifyLanguage(importArray[counter])); }
               else if(lastseen == 31) { importAsset.Photo_3_Caption__c = StripHTML(prettifyLanguage(importArray[counter])); }
               else if(lastseen == 32) { importAsset.Photo_3_Credit__c = StripHTML(prettifyLanguage(importArray[counter])); }
               else if(lastseen == 33) { importAsset.Photo_3_Alt_Text__c = StripHTML(prettifyLanguage(importArray[counter])); }
               else if(lastseen == 34) { importAsset.Photo_4_Caption__c = StripHTML(prettifyLanguage(importArray[counter])); }
               else if(lastseen == 35) { importAsset.Photo_4_Credit__c = StripHTML(prettifyLanguage(importArray[counter])); }
               else if(lastseen == 36) { importAsset.Photo_4_Alt_Text__c = StripHTML(prettifyLanguage(importArray[counter])); }
               else if(lastseen == 37) { importAsset.Photo_5_Caption__c = StripHTML(prettifyLanguage(importArray[counter])); }
               else if(lastseen == 38) { importAsset.Photo_5_Credit__c = StripHTML(prettifyLanguage(importArray[counter])); }
               else if(lastseen == 39) { importAsset.Photo_5_Alt_Text__c = StripHTML(prettifyLanguage(importArray[counter])); }
               else if(lastseen == 40) { importAsset.Photo_6_Caption__c = StripHTML(prettifyLanguage(importArray[counter])); }
               else if(lastseen == 41) { importAsset.Photo_6_Credit__c = StripHTML(prettifyLanguage(importArray[counter])); }
               else if(lastseen == 42) { importAsset.Photo_6_Alt_Text__c = StripHTML(prettifyLanguage(importArray[counter])); }
               else if(lastseen == 43) { importAsset.Thumbnail_Credit__c = StripHTML(prettifyLanguage(importArray[counter])); }
               else if(lastseen == 44) { importAsset.Thumbnail_Alt_Tag__c = StripHTML(prettifyLanguage(importArray[counter])); }
               else if(lastseen == 45) { importAsset.Thumbnail_URL__c = StripHTML(importArray[counter]); }
               else if(lastseen == 46) { importAsset.Multimedia_URL__c = StripHTML(importArray[counter]); }
               lastseen = -1;
            }
         }
         try{
         	
         	update importAsset;
         	ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.INFO,'Import completed successfully. Refresh the parent window to see changes.');
			ApexPages.addMessage(myMsg);
			messageDisplayed = true;
         	}
         catch (System.DMLException ex)
         {
            String errMsg = 'There was an error in importing the asset.  Please contact your system administrator and provide the error text below: \n \n' + ex.getDMLMessage(0);
            System.Debug('DEBUG:: ' + errMsg);
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,errMsg);
			ApexPages.addMessage(myMsg);
			messageDisplayed = true;
         }
      }
   }
   
}
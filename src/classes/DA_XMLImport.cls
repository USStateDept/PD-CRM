@RestResource (urlMapping='/XMLImport/importer/*')
global with sharing class DA_XMLImport
{
    global class XMLObject
    {
    	String slug_id;
        String root_slug_id;
        String language;
        String post_date;
        String post_time;
        String file_name;
        String shortened_url_for_social_media;
        String article_date;
        String article_time;
        String create_date;
        String original_date_of_publishing;
        String editorial_comments;
        String author_name;
        String author_title;
        // Value does not exist in XML
        //String editor_name;
        String source;
        String requester_of_translation;
        String doc_type;
        String annunciator;
        String headline;
        String subheadline;
        String summary;
        String content_header;
        String content_body;
        // Value does not exist in XML
        //String content_footer;
        String proclamation;
        String content_teaser;
        String content_facebook;
        String content_twitter;
        // Value does not exist in XML
        //String content_mobile_headline;
        //String content_mobile_blurb;
        Boolean do_not_distribute_anywhere;
        Boolean staff_use_only;
        Decimal version;
        String product_id;
        String product_id_name;
        String iip_theme_code;
        String package_title_with_yearmonth;
        String category1;
        String category2;
        String category3;
        String category4;
        String category5;
        String category6;
        String category7;
        String category8;
        String category9;
        String category10;
        String category11;
        String category12;
        String category13;
        String category14;
        String category15;
        String category16;
        String category17;
        String category18;
        String category19;
        String category20;
        Integer count_of_categories;
        String publication_title;
        Boolean publication_table_of_contents;
        String search_engine_keywords;
        String more_coverage_headline_1;
        String more_coverage_url_1;
        String more_coverage_headline_2;
        String more_coverage_url_2;
        String more_coverage_headline_3;
        String more_coverage_url_3;
        String more_coverage_headline_4;
        String more_coverage_url_4;
        String more_coverage_headline_5;
        String more_coverage_url_5;
        String smallPhotoUrl1;
        String smallPhotoCaption1;
        String photoCredit1;
        String photoAltText1;
        String enlargedPhotoURL1;
        String enlargedPhotoCaption1;
        String smallPhotoUrl2;
        String smallPhotoCaption2;
        String photoCredit2;
        String photoAltText2;
        String enlargedPhotoURL2;
        String enlargedPhotoCaption2;
        String multimedia_url;
        String thumbnail_url;
        String thumbnail_credit;
        String thumbnail_alt_tag;
    }
    

    @HttpPost
    global static void XMLuploader( XMLObject xml )
    {
        List<String> errors = new List<String>();
        
        Digital_Asset__c asset = new Digital_Asset__c();
        PD_TOC_Asset__c tocAsset = null;

		Boolean duplicate = false;
		
		List<String> truncatedItems = new List<String>();
		
        User owner = [SELECT id FROM User WHERE username like 'pubdump@somewhere.com%' LIMIT 1];
        
        //------ Main Process Starts here -----
        // Verifying to make sure that the asset does not exist in the SF database...
        try
        {
            Digital_Asset__c verifyAsset = [SELECT Id, createdById, Name
                                              FROM Digital_Asset__c
                                             WHERE Slug_ID__c = :xml.slug_id
                                                OR Republish_ID__c = :xml.slug_id];
            
            if (verifyAsset.CreatedById == UserInfo.getUserId())
            {
          		duplicate = true;
          		verifyAsset.Name = 'DUPE_' + verifyAsset.Name;
          		
          		if (verifyAsset.Name.length() > 80)
		        {
		            verifyAsset.Name = verifyAsset.Name.substring( 0, 79 );
		        }
          		update verifyAsset;
            }
            
            if (verifyAsset != null || verifyAsset.Id != null)
            {
                errors.add( xml.language + ' | ' + xml.post_date + ':' + xml.post_time + ' | ' + xml.slug_id + ' | ' + xml.root_slug_id + ' - Slug ID already exists in the database.' );
            }
        }
        catch (Exception e)
        {
            // This is a new record... NOT AN ERROR...
        }

        // All of the asset will have 'Published' status, owned by 'pubdump', and includes feed
        asset.OwnerId = owner.Id;
        asset.Status__c = 'Published';
        asset.Include_in_RSS_Feed__c = true;
        
        asset.Republish_ID__c = xml.slug_id;
        
        // If the root slug id exists, the parent record must exist in the SF database... (it will get rejected if it does not)
        if (xml.root_slug_id != null && xml.root_slug_id.length() > 0)
        {
            try
            {
                Id parentassetID = [SELECT Id
                                      FROM Digital_Asset__c 
                                     WHERE Slug_ID__c = :xml.root_slug_id
                                        OR Republish_ID__c = :xml.root_slug_id LIMIT 1].id;

                asset.Parent_Headline__c = parentassetID;
                asset.Parent_Slug_ID__c = xml.root_slug_id;
            }
            catch (exception e)
            {
                errors.add( 'Parent Headline does not exist.' );
            }
        }
        
        // Verifying the Editor in the SF database
        //try
        //{
        //    Id editor = [SELECT id FROM User WHERE name = :xml.editor_name].id;
        //    asset.Editor__c = editor;
        //}
        //catch (Exception e)
        //{
        //    // Editor does not exist in the Salesforce Database... skip this process...
        //}
        
        if (xml.publication_table_of_contents)
        {
            errors.add( 'The table of content should not come in during this process!' );
        }
        
        // TODO: based on the copy desk's answer, this will be removed.
        asset.Asset_Version__c = xml.version;
        
        asset.Asset_Comments__c = xml.editorial_comments;

        asset.Language__c = xml.language;
        
        // Mapping for Product ID to Asset Type
        if (xml.product_id.equalsIgnoreCase( 'ARTICLE' )){ asset.Asset_Type__c = 'Article'; }
        else if (xml.product_id.equalsIgnoreCase( 'DISCRETIONARY DIPLOMATIC DISTRIBUTION' )) { asset.Asset_Type__c = 'Note to Posts'; }
        else if (xml.product_id.equalsIgnoreCase( 'INBRIEF' )) { asset.Asset_Type__c = 'In Brief'; }
        else if (xml.product_id.equalsIgnoreCase( 'INTERNAL USE ONLY' )) { asset.Asset_Type__c = 'Note to Posts'; }
        else if (xml.product_id.equalsIgnoreCase( 'PODCAST' )) { asset.Asset_Type__c = 'Audio'; }
        else if (xml.product_id.equalsIgnoreCase( 'PUBLICATION' )) { asset.Asset_Type__c = 'PUBLICATION'; }
        else if (xml.product_id.equalsIgnoreCase( 'PUBS' )) { asset.Asset_Type__c = 'PUBLICATION'; }
        else if (xml.product_id.equalsIgnoreCase( 'VIDEO' )) { asset.Asset_Type__c = 'Video'; }
        else if (xml.product_id.equalsIgnoreCase( 'TEXTTRANS' )) { asset.Asset_Type__c = 'Text or Transcript'; }
        else if (xml.product_id.equalsIgnoreCase( 'PAMPHLET' )) { asset.Asset_Type__c = 'Pamphlet'; }
        else if (xml.product_id.equalsIgnoreCase( 'GALLERY' )) { asset.Asset_Type__c = 'Photo Gallery'; }
        else if (xml.product_id.equalsIgnoreCase( 'AUDIO' )) { asset.Asset_Type__c = 'Audio'; }
        else if (xml.product_id.equalsIgnoreCase( 'NOTE TO POSTS' )) { asset.Asset_Type__c = 'Note to Posts'; }
        else if (xml.product_id.equalsIgnoreCase( 'PHOTO GALLERY' )) { asset.Asset_Type__c = 'Photo Gallery'; }
        else { errors.add( 'Product ID did not map with any of the Asset type mapping. The xml value is ' + xml.product_id + ' and SLUG ID - ' + xml.slug_id ); }
        
        // Mapping for IIP Theme Code to Asset Theme
        if(xml.iip_theme_code.equalsIgnoreCase( 'SECURITY' )) { asset.Asset_Theme__c = 'Regional Stability and Security'; }
        else if(xml.iip_theme_code.equalsIgnoreCase( 'ECON' )) { asset.Asset_Theme__c = 'Economic Growth and Development'; }
        else if(xml.iip_theme_code.equalsIgnoreCase( 'ENERGY' )) { asset.Asset_Theme__c = 'Energy and Environment'; }
        else if(xml.iip_theme_code.equalsIgnoreCase( 'AMERICA' )) { asset.Asset_Theme__c = 'All About America'; }
        else if(xml.iip_theme_code.equalsIgnoreCase( 'DEMOC' )) { asset.Asset_Theme__c = 'Democracy/Democratic Institutions'; }
        else if(xml.iip_theme_code.equalsIgnoreCase( 'SPECIAL' )) { asset.Asset_Theme__c = 'Special Initiatives (Event Driven)'; }
        else {}
        //else { if (xml.iip_theme_code != null && (xml.iip_theme_code.length() > 0 || !xml.iip_theme_code.equalsIgnoreCase( 'NULL' ))) errors.add( 'IIP Theme Code did not map with any of the Asset Theme mapping.' ); }
		
        if (xml.doc_type != null && xml.doc_type.length() > 0)
        {
            asset.Asset_Subtype__c = xml.doc_type;
        }
        else
        {
            errors.add( 'DOC_TYPE is null.' );
        }
        
        
        if (xml.package_title_with_yearmonth.equalsIgnoreCase( 'World Water Forum' ))
        {
            asset.Asset_Package__c = '2012.03.World Water Forum';
        }
        else if (xml.package_title_with_yearmonth.equalsIgnoreCase( 'African Growth and Opportunity Act Forum' ))
        {
            asset.Asset_Package__c = '2012.06.African Growth and Opportunity Act Forum';
        }
        else
        {
            asset.Asset_Package__c = xml.package_title_with_yearmonth;
        }

        asset.IIP_Internal_Use_Only__c = xml.do_not_distribute_anywhere;
        
        if (xml.staff_use_only)
        {
            asset.Asset_Subtype__c = 'Internal Use Only';
        }
        
        if (asset.Asset_Subtype__c == 'IIP Staff Written')
        {
            asset.Include_Byline__c = true;
        }
        
        String articleDate = xml.article_date;
        articleDate = articleDate.split( '/' )[2] + '-' + articleDate.split( '/' )[0] + '-' + articleDate.split( '/' )[1] + ' ';

        String articleTime = xml.article_time;
            
        if (articleTime == null || articleTime == '')
        {
            articleTime = '00:00:00';
        }

        articleDate = articleDate + articleTime;
        asset.Asset_Date_Time__c = datetime.valueof( articleDate );
        
        String publishedDate;
    
        if (xml.original_date_of_publishing == null || xml.original_date_of_publishing.length() == 0)
        {
            publishedDate = xml.create_date;
        }
        else
        {
            publishedDate = xml.original_date_of_publishing;
        }

        asset.Date_of_First_Publish__c = datetime.parse( publishedDate + ' 12:00 AM' );
        
        if (xml.headline != null && xml.headline.length() > 0)
        {
            asset.Headline_long__c = xml.headline;
        }
        else
        {
            asset.Headline_long__c = '';
            errors.add( 'Headline is empty.' );
        }
        asset.Author__c = xml.author_name;
        asset.Author_Job_Title__c = xml.author_title;
         
        asset.Top__c = xml.summary;
	    asset.subheadline__c = xml.subheadline;
	    if (asset.subheadline__c != null && asset.subheadline__c.length() > 155)
        {
        	asset.subheadline__c = asset.subheadline__c.substring( 0, 154 );
        	truncatedItems.add( 'Subheadline' );
        }

        asset.Article_Body__c = xml.content_body;
        asset.Content_Teaser__c = xml.content_teaser;
        
        if (asset.Content_Teaser__c != null && asset.Content_Teaser__c.length() > 2990)
        {
        	asset.Content_Teaser__c = asset.Content_Teaser__c.substring( 0, 2990 );
        	truncatedItems.add( 'Content Teaser' );
        }
        
        asset.Social_Media_Blurb__c = xml.content_facebook;
        if (asset.Social_Media_Blurb__c != null && asset.Social_Media_Blurb__c.length() > 1000)
        {
        	asset.Social_Media_Blurb__c = asset.Social_Media_Blurb__c.substring( 0, 999 );
        	truncatedItems.add( 'Social Media Blurb' );
        }
        
        asset.Microblog__c = xml.content_twitter;
        // Value does not exist in XML
        //asset.Mobile_Headline__c = xml.content_mobile_headline;
        //asset.Mobile_Blurb__c = xml.content_mobile_blurb;
        asset.Multimedia_URL__c = xml.multimedia_url;
        asset.Proclamation__c = xml.proclamation;
        if (asset.Proclamation__c != null && asset.Proclamation__c.length() > 254)
        {
        	asset.Proclamation__c = asset.Proclamation__c.substring( 0, 253 );
        	truncatedItems.add( 'Proclamation' );
        }
        
        asset.Translation_Requested_By__c = xml.requester_of_translation;
        
        asset.Thumbnail_URL__c = xml.thumbnail_url;
        asset.Thumbnail_Credit__c = xml.thumbnail_credit;
        asset.Thumbnail_Alt_Tag__c = xml.thumbnail_alt_tag;
        
        if (xml.search_engine_keywords == null || xml.search_engine_keywords.length() == 0)
        {
            asset.Search_Keywords__c = 'add keywords here';
        }
        else
        {
            asset.Search_Keywords__c = xml.search_engine_keywords;
            
            if (asset.Search_Keywords__c != null && asset.Search_Keywords__c.length() > 255)
            {
            	asset.Search_Keywords__c = asset.Search_Keywords__c.substring( 0, 254 );
        		truncatedItems.add( 'Search Keywords' );
            }
        }
        
        asset.Source__c = xml.source;
        
        if (asset.Source__c != null && asset.Source__c.length() > 255)
    	{
    		asset.Source__c = asset.Source__c.substring( 0, 254 );
        	truncatedItems.add( 'Source' );
    	}
        
        if (xml.count_of_categories > 0)
        {           
            asset.Regional_Feeds__c = '';
            asset.Regional_Feeds__c += parsecategory( xml.category1 );
            asset.Regional_Feeds__c += parsecategory( xml.category2 );
            asset.Regional_Feeds__c += parsecategory( xml.category3 );
            asset.Regional_Feeds__c += parsecategory( xml.category4 );
            asset.Regional_Feeds__c += parsecategory( xml.category5 );
            asset.Regional_Feeds__c += parsecategory( xml.category6 );
            asset.Regional_Feeds__c += parsecategory( xml.category7 );
            asset.Regional_Feeds__c += parsecategory( xml.category8 );
            asset.Regional_Feeds__c += parsecategory( xml.category9 );
            asset.Regional_Feeds__c += parsecategory( xml.category10 );
            asset.Regional_Feeds__c += parsecategory( xml.category11 );
            asset.Regional_Feeds__c += parsecategory( xml.category12 );
            asset.Regional_Feeds__c += parsecategory( xml.category13 );
            asset.Regional_Feeds__c += parsecategory( xml.category14 );
            asset.Regional_Feeds__c += parsecategory( xml.category15 );
            asset.Regional_Feeds__c += parsecategory( xml.category16 );
            asset.Regional_Feeds__c += parsecategory( xml.category17 );
            asset.Regional_Feeds__c += parsecategory( xml.category18 );
            asset.Regional_Feeds__c += parsecategory( xml.category19 );
            asset.Regional_Feeds__c += parsecategory( xml.category20 );
        }
        
        asset.Annunciator__c = xml.annunciator;
            
        asset.Content_Header__c = xml.content_header;
        // Value does not exist in the XML
        //asset.Content_Footer__c = xml.content_footer;

        asset.Display_MC_1__c = true;
        asset.MC_Headline_1__c = xml.more_coverage_headline_1;
        if (asset.MC_Headline_1__c != null && asset.MC_Headline_1__c.length() > 255)
        {
        	asset.MC_Headline_1__c = asset.MC_Headline_1__c.substring( 0, 254 );
        	truncatedItems.add( 'More Coverage Headline 1' );
        }

        asset.MC_URL_1__c = xml.more_coverage_url_1;
        if (asset.MC_URL_1__c != null && asset.MC_URL_1__c.length() > 255)
        {
        	asset.MC_URL_1__c = asset.MC_URL_1__c.substring( 0, 254 );
        	truncatedItems.add( 'More Coverage URL 1' );
        }
        
        asset.Display_MC_2__c = true;
        asset.MC_Headline_2__c = xml.more_coverage_headline_2;
        if (asset.MC_Headline_2__c != null && asset.MC_Headline_2__c.length() > 255)
        {
        	asset.MC_Headline_2__c = asset.MC_Headline_2__c.substring( 0, 254 );
        	truncatedItems.add( 'More Coverage Headline 2' );
        }

        asset.MC_URL_2__c = xml.more_coverage_url_2;
        if (asset.MC_URL_2__c != null && asset.MC_URL_2__c.length() > 255)
        {
        	asset.MC_URL_2__c = asset.MC_URL_2__c.substring( 0, 254 );
        	truncatedItems.add( 'More Coverage URL 2' );
        }
        
        asset.Display_MC_3__c = true;
        asset.MC_Headline_3__c = xml.more_coverage_headline_3;
        
        asset.MC_URL_3__c = xml.more_coverage_url_3;
        if (asset.MC_URL_3__c != null && asset.MC_URL_3__c.length() > 255)
        {
        	asset.MC_URL_3__c = asset.MC_URL_3__c.substring( 0, 254 );
        	truncatedItems.add( 'More Coverage URL 3' );
        }
        
        asset.Display_MC_4__c = true;
        asset.MC_Headline_4__c = xml.more_coverage_headline_4;
        asset.MC_URL_4__c = xml.more_coverage_url_4;
        
        asset.Display_MC_5__c = true;
        asset.MC_Headline_5__c = xml.more_coverage_headline_5;
        asset.MC_URL_5__c = xml.more_coverage_url_5;
        if (asset.MC_URL_5__c != null && asset.MC_URL_5__c.length() > 255)
        {
        	asset.MC_URL_5__c = asset.MC_URL_5__c.substring( 0, 254 );
        	truncatedItems.add( 'More Coverage URL 5' );
        }
        

        if (xml.enlargedPhotoURL1 != null && xml.enlargedPhotoURL1.length() > 0)
        {   
            asset.Photo_1_URL__c = xml.enlargedPhotoURL1;
            asset.Photo_1_Caption__c = xml.enlargedPhotoCaption1;
        }
        else
        {
            asset.Photo_1_URL__c = xml.smallPhotoURL1;
            asset.Photo_1_Caption__c = xml.smallPhotoCaption1;
        }
        
        if (asset.Photo_1_Caption__c != null && asset.Photo_1_Caption__c.length() > 255)
        {
        	asset.Photo_1_Caption__c = asset.Photo_1_Caption__c.substring( 0, 254 );
        	truncatedItems.add( 'Photo 1 Caption' );
        }
        
        asset.Photo_1_Credit__c = xml.photoCredit1;
        asset.Photo_1_Alt_Text__c = xml.photoAltText1;
        if (asset.Photo_1_Alt_Text__c != null && asset.Photo_1_Alt_Text__c.length() > 255)
        {
        	asset.Photo_1_Alt_Text__c = asset.Photo_1_Alt_Text__c.substring( 0, 254 );
        	truncatedItems.add( 'Photo 1 Alt Text' );
        }
        
        if (xml.enlargedPhotoURL2 != null && xml.enlargedPhotoURL2.length() > 0)
        {   
            asset.Photo_2_URL__c = xml.enlargedPhotoURL2;
            asset.Photo_2_Caption__c = xml.enlargedPhotoCaption2;
        }
        else
        {
            asset.Photo_2_URL__c = xml.smallPhotoURL2;
            asset.Photo_2_Caption__c = xml.smallPhotoCaption2;
        }
        
        if (asset.Photo_2_Caption__c != null && asset.Photo_2_Caption__c.length() > 255)
        {
        	asset.Photo_2_Caption__c = asset.Photo_2_Caption__c.substring( 0, 254 );
        	truncatedItems.add( 'Photo 2 Caption' );
        }
        
        asset.Photo_2_Credit__c = xml.photoCredit2;
        asset.Photo_2_Alt_Text__c = xml.photoAltText2;
        if (asset.Photo_2_Alt_Text__c != null && asset.Photo_2_Alt_Text__c.length() > 255)
        {
        	asset.Photo_2_Alt_Text__c = asset.Photo_2_Alt_Text__c.substring( 0, 254 );
        	truncatedItems.add( 'Photo 2 Alt Text' );
        }
        
        if (asset.Headline_long__c.length() > 80)
        {
            asset.Name = asset.Headline_long__c.substring( 0, 79 );
        }
        else
        {
            asset.Name = asset.Headline_long__c; 
        }
        
        if (duplicate)
        {
        	asset.Name = 'DUPE_' + asset.Name;
        	
        	if (asset.Name.length() > 80)
	        {
	            asset.Name = asset.Name.substring( 0, 79 );
	        }
        }
        
        asset.Article_Body_Word_Count__c = DA_ArticleToXML.WordCount( asset.Article_Body__c, asset.Language__c );
        asset.Top_Word_Count__c = DA_ArticleToXML.WordCount( asset.Top__c, asset.Language__c);
        asset.Headline_Word_Count__c = DA_ArticleToXML.WordCount( asset.Headline_Long__c, asset.Language__c);
        asset.Published_URL__c = DA_ArticleToXML.GenerateURL( asset );
        
        // setting up the ToC will be the last step...
        if (xml.publication_title != null && xml.publication_title.length() > 0)
        {
            Digital_Asset__c toc = null;
    
            try
            {
                toc = [SELECT id, ToC_Hidden__c, Article_Body__c 
                         FROM Digital_Asset__c 
                        WHERE Headline_long__c = :xml.publication_title 
                          AND Asset_Type__c = 'Table of Contents'
                          AND Language__c = :xml.language
                        LIMIT 1];
                errors.add( 'ToC already exist in the database! Slug ID: ' + xml.slug_id );
            }
            catch (Exception e)
            {
                // The TOC does not exist in the SF database... This TOC will get imported in the 2nd part of the import.
                insert asset;
                tocAsset = new PD_TOC_Asset__c();
                tocAsset.Headline__c = XML.PUBLICATION_TITLE;
                tocAsset.Publishing_Asset__c = asset.id;
                insert( tocAsset );
            }
        }
	
		if (duplicate)
		{
			if (errors.size() == 1)
			{
				try
	            {
	            	if (truncatedItems.size() > 0)
	            	{
	            		asset.Asset_Comments__c += 'Follow fields have been truncated from the XML import process -<br/><br/>';
	            		
		            	for (String truncatedStr : truncatedItems)
		            	{
		            		asset.Asset_Comments__c += '-' + truncatedStr + '<br/><br/>';
		            	}
	            	}
	            	
	                upsert asset;
	            }
	            catch (Exception e)
	            {
	                errors.add( e.getMessage() );
	            }
			}
		}
	
        if (errors.size() == 0)
        {
            try
            {
            	if (truncatedItems.size() > 0)
            	{
            		asset.Asset_Comments__c += 'The following fields have been truncated from the XML import process -<br/><br/>';
            		
	            	for (String truncatedStr : truncatedItems)
	            	{
	            		asset.Asset_Comments__c += '-' + truncatedStr + '<br/><br/>';
	            	}
            	}
            	
                upsert asset;
            }
            catch (Exception e)
            {
                errors.add( e.getMessage() );
            }
        }
        RestRequest request = RestContext.request;
        RestResponse res = RestContext.response;
        
        String xpath = '{"xpath":""}';
	        
        if (request != null)
    	{
    		xpath = '{"xpath" : "' + request.headers.get( 'X-Path' ) + '"}';
    	}
	         
        if (res != null)
        {
	        res.addHeader( 'Content-Type', 'application/json' );
	        String jsonResponse = '';
	        
	        if (errors.size() > 0)
	        {
	            String errorMsg = 'ERROR(S):';
	            for (String err : errors)
	            {
	                errorMsg += err + ' ';
	            }   
	            
	            res.statusCode = 400;
	            jsonResponse = '{"response": [{"status": "Failure", "message": "' + errorMsg + '"},' + xpath + '],"processedBY":"'+ UserInfo.getUserId() +'"}';
	            res.responseBody = blob.valueOf( jsonResponse );
	        }
	        else
	        {
	            res.statusCode = 201;
	            jsonResponse = '{"response": [{"assetID": "' + asset.id  + '",' + xpath + '],"processedBY":"'+ UserInfo.getUserId() +'"}';
	            res.responseBody = blob.valueOf(jsonResponse);
	        }
        }
    }
    
 
    public static string parseCategory( String category )
    {
        String rssFeed = '';
        
        if (category != null && category.length() > 0)  
        {
            // Africa, Table of Contents, 50 States, POTUS, Secretary of States, Iran, Iraq and Summit of the Americas ( 1=1 mapping ) //TW updated Iraq 26 Aug 2014
            if (category.containsIgnoreCase( 'Africa' )) { rssFeed = 'Africa'; }
            else if (category.containsIgnoreCase( 'TOC' )) { rssFeed = 'Table of Contents'; }
            else if (category.containsIgnoreCase( '50STATES' )) { rssFeed = '50 States'; }
            else if (category.containsIgnoreCase( 'POTUS' )) { rssFeed = 'POTUS'; }
            else if (category.containsIgnoreCase( 'SECSTATE' )) { rssFeed = 'Secretary of States'; }
            else if (category.containsIgnoreCase( 'IRAN' )) { rssFeed = 'Iran'; }
            else if (category.containsIgnoreCase( 'IRAQ' )) { rssFeed = 'Iraq'; } //TW added 26 Aug 2014
            else if (category.containsIgnoreCase( 'Summit of the Americas' )) { rssFeed = 'Summit of the Americas'; }
            
            // Western Hemisphere
            else if (category.containsIgnoreCase( 'AMERICAS' )) { rssFeed = 'Western Hemisphere'; }
            else if (category.containsIgnoreCase( 'CENTAM' )) { rssFeed = 'Western Hemisphere'; }
            else if (category.containsIgnoreCase( 'MEXICO' )) { rssFeed = 'Western Hemisphere'; }
            else if (category.containsIgnoreCase( 'SOUTHAMERICA' )) { rssFeed = 'Western Hemisphere'; }
            else if (category.containsIgnoreCase( 'BRAZIL' )) { rssFeed = 'Western Hemisphere'; }
            else if (category.containsIgnoreCase( 'Central America and the Caribbean' )) { rssFeed = 'Western Hemisphere'; }
            else if (category.containsIgnoreCase( 'South America' )) { rssFeed = 'Western Hemisphere'; }
            
            // Europe & Eurasia
            else if (category.containsIgnoreCase( 'EUR' )) { rssFeed = 'Europe & Eurasia'; }
            else if (category.containsIgnoreCase( 'RUEAP' )) { rssFeed = 'Europe & Eurasia'; }
            else if (category.containsIgnoreCase( 'RUEUR' )) { rssFeed = 'Europe & Eurasia'; }
            else if (category.containsIgnoreCase( 'USINFO/Regions/Countries of the former USSR' )) { rssFeed = 'Europe & Eurasia'; }
            else if (category.containsIgnoreCase( 'Russia' )) { rssFeed = 'Europe & Eurasia'; }
            
            // Middle East & North Africa
            else if (category.containsIgnoreCase( 'MENA' )) { rssFeed = 'Middle East & North Africa'; }
            else if (category.containsIgnoreCase( 'MIDEASTNAF' )) { rssFeed = 'Middle East & North Africa'; }
            else if (category.containsIgnoreCase( 'MIDEAST' )) { rssFeed = 'Middle East & North Africa'; }
            else if (category.containsIgnoreCase( 'Middle East and South Asia' )) { rssFeed = 'Middle East & North Africa'; }
            else if (category.containsIgnoreCase( 'Middle East-North Africa' )) { rssFeed = 'Middle East & North Africa'; }
            else if (category.containsIgnoreCase( 'MiddleEastNorthAfrica' )) { rssFeed = 'Middle East & North Africa'; }
            
            // East Asia & Pacific
            else if (category.containsIgnoreCase( 'EAP' )) { rssFeed = 'East Asia & Pacific'; }
            else if (category.containsIgnoreCase( 'EASIA' )) { rssFeed = 'East Asia & Pacific'; }
            else if (category.containsIgnoreCase( '/Asia' )) { rssFeed = 'East Asia & Pacific'; }
            else if (category.containsIgnoreCase( 'East Asia and the Pacific' )) { rssFeed = 'East Asia & Pacific'; }
            else if (category.containsIgnoreCase( 'BURMA' )) { rssFeed = 'East Asia & Pacific'; }
            else if (category.containsIgnoreCase( 'NORTHKOREA' )) { rssFeed = 'East Asia & Pacific'; }
            else if (category.containsIgnoreCase( 'USCHINA' )) { rssFeed = 'East Asia & Pacific'; }
            
            // South & Central Asia
            else if (category.containsIgnoreCase( 'SCA' )) { rssFeed = 'South & Central Asia'; }
            else if (category.containsIgnoreCase( 'SCENTASIA' )) { rssFeed = 'South & Central Asia'; }
            else if (category.containsIgnoreCase( 'CENTASIA' )) { rssFeed = 'South & Central Asia'; }
            else if (category.containsIgnoreCase( 'South Asia' )) { rssFeed = 'South & Central Asia'; }
            else if (category.containsIgnoreCase( 'SouthAsia' )) { rssFeed = 'South & Central Asia'; }
        }
        return rssFeed + ';';
    }
    

    public static testmethod void TestXMLuploader()
    {
        XMLObject bob = new XMLObject();
        
        //bob.TEMPLATE_VERSION; //not saved
        bob.LANGUAGE = 'English';
        //bob.POST_DATE; //not saved
        //bob.POST_TIME; //not saved
        //bob.FILE_NAME; //not saved
        //bob.SHORTENED_URL_FOR_SOCIAL_MEDIA; //not saved
        bob.ARTICLE_DATE = '04/08/2010';
        bob.ARTICLE_TIME = '00:00:00';
        //bob.ARTICLE_DATE_IN_LANGUAGE; //not saved
        //bob.CREATE_DATE; //not saved
        bob.ORIGINAL_DATE_OF_PUBLISHING = '05/05/2010';
        //bob.LAST_REVISION_DATE; //not saved
        bob.EDITORIAL_COMMENTS = 'mary had a little lamb';
        bob.AUTHOR_NAME = 'test process';
        bob.AUTHOR_TITLE = 'some script';
        bob.SOURCE = 'The One power';
        bob.requester_of_translation = 'everyone';
        bob.DOC_TYPE = 'Byliner';
        //bob.ANNUNCIATOR; //not saved
        bob.HEADLINE = 'test code';
        bob.SUBHEADLINE = 'test code';
        bob.SUMMARY = 'all kinds of random stuff';
        //bob.CONTENT_HEADER; //not saved
        bob.CONTENT_BODY = 'more random stuff';
        //bob.CONTENT_FOOTER; //not saved
        bob.PROCLAMATION = 'random';
        bob.CONTENT_TEASER = 'teaser';
        bob.CONTENT_FACEBOOK = 'facebook';
        bob.CONTENT_TWITTER = 'twitter';
        
        //Not popuated in XML
        //bob.CONTENT_MOBILE_HEADLINE = 'mobile headline';
        //bob.CONTENT_MOBILE_BLURB = 'mobile blurb';
        bob.DO_NOT_DISTRIBUTE_ANYWHERE = true; //not saved
        bob.STAFF_USE_ONLY = true; //not saved
        bob.VERSION = 1;
        bob.SLUG_ID = '1234567890';
        bob.ROOT_SLUG_ID = '0987654321';
        bob.PRODUCT_ID = 'Article';
        bob.PRODUCT_ID_NAME = 'Article';
        bob.IIP_THEME_CODE = 'theme';
        bob.PACKAGE_TITLE_WITH_YEARMONTH = '';
        bob.CATEGORY1 = '';
        bob.CATEGORY2 = '';
        bob.CATEGORY3 = '';
        bob.CATEGORY4 = '';
        bob.CATEGORY5 = '';
        bob.CATEGORY6 = '';
        bob.CATEGORY7 = '';
        bob.CATEGORY8 = '';
        bob.CATEGORY9 = '';
        bob.CATEGORY10 = '';
        bob.CATEGORY11 = '';
        bob.CATEGORY12 = '';
        bob.CATEGORY13 = '';
        bob.CATEGORY14 = '';
        bob.CATEGORY15 = '';
        bob.CATEGORY16 = '';
        bob.CATEGORY17 = '';
        bob.CATEGORY18 = '';
        bob.CATEGORY19 = '';
        bob.CATEGORY20 = '';
        //bob.COUNT_OF_CATEGORIES;//not saved
        bob.PUBLICATION_TITLE = '';
        bob.PUBLICATION_TABLE_OF_CONTENTS = false;
        bob.SEARCH_ENGINE_KEYWORDS = 'keywords';
        bob.MORE_COVERAGE_HEADLINE_1 = '';
        bob.MORE_COVERAGE_URL_1 = '';
        bob.MORE_COVERAGE_HEADLINE_2 = '';
        bob.MORE_COVERAGE_URL_2 = '';
        bob.MORE_COVERAGE_HEADLINE_3 = '';
        bob.MORE_COVERAGE_URL_3 = '';
        bob.MORE_COVERAGE_HEADLINE_4 = '';
        bob.MORE_COVERAGE_URL_4 = '';
        bob.MORE_COVERAGE_HEADLINE_5 = '';
        bob.MORE_COVERAGE_URL_5 = '';
        bob.SmallPhotoURL1 = '';
        bob.SmallPhotoCaption1 = '';
        bob.PhotoCredit1 = '';
        bob.PhotoAltText1 = '';
        //bob.EnlargedPhotoURL1; //not saved
        //bob.EnlargedPhotoCaption1; //not saved
        bob.SmallPhotoURL2 = '';
        bob.SmallPhotoCaption2 = '';
        bob.PhotoCredit2 = '';
        bob.PhotoAltText2 = '';
        //bob.EnlargedPhotoURL2; //not saved
        //bob.EnlargedPhotoCaption2; //not saved
        bob.MULTIMEDIA_URL = '';
        bob.THUMBNAIL_URL = '';
        bob.THUMBNAIL_CREDIT = '';
        bob.THUMBNAIL_ALT_TAG = '';
        
        DA_XMLImport.XMLuploader(bob);
    }


    public static testmethod void TestParseCategory()
    {
        DA_XMLImport.parseCategory('AFRICA');
        DA_XMLImport.parseCategory('EAP');
        DA_XMLImport.parseCategory('EUR');
        DA_XMLImport.parseCategory('MENA');
        DA_XMLImport.parseCategory('SCA');
        DA_XMLImport.parseCategory('AMERICAS');
        DA_XMLImport.parseCategory('POTUS');
        DA_XMLImport.parseCategory('SECSTATE');
        DA_XMLImport.parseCategory('TOC');
        DA_XMLImport.parseCategory('APEC');
        DA_XMLImport.parseCategory('IRAN');
        DA_XMLImport.parseCategory('BRAZIL');
        DA_XMLImport.parseCategory('BURMA');
        DA_XMLImport.parseCategory('NORTHKOREA');
        DA_XMLImport.parseCategory('USCHINA');
        DA_XMLImport.parseCategory('AMERICAS');
        DA_XMLImport.parseCategory('CENTAM');
        DA_XMLImport.parseCategory('MEXICO');
        DA_XMLImport.parseCategory('AMERICAS');
        DA_XMLImport.parseCategory('SOTA');
        DA_XMLImport.parseCategory('INVALID');
    }
}
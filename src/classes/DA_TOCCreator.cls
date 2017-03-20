@RestResource (urlMapping='/XMLTOCprocessor/tocprocessor/*')
global with sharing class DA_TOCCreator
{
	public DA_TOCCreator(){}

	@HttpPost
	global static void processTOC()
	{
		List<Digital_Asset__c> assets = new List<Digital_Asset__c>();
		List<Digital_Asset__c> tocs = new List<Digital_Asset__c>();
		List<PD_TOC_Asset__c> assetWithTOCs = [SELECT Headline__c, Publishing_Asset__r.Search_Keywords__c, Publishing_Asset__r.Publication_Title__c, 
		                                              Publishing_Asset__r.Language__c, Publishing_Asset__r.Asset_Subtype__c, Publishing_Asset__r.Slug_ID__c,
		                                              Publishing_Asset__r.ToC_Blurb__c, Publishing_Asset__r.Published_URL__c, Publishing_Asset__r.name,
		                                              Publishing_Asset__r.Headline_Long__c, Publishing_Asset__r.ToC_Subheading__c, Publishing_Asset__r.Id
		                                         FROM PD_TOC_Asset__c];
		
		Map<String, List<Id>> tocMap = new Map<String, List<Id>>{};
		Map<String, Digital_Asset__c> tocAssetMap = new Map<String, Digital_Asset__c>{};
		
		for (PD_TOC_Asset__c assetWithTOC : assetWithTOCs)
		{
		 	string tempBody = '';
			string tempstr = '';
		 	
		 	if (!tocAssetMap.containsKey( assetWithTOC.Headline__c ))
		 	{
			 	Digital_Asset__c toc = new Digital_Asset__c();
			 	
			 	toc.Headline_long__c = assetWithTOC.Headline__c;
			 	
	            if (assetWithTOC.Headline__c.length() > 79)
	            {
	            	TOC.Name = assetWithTOC.Headline__c.substring( 0, 79 );
	            }
	            else
	            {
	            	TOC.Name = assetWithTOC.Headline__c; 
	            }
	            
	            toc.Asset_Comments__c = 'WARNING: This Table of Contents is a placeholder created in 2013 during the mass import of older items into Salesforce. It must be modified before being republished. Examine the Web version to see what is needed. Text may need to be placed in the individual chapters\' relevant "ToC Section Headline" and "ToC Blurb" fields to update this Table of Contents\' "Asset Body" field. Contact the Copy Desk with any questions.';
	            
	            toc.Search_Keywords__c = assetWithTOC.Publishing_Asset__r.Search_Keywords__c;
	            System.debug( assetWithTOC.Publishing_Asset__r.Id + ': ' + toc.Search_Keywords__c );
	            toc.Language__c = assetWithTOC.Publishing_Asset__r.Language__c;
	            toc.Asset_Type__c = 'Table of Contents';
	            toc.Asset_Subtype__c = assetWithTOC.Publishing_Asset__r.Asset_Subtype__c;
				toc.ToC_Hidden__c = assetWithTOC.Publishing_Asset__r.Slug_ID__c;

				if(assetWithTOC.Publishing_Asset__r.ToC_SubHeading__c != null)
				{
					tempbody += '<p><b>' + assetWithTOC.Publishing_Asset__r.ToC_SubHeading__c + '</b></p>';
				}
				if(assetWithTOC.Publishing_Asset__r.ToC_Blurb__c == null)
				{
					tempbody += '<p><a href=\"' + assetWithTOC.Publishing_Asset__r.Published_URL__c + '\">' + assetWithTOC.Publishing_Asset__r.Headline_Long__c + '</a><br></p>';
				}
				else
				{
					tempstr = assetWithTOC.Publishing_Asset__r.ToC_Blurb__c;
					tempstr = tempstr.replaceAll('\\<p.*?\\>', '<p>');
					tempstr = tempstr.replaceFirst('\\<p\\>', '');
					tempbody += '<p><a href=\"' + assetWithTOC.Publishing_Asset__r.Published_URL__c + '\">' + assetWithTOC.Publishing_Asset__r.Headline_Long__c + '</a><br>' + tempstr + '</p>';
				}
				
				toc.Article_Body__c = tempBody;
				
				List<Id> init = new List<Id>();
				
				init.add( assetWithTOC.Publishing_Asset__r.Id );
				
				tocMap.put( assetWithTOC.Headline__c, init );
	            tocAssetMap.put( assetWithTOC.Headline__c, toc );
	            tocs.add( toc );   
		 	}
		 	else
		 	{
		 		String tocHidden = tocAssetMap.get( assetWithTOC.Headline__c ).ToC_Hidden__c + '##' + assetWithTOC.Publishing_Asset__r.Slug_ID__c;
		 		
		 		tempbody = tocAssetMap.get( assetWithTOC.Headline__c ).Article_Body__c;
		 		
		 		if(assetWithTOC.Publishing_Asset__r.ToC_SubHeading__c != null)
				{
					tempbody += '<p><b>' + assetWithTOC.Publishing_Asset__r.ToC_SubHeading__c + '</b></p>';
				}
				if(assetWithTOC.Publishing_Asset__r.ToC_Blurb__c == null)
				{
					tempbody += '<p><a href=\"' + assetWithTOC.Publishing_Asset__r.Published_URL__c + '\">' + assetWithTOC.Publishing_Asset__r.Headline_Long__c + '</a><br></p>';
				}
				else
				{
					tempstr = assetWithTOC.Publishing_Asset__r.ToC_Blurb__c;
					tempstr = tempstr.replaceAll('\\<p.*?\\>', '<p>');
					tempstr = tempstr.replaceFirst('\\<p\\>', '');
					tempbody += '<p><a href=\"' + assetWithTOC.Publishing_Asset__r.Published_URL__c + '\">' + assetWithTOC.Publishing_Asset__r.Headline_Long__c + '</a><br>' + tempstr + '</p>';
				}

		 		tocAssetMap.get( assetWithTOC.Headline__c ).ToC_Hidden__c = tocHidden;
		 		tocAssetMap.get( assetWithTOC.Headline__c ).Article_Body__c = tempbody;
		 		tocMap.get( assetWithTOC.Headline__c ).add( assetWithTOC.Publishing_Asset__r.Id );
		 	}
		 }

		 insert( tocs );
		 delete assetWithTOCs;
		 for (Digital_Asset__c toc : tocs)
		 {	 	
		 	if (tocMap.containsKey( toc.Headline_long__c ))
		 	{
		 		for (Id assetId : tocMap.get( toc.Headline_long__c ))
		 		{
		 			Digital_Asset__c asset = new Digital_Asset__c( Id=AssetId );
		 			asset.Publication_Title__c = toc.id;
		 			
		 			assets.add( asset );
		 		}
		 	}
		 }
		 
		 update( assets );

		RestResponse res = RestContext.response;
		
		if (res != null)
		{
		    res.statusCode = 201;
	        String jsonResponse = '{"response": "success","processedBY":"'+ UserInfo.getUserId() +'"}';
	        res.responseBody = blob.valueOf(jsonResponse);
		}
	}
	
	
	public static testMethod void testDA_TOCCreator()
    {
    	Test.startTest();
    	
    	Digital_Asset__c asset1 = new Digital_Asset__c();
    	asset1.Name = 'test';
        asset1.Language__c = 'English';
    	asset1.ToC_SubHeading__c = 'test';
    	asset1.Search_Keywords__c = 'test';
    	insert asset1;
    	
    	Digital_Asset__c asset2 = new Digital_Asset__c();
    	asset2.Name = 'test';
        asset2.Language__c = 'English';
    	asset2.ToC_SubHeading__c = 'test';
    	asset2.Search_Keywords__c = 'test';
    	asset2.ToC_Blurb__c = 'test';
    	insert asset2;
    	
    	    	
    	PD_TOC_Asset__c toc1 = new PD_TOC_Asset__c();
    	toc1.Headline__c = 'test';
    	toc1.Publishing_Asset__c = asset1.id;
    	insert toc1;
    	
    	PD_TOC_Asset__c toc2 = new PD_TOC_Asset__c();
    	toc2.Headline__c = 'testtesttstesttesttstesttesttstesttesttstesttesttstesttesttstesttesttstesttesttstesttesttstesttesttstesttesttstesttesttstesttesttstesttesttstesttesttstesttestts';
    	toc2.Publishing_Asset__c = asset2.id;
    	insert toc2;
    	
    	DA_TOCCreator.processTOC();
    }
}
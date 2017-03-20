global class COMP_NotifyEmails2 implements Schedulable
{
    global void execute( SchedulableContext sc )
    {
        send_Compilation_Emails();
    }
	
	global static List<Digital_Asset__c> getCompilationAssets()
	{
		DateTime currentDate = DateTime.now();
        DateTime yesterdayDate = currentDate.addDays( -1 );
        DateTime tomorrowDate = currentDate.addDays( 1 );
    	String currentDateFormat = currentDate.format( 'MMM dd' );
    
        Digital_Asset__c[] results = [SELECT Headline_long__c, Article_Body__c, Language__c, Published_URL__c, Multimedia_URL__c, 
                                             Total_Word_Count__c, Author__c, Author_Job_Title__c, Asset_Type__c, Asset_SubType__c,
                                             IIP_Internal_Use_Only__c, Include_Byline__c, Top__c, Post_Date__c
                                    	FROM Digital_Asset__c
                                   		WHERE Post_Date__c > :yesterdayDate AND Post_Date__c < :tomorrowDate
                                    	AND Include_In_Compilation__c = true
                                     	AND Status__c = 'Published'];
        return results;
	}

    global static void send_Compilation_Emails()
    {
        String[] compLangList = new String[]{ 'AR', 'CH', 'EN', 'FR', 'FA', 'PT', 'RU', 'ES', 'TR', 'UR' };
        string[] languages = new string[] { 'Arabic', 'Chinese', 'English', 'French', 'Persian', 'Portuguese', 'Russian', 'Spanish', 'Turkish', 'Urdu' };
        String[] asset_Order = new string[] {'Article', 'In Brief', 'Audio', 'Video', 'Photo Gallery', 'Pamphlet', 'Table of Contents', 'Publication', 'Text or Transcript', 'Note to Posts'};
        
        String emailTop = '';
        String emailBot = '';
        String internalEmailTop = '';
        String internalEmailBot = '';
        Boolean found = false;
        Boolean foundInternal = false;
        
    Document compilationAttachment = [SELECT name, Body FROM Document WHERE Keywords = 'Compilation Attachment' AND Description = 'Compilation Attachment'];
    
        DateTime currentDate = DateTime.now();
        DateTime yesterdayDate = currentDate.addDays( -1 );
        DateTime tomorrowDate = currentDate.addDays( 1 );
    String currentDateFormat = currentDate.format( 'MMM dd' );
    /*
        Digital_Asset__c[] results = [SELECT Headline_long__c, Article_Body__c, Language__c, Published_URL__c, Multimedia_URL__c, 
                                             Total_Word_Count__c, Author__c, Author_Job_Title__c, Asset_Type__c, Asset_SubType__c,
                                             IIP_Internal_Use_Only__c, Include_Byline__c, Top__c, Post_Date__c
                                        FROM Digital_Asset__c
                                       	WHERE Post_Date__c > :yesterdayDate AND Post_Date__c < :tomorrowDate //revised on 10/1/13 per CR
                                       	//WHERE Asset_Date_Time__c > :yesterdayDate And Asset_Date_Time__c < :tomorrowDate //commented out on 10/1/13 per CR
                                       //WHERE Date_of_First_Publish__c > :yesterdayDate And Date_of_First_Publish__c < :tomorrowDate
                                         AND Include_In_Compilation__c = true
                                         AND Status__c = 'Published'];
        //                               WHERE createdById = :UserInfo.getUserId()];
      */
		
		Digital_Asset__c[] results = getCompilationAssets();
		
        for (Integer lIndex = 0; lIndex < languages.size(); lIndex++)
        {
            emailTop = languages[ lIndex ] + ' IIP Digital Compilation System\n' + currentDate.format('dd MMM yyyy') + '\n\n';
            emailBot = '';
            
            for (String assetType : Asset_Order)
            {
                if (assetType == 'Publication')
                {
                    foundInternal = true;
                    found = true;
                }
                else
                {
                    foundInternal = false;
                    found = false;
                }
                
                for (Digital_Asset__c X : results)
                {
                    if (( X.Language__c == Languages [lIndex ]) && (assetType == X.Asset_Type__c))
                    {
                        String body = GLOBAL_Library.jitScrub(X.Article_Body__c);
                        String top = GLOBAL_Library.jitScrub(X.Top__c);
                        String urlString = X.Multimedia_URL__c;
                        
                        if (urlString == '' || urlString == null)
                        {
                            urlString = '';
                        }
                        else
                        {
                            urlString = '(' + URLString  + ') ';
                        }
                        
                        //RT Ticket #103226 Fix - replacing <br />, <br>, <br >, or <br/> to new line
                        if (body != null)
                        {
                            body = body.replaceAll( '\n', '' );
                            body = body.replaceAll( '\r', '' );
                            
                            body = body.replaceAll( '<p />', '\n' );
                            body = body.replaceAll( '<p/>', '\n' );
                            body = body.replaceAll( '<p>',   '\n' );
                            body = body.replaceAll( '<p >',   '\n' );
                            body = body.replaceAll( '</p>', '\n' );
                            body = body.replaceAll( '</ p>', '\n' );
                            body = body.replaceAll( '<p />',   '\n' );
                           
                            
                            body = body.replaceAll( '<p/>',   '\n' );
                            body = body.replaceAll( '<br />', '\n' );
                            body = body.replaceAll( '<br>',   '\n' );
                            body = body.replaceAll( '<br >',  '\n' );
                            body = body.replaceAll( '<br/>',  '\n' );
                            
                            body = body.replaceAll( '&quot;', '\'' );
                            body = body.replaceAll( '\\<.*?\\>', '' );
                            body = body.replaceAll( '&rsquo;', '\'' );
                            body = body.replaceAll( '&ldquo;', '\'' );
                            body = body.replaceAll( '&rdquo;', '\'' );
                            body = body.replaceAll( '&lt;', '<' );
                            body = body.replaceAll( '&gt;', '>' );
                            body = body.replaceAll( '&rdquo;', '\'' );
                            body = body.replaceAll( '&#39;', '\'' );
                        }
                        else
                        {
                            body = '';
                        }
                        
                        
                        if (top != null && top.length()>0)
                        {
                          //RT Ticket #103226 Fix - replacing <br />, <br>, <br >, or <br/> to new line
                          top = top.replaceAll( '\n', '' );
                            top = top.replaceAll( '\r', '' );
                          top = top.replaceAll( '<p />', '\n' );
	                      top = top.replaceAll( '<p/>', '\n' );
	                      top = top.replaceAll( '<p>',   '\n' );
	                      top = top.replaceAll( '<p >',   '\n' );
	                      top = top.replaceAll( '</p>', '\n' );
                            top = top.replaceAll( '</ p>', '\n' );
                            top = top.replaceAll( '<p />',   '\n' );
                            top = top.replaceAll( '<p/>',   '\n' );
                          top = top.replaceAll( '<br />', '\n' );
                          top = top.replaceAll( '<br>',   '\n' );
                          top = top.replaceAll( '<br >',  '\n' );
                          top = top.replaceAll( '<br/>',  '\n' );
                        
                            top = top.replaceAll( '&quot;', '\'' );
                            top = top.replaceall( '\\<.*?\\>', '' );
                            top = top.replaceAll( '&rsquo;', '\'' );
                            top = top.replaceAll( '&ldquo;', '\'' );
                            top = top.replaceAll( '&lt;', '<' );
                          top = top.replaceAll( '&gt;', '>' );
                            top = top.replaceAll( '&rdquo;', '\'' );
                            top = top.replaceAll( '&#39;', '\'' );
                            top = top + '\n';
                        }
                        else
                        {
                            top = '';
                        }
                        
                        if (urlString == 'null')
                        {
                            urlString = '';
                        }

                        if (X.IIP_Internal_Use_Only__c) {/* Asset not to be distributed */}
                        else if ((X.Asset_Type__c == 'Note to Posts' || X.Asset_Subtype__c == 'Internal Use Only' || X.Asset_Subtype__c == 'Discretionary Diplomatic Distribution') && X.Language__c == 'English')
                        {
                            if (foundInternal == false)
                            {
                                if (X.Asset_Type__c == 'Table of Contents')
                                {
                                    internalEmailTop += 'Publication\n\n';//some kind of heading
                                }
                                else
                                {
                                    internalEmailTop += X.Asset_Type__c + '\n\n';//some kind of heading
                                }
                                foundInternal = true;
                            }
                            
                            //asset is for internal use only
                            internalEmailTop += X.Headline_long__c + '\n' + URLString + '(' + X.Total_Word_Count__c + ')\n' + X.Published_URL__c + '\n\n';
                     
                            if(X.Include_Byline__c == true && (assetType == 'Article' || assetType == 'Publication'))
                            {
                                internalEmailBot += '--------------------------------------------------------------------------------\n' + 
                                                    X.Headline_long__c + '\n' + URLString + '(' + X.Total_Word_Count__c + ')\n\n' +
                                                    X.Author__c + '\n' + X.Author_Job_Title__c + '\n' +
                                                    top + body + '\n';
                            }
                            else
                            {
                                if (assetType == 'Article' || assetType == 'Publication' || assetType == 'Table of Contents')
                                {
                                    internalEmailBot += '--------------------------------------------------------------------------------\n' + 
                                                        X.Headline_long__c + '\n' + URLString + '(' + X.Total_Word_Count__c + ')\n' +
                                                        top + body + '\n';
                                }
                                else
                                {
                                    internalEmailBot += '--------------------------------------------------------------------------------\n' + 
                                                        X.Headline_long__c + '\n' + URLString + '(' + X.Total_Word_Count__c + ')\n' +
                                                        body + '\n';
                                }
                            }
                        }
                        else
                        {
                            //asset is for normal distribution
                            if(found == false)
                            {
                                if (X.Asset_Type__c == 'Table of Contents')
                                {
                                    emailTop += 'Publication\n\n';//some kind of heading
                                }
                                else
                                {
                                    emailTop += X.Asset_Type__c + '\n\n';//some kind of heading
                                }
                                found = true;
                            }
                            
                            emailTop += X.Headline_long__c + '\n' + URLString + '(' + X.Total_Word_Count__c + ')\n' + X.Published_URL__c + '\n\n';

                            if(X.Include_Byline__c == true && (assettype == 'Article' || assettype == 'Publication'))
                            {
                                emailBot += '--------------------------------------------------------------------------------\n' + 
                                            X.Headline_long__c + '\n' + URLString + '(' + X.Total_Word_Count__c + ')\n\n' +
                                            X.Author__c + '\n' + X.Author_Job_Title__c + '\n' +
                                            top + body + '\n';
                            }
                            else
                            {
                                if (assettype == 'In Brief')
                                {
                                    emailBot += '--------------------------------------------------------------------------------\n' + 
                                                X.Headline_long__c + '\n' + URLString + '(' + X.Total_Word_Count__c + ')\n' +
                                                body + '\n';
                                }
                                else
                                {
                                    emailBot += '--------------------------------------------------------------------------------\n' + 
                                                X.Headline_long__c + '\n' + URLString + '(' + X.Total_Word_Count__c + ')\n' +
                                                top + body + '\n';
                                }
                            }
                        }
                    }
                }
            }
         
            if(Languages[lIndex] == 'English')
            {
                if (internalEmailBot.length() > 0)
                {
                  //all of the assets of the current langauge have been added to the fields
                  internalEmailTop += internalEmailBot;
                  
                  Case c = new Case();
                
                  c.SuppliedName = 'IIPDIGITAL-INTERNAL: INTERNAL ONLY Collection for ' + currentDateFormat;
                  c.Subject = 'SYS:Compilation System';
                  c.Email_Body__c = '';
                  c.Email_Body__c += 'IIP Digital - Engaging the World\nhttp://iipdigital.usembassy.gov\n\nIIP Digital Compilation System mailing list.\n';
                  c.Email_Body__c += 'Caution: Please remove the internal use only material before redistributing to your audiences.\n\n';
                  c.Email_Body__c += 'Here is the INTERNAL USE ONLY collection for ' + currentDate.format( 'MMM dd' );
                
                  compilationAttachment.Body = Blob.valueOf( internalEmailTop.replaceAll( '\n', '\r\n') );
                  compilationAttachment.Name = 'INTERNAL_' + currentDateFormat;
                  update compilationAttachment;
                  
                  AssignmentRule ar = new AssignmentRule(); 
                  
                  //Assignment Rule Query
                  ar = [select id from AssignmentRule where SobjectType = 'Case' and Name = 'Salesforce Email Handler' and Active = true limit 1];
                  
                  //Creating DML Options
                  Database.DMLOptions dmlOpts = new Database.DMLOptions();
                  if (ar != null)
                  {
                     dmlOpts.assignmentRuleHeader.assignmentRuleID = AR.ID;
                     dmlOpts.EmailHeader.TriggerUserEmail = true;
                     c.setOptions(dmlOpts);
                     insert c;
                  }
                  
                  delete c;
                  Database.emptyRecycleBin( c );
                }
            }

            
             if (emailBot.length() > 0)
             {
               emailTop += emailBot;

              Case c = new Case();
                  
              c.SuppliedName = 'IIPDIGITAL-' + compLangList[lIndex] + ':' + Languages[lIndex] + ' collection for ' + currentDateFormat;
                c.Subject = 'SYS:Compilation System';
                c.Email_Body__c = '';
                
                if(Languages[lIndex] == 'English')
                {
                    c.Email_Body__c += 'IIP Digital - Engaging the World\nhttp://iipdigital.usembassy.gov\n\nIIP Digital Compilation System mailing list.\n';
                }
                else
                {
                    c.Email_Body__c += 'IIP Digital - Engaging the World\nhttp://iipdigital.usembassy.gov/'+ Languages[lIndex].toLowerCase() + '/\n\nIIP Digital Compilation System mailing list.\n';
                }
                
                c.Email_Body__c += 'Caution: Please remove the internal use only material before redistributing to your audiences.\n\n';
                c.Email_Body__c += 'Here is the ' + Languages[lIndex] + ' collection for ' + currentDate.format( 'MMM dd' );

              compilationAttachment.Body = Blob.valueOf( emailTop.replaceAll( '\n', '\r\n') );
              compilationAttachment.Name = Languages[lIndex] + '_' + currentDateFormat;
              update compilationAttachment;
              
              AssignmentRule ar = new AssignmentRule(); 
              
              //Assignment Rule Query
              ar = [select id from AssignmentRule where SobjectType = 'Case' and Name = 'Salesforce Email Handler' and Active = true limit 1];
              
              //Creating DML Options
              Database.DMLOptions dmlOpts = new Database.DMLOptions();
              if (ar != null)
              {
                 dmlOpts.assignmentRuleHeader.assignmentRuleID = AR.ID;
                 dmlOpts.EmailHeader.TriggerUserEmail = true;
                 c.setOptions(dmlOpts);
                 insert c;
              }
              
              delete c;
        Database.emptyRecycleBin( c );
             }
        }
        
        compilationAttachment.Body = Blob.valueOf( '' );
      compilationAttachment.Name = 'Compilation Attachment';
      update compilationAttachment;
    }


	
}
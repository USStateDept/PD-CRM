public class AmericanSpacesContacts
{
    public AmericanSpacesAttachment[] attachments;
    
    public Integer attachmentNumber{ get; set; }
    public Id postId{ get; set; }
    public String postName{ get; set; }
    
    private American_Spaces_Contact__c americanSpacesContact;
    private ApexPages.StandardController std;
    
    private List<Id> tempIDs = new List<Id>();
    private boolean isModifiable = false;
    private boolean isDirty = false;
    
    public AmericanSpacesContacts( ApexPages.StandardController stdCtrl )
    {
        std = stdCtrl;
        
        if (std != null)
        {
            americanSpacesContact = (American_Spaces_Contact__c) std.getRecord();
        }
        else
        {
        	americanSpacesContact = new American_Spaces_Contact__c();
        }
                    
        String postID = ApexPages.currentPage().getParameters().get( 'postID' );
            
        if (postID != null && postID.length() > 0)
        {
           	americanSpacesContact.Managing_Post_City__c = postID;
        }
        else
        {
        	Id qryPostId = [SELECT Managing_Post_City__r.id FROM American_Spaces_Contact__c WHERE id = :americanSpacesContact.id].Managing_Post_City__r.id;
        	americanSpacesContact.Managing_Post_City__c = qryPostId;
        }
            
        American_Spaces_Post_Contacts__c aspc = [SELECT id, Name FROM American_Spaces_Post_Contacts__c WHERE id = :americanSpacesContact.Managing_Post_City__c];

        this.postId = aspc.id;
        this.postName = aspc.Name;
    }
    
    
    public List<American_Spaces_Statistic__c> getStatistics()
    {
    	return [SELECT name, Month__c, Year__c, Number_of_Visitors__c, 	Number_of_Programs__c, Number_of_Program_Attendees__c 
    	          FROM American_Spaces_Statistic__c
    	         WHERE Name_of_Space__c = :americanSpacesContact.Id
    	      ORDER BY filter__c DESC];
    }
    
    
    public List<American_Space_Branch__c> getBranches()
    {
    	return [SELECT name, Type_of_Space__c, City__c, Status__c, Open_to_public__c
    	          FROM American_Space_Branch__c
    	         WHERE Name_of_Space__c = :americanSpacesContact.Id];
    }
    
    
    public PageReference addStatistics()
	{
		return new PageReference( '/apex/AmericanSpace_Statistics_Edit?spaceID=' + americanSpacesContact.Id );
	}
	
	
	public PageReference addBranch()
	{
		return new PageReference( '/apex/AmericanSpace_Branch_Edit?spaceID=' + americanSpacesContact.Id );
	}
    
    
    public American_Spaces_Contact__c getAmericanSpacesContact()
    {
        return americanSpacesContact;
    }
    public void setAmericanSpacesContact( American_Spaces_Contact__c americanSpacesContact )
    {
        this.americanSpacesContact = americanSpacesContact;
    }


    public List<AmericanSpacesAttachment> getAttachments()
    {
        if (( null != getAmericanSpacesContact().id ) && ( attachments == null ))
        {
            attachments = new List<AmericanSpacesAttachment>();

        	for (American_Spaces_Notes_and_Attachments__c data : 
        	                      [SELECT Type_of_Document__c, Description__c, Document_ID__c, Comments__c, Date__c, extension__c, name
        	                         FROM American_Spaces_Notes_and_Attachments__c
        	                        WHERE Object_ID__c = :getAmericanSpacesContact().id	
        	 					 ORDER BY CreatedDate ])
            {
            	Attachment newDocument = new Attachment( id=data.Document_ID__c );
                AmericanSpacesAttachment createdAttachment = new AmericanSpacesAttachment( newDocument, null, data );

                attachments.add( createdAttachment );
            }
        }
        
        return attachments;
    }
    
    
   private boolean updateAmericanSpaceContact( boolean saveFlag )
   {
        boolean bSaved = true;
        boolean changed = false;
        
        if (null != attachments)
        {
            try
            {
                List<Attachment> upsertAttachments = new List<Attachment>();
                List<American_Spaces_Notes_and_Attachments__c> upsertInfos = new List<American_Spaces_Notes_and_Attachments__c>();
                
                for (AmericanSpacesAttachment attachmentObj : attachments)
                {
                    if (getAmericanSpacesContact() != null && getAmericanSpacesContact().id != null)
                    {
                    	if (attachmentObj.getAttachment().Id == null)
                    	{
                        	attachmentObj.getAttachment().ParentId = getAmericanSpacesContact().id;
                    	}
                        attachmentObj.getInformation().Object_ID__c = getAmericanSpacesContact().id;
                    }                    
                    if ( attachmentObj.getAttachmentDetail() != null )
                    {
                        attachmentObj.getAttachment().Body = attachmentObj.getAttachmentDetail();
                    }             
                    
                    // Getting file extension...          
                    if (attachmentObj.getAttachment().name != null && attachmentObj.getAttachment().name.length() > 0 && attachmentObj.getAttachment().ContentType == null)
                    {
                        Integer mid= attachmentObj.getAttachment().name.lastIndexOf( '.' );
                        String fname = attachmentObj.getAttachment().name.substring( 0, mid );

                        String ext = attachmentObj.getAttachment().name.substring( mid+1, attachmentObj.getAttachment().name.length() );
    
                        attachmentObj.getAttachment().name = fname;
                        attachmentObj.getAttachment().ContentType = GLOBAL_Library.getContentType( ext );
                        
                        attachmentObj.getInformation().name = fname;
                        attachmentObj.getInformation().extension__c = ext;
                        
                        if (americanSpacesContact.Type_of_Space__c != null &&
                        	!americanSpacesContact.Type_of_Space__c.equalsIgnoreCase( 'Information Resource Center' ) && 
                            !americanSpacesContact.Type_of_Space__c.equalsIgnoreCase( 'American Center' ) && 
                            (ext.equalsIgnoreCase( 'jpg' ) ||  ext.equalsIgnoreCase( 'png' ) || ext.equalsIgnoreCase( 'gif' )))
                        {
                        	 ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, 'Partner spaces cannot upload photos at this time. We hope to introduce this functionality later in 2014.' ));
                        	 bSaved = false;
                        	 break;
                        }
                    }
                    
                    // Ikjae: In order to work around the view state limit, the photo object needs to be saved temp
                    if (attachmentObj.getAttachment().Id == null && attachmentObj.getAttachmentDetail()  != null)
                    {
                    	Database.SaveResult sr = Database.Insert( attachmentObj.getAttachment() );
                    	attachmentObj.setAttachmentDetail( null );
                    	
                    	attachmentObj.getInformation().Document_ID__c = attachmentObj.getAttachment().Id;
                    	Database.Upsert( attachmentObj.getInformation() );
                    	
                    	tempIDs.add( attachmentObj.getInformation().Id );
                    }
                    
                    if (saveFlag)
                    {
                    	if (attachmentObj.getAttachment().name != null)
                    	{
                    		upsertAttachments.add( attachmentObj.getAttachment() );
                    	}
                    	
                    	upsertInfos.add( attachmentObj.getInformation() );
                    }
                }                   
                
                if (saveFlag)
                {
                    upsert upsertAttachments;
                    upsert upsertInfos;
                }
            }
            catch (Exception e)
            {
                String msg = e.getMessage();
                ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, msg ));
                bSaved = false;
            }
        }
        
        attachments = null;
        
        return bSaved;
   }
   
   
   public List<AmericanSpacesAttachment> getCurrentattachments()
   {
	   attachments = new List<AmericanSpacesAttachment>();
        
        for (American_Spaces_Notes_and_Attachments__c data : 
        	                      [SELECT Type_of_Document__c, Description__c, Document_ID__c, Comments__c, Date__c, extension__c, name
        	                         FROM American_Spaces_Notes_and_Attachments__c
        	                        WHERE Id in :tempIDs
        	 					 ORDER BY CreatedDate ])
       {
           Attachment newDocument = new Attachment( id=data.Document_ID__c );
            	
           AmericanSpacesAttachment createdPhoto = new AmericanSpacesAttachment( newDocument, null, data );

           attachments.add( createdPhoto );
       }

       return attachments;
   }
   
    public PageReference save()
    {
        PageReference returningPage = null;
        
        if (std != null)
        {
        	try
        	{
        		Id id = [SELECT Id FROM American_Spaces_Post_Contacts__c WHERE id = :postId AND name = :postName LIMIT 1].id;
        	}
        	catch( Exception e )
        	{
        		ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, 'Managing Post City: No Matches found.' ));
        		return null;
        	}
        	
        	americanSpacesContact.Managing_Post_City__c = postId;
        	
        	std.save();
        	americanSpacesContact = (American_Spaces_Contact__c) std.getRecord();   
        }
    	
        String country = ApexPages.currentPage().getParameters().get( 'country' );
      	String postID = ApexPages.currentPage().getParameters().get( 'postID' );
      	
      	
      	if (updateAmericanSpaceContact( true ))
        {
	      	if (country != null && country.length() > 0)
			{
				returningPage = new PageReference( '/apex/AmericanSpace_AmSpacePostContactView?postID=' + postID + '&country=' + country );
			}
			else if (postID != null && postID.length() > 0)
			{
				returningPage = new PageReference( '/apex/AmericanSpace_AmSpacePostContactView?postID=' + postID );
			}
			else
			{
				returningPage = new PageReference( '/' + getAmericanSpacesContact().id );
			}
        }
		
		return returningPage;
    }
    
    public PageReference deleteTheRecord()
    {
    	Id id = [SELECT Managing_Post_City__r.id FROM American_Spaces_Contact__c WHERE id = :getAmericanSpacesContact().id].Managing_Post_City__r.id;
    	PageReference returningPage = new PageReference( '/' + id );
    	
    	delete getAmericanSpacesContact();
    	
        return returningPage;
	}
	
	
    public PageReference cancel()
    {
    	List<Attachment> docs = new List<Attachment>();
    	
    	for (American_Spaces_Notes_and_Attachments__c attachment : [ select Document_ID__c FROM American_Spaces_Notes_and_Attachments__c WHERE Id in :tempIDs ])
    	{
    		docs.add( new Attachment( id=attachment.Document_ID__c ));
    	}
    	    	
    	Database.delete( docs );
    	
    	if (isDirty)
    	{
    		delete getAmericanSpacesContact();
    	}

    	List<American_Spaces_Notes_and_Attachments__c> tempDocs = [ select id FROM American_Spaces_Notes_and_Attachments__c WHERE Id in :tempIDs  ];
    	
    	delete tempDocs;
    	
    	PageReference returningPage;
    	
        String country = ApexPages.currentPage().getParameters().get( 'country' );
      	String postID = ApexPages.currentPage().getParameters().get( 'postID' );
      	
      	if (country != null && country.length() > 0)
		{
			returningPage = new PageReference( '/apex/AmericanSpace_AmSpacePostContactView?postID=' + postID + '&country=' + country );
		}
		else if (postID != null && postID.length() > 0)
		{
			returningPage = new PageReference( '/apex/AmericanSpace_AmSpacePostContactView?postID=' + postID );
		}
		else
		{
			returningPage = new PageReference( '/' + getAmericanSpacesContact().id );
		}
		
		return returningPage;
    }
    
    
    public void newAttachment()
    {
        updateAmericanSpaceContact( false );
        
        Attachment doc;
        American_Spaces_Notes_and_Attachments__c information;
        
        if (null == getAmericanSpacesContact().id)
        {
        	std.save();
        	americanSpacesContact = (American_Spaces_Contact__c) std.getRecord();  
        	isDirty = true;
        	
        	attachments = getCurrentattachments();
        	doc = new Attachment( ParentId=getAmericanSpacesContact().id );
        	information = new American_Spaces_Notes_and_Attachments__c();
        }
        else
        {
        	attachments = getattachments();
        	doc = new Attachment( ParentId=getAmericanSpacesContact().id  );
        	information = new American_Spaces_Notes_and_Attachments__c( name='', Object_ID__c=getAmericanSpacesContact().id  );
        }
        
        AmericanSpacesAttachment newPhoto = new AmericanSpacesAttachment( doc, null, information );        
        attachments.add( newPhoto );
    }
    
    
    public void deleteAttachment()
    {

        if (null != attachmentNumber)
        {
            AmericanSpacesAttachment attachmentObj = attachments.get( attachmentNumber - 1 );
            
            if ( attachmentObj.getInformation().id != null )
            {
            	attachments.remove( attachmentNumber - 1 );
            	attachmentObj.deleteObj();
            }
            else
            {
                attachments.remove( attachmentNumber - 1 );
            }

            attachmentNumber = null;
        }
    }
    
    
    public boolean getIsModifiable()
    {
    	try
        {
        	isModifiable = AmericanSpacesAccess.hasAccess( postId, americanSpacesContact.Country__c );
        }
        catch (Exception e)
        {
        	// This method is running on the photo page...
        }
    	
    	return isModifiable;
    }
    
    public boolean getIsDeletable()
    {
    	return AmericanSpacesAccess.hasDeleteAccess();
    }
    
    
    public static testMethod void testAmericanSpacesContacts()
    {             
        Test.startTest();
        
        
        American_Spaces_Post_Contacts__c aspc = new American_Spaces_Post_Contacts__c( Name='test' );
        insert aspc;
        
        ApexPages.currentPage().getParameters().put( 'postID', aspc.id );
        
        AmericanSpacesContacts amsc = new AmericanSpacesContacts( null );
        
        
        American_Spaces_Contact__c ascc = new American_Spaces_Contact__c( Name='test', Managing_Post_City__c=aspc.id );
        insert ascc;
        
        amsc.setAmericanSpacesContact( ascc );
        System.assertEquals( amsc.getAmericanSpacesContact().Id, ascc.Id );
        
        Attachment doc = new Attachment( name='testImg.png', parentID=ascc.Id, body=Blob.valueOf('Test Blob String'));
        insert doc;
        
        American_Spaces_Notes_and_Attachments__c asna = new American_Spaces_Notes_and_Attachments__c( Name='test', Document_ID__c=doc.id, object_ID__c=ascc.id );
        insert asna;
        
        amsc.cancel();
        
        blob img = EncodingUtil.base64Decode( '123123123123' );
        
        AmericanSpacesAttachment ascp = new AmericanSpacesAttachment( doc, img, asna );
        ascp.setAttachment( doc );
        ascp.setAttachmentDetail( img );
		ascp.setInformation( asna );

        amsc.attachments = amsc.getAttachments();
        System.assertEquals( amsc.attachments.size(), 1 );
        amsc.attachments.add( ascp );
        amsc.newAttachment();
        
        amsc.attachmentNumber = 2;
        amsc.deleteAttachment();
        
        amsc.updateAmericanSpaceContact( true );
        System.assertEquals( amsc.save().getUrl(), '/apex/AmericanSpace_AmSpacePostContactView?postID=' + aspc.id );
        
        //System.assertEquals( amsc.getIsModifiable(), true );
        amsc.getCurrentattachments();
        amsc.deleteTheRecord();
        amsc.getIsDeletable();
    }
}
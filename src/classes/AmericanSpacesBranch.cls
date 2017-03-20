public class AmericanSpacesBranch
{
    public AmericanSpacesAttachment[] attachments;
    
    public Integer attachmentNumber{ get; set; }
    public Id spaceId{ get; set; }
    public String spaceName{ get; set; }
    
    private American_Space_Branch__c americanSpacesBranch;
    private ApexPages.StandardController std;
    
    private List<Id> tempIDs = new List<Id>();
    private boolean isModifiable = false;
    private boolean isDirty = false;
    
    public AmericanSpacesBranch( ApexPages.StandardController stdCtrl )
    {
        std = stdCtrl;
        americanSpacesBranch = (American_Space_Branch__c) std.getRecord();

    	String id;
        	
    	if (americanSpacesBranch != null && americanSpacesBranch.id != null)
    	{
    		American_Space_Branch__c assc = [SELECT Name_of_Space__c FROM American_Space_Branch__c WHERE id = :americanSpacesBranch.id];
    		id = assc.Name_of_Space__c;
    		
    	}
    	else
       	{
       		id = ApexPages.currentPage().getParameters().get( 'spaceID' );
       	}
       		
   		American_Spaces_Contact__c aspc = [SELECT id, Name, Managing_Post_City__c, country__c FROM American_Spaces_Contact__c WHERE id = :id];
   		isModifiable = AmericanSpacesAccess.hasAccess( aspc.Managing_Post_City__c, aspc.Country__c );
		System.debug('@@@isModifiable...'+isModifiable);
        spaceId = aspc.Id;
        spaceName = aspc.name;
    }
    
    
	public PageReference deleteTheRecord()
    {
    	Id id = [SELECT Name_of_Space__r.id FROM American_Space_Branch__c WHERE id = :getAmericanSpacesBranch().id].Name_of_Space__r.id;
    	PageReference returningPage = new PageReference( '/' + id );
    	
    	delete americanSpacesBranch;
    	
        return returningPage;
	}
    
    
    public American_Space_Branch__c getAmericanSpacesBranch()
    {
        return americanSpacesBranch;
    }
    public void setAmericanSpacesBranch( American_Space_Branch__c americanSpacesBranch )
    {
        this.americanSpacesBranch = americanSpacesBranch;
    }


    public List<AmericanSpacesAttachment> getAttachments()
    {
        if (( null != getAmericanSpacesBranch().id ) && ( attachments == null ))        
        {
            attachments = new List<AmericanSpacesAttachment>();

            for (American_Spaces_Notes_and_Attachments__c data : 
        	                      [SELECT Type_of_Document__c, Description__c, Document_ID__c, Comments__c, Date__c, extension__c, name
        	                         FROM American_Spaces_Notes_and_Attachments__c
        	                        WHERE Object_ID__c = :getAmericanSpacesBranch().id
        	 					 ORDER BY CreatedDate ])
            {
            	Attachment newDocument = new Attachment( id=data.Document_ID__c );
                AmericanSpacesAttachment createdAttachment = new AmericanSpacesAttachment( newDocument, null, data );

                attachments.add( createdAttachment );
            }
        }
        
        return attachments;
    }
    
    
   public boolean updateAmericanSpaceContact( boolean saveFlag )
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
                    if (getAmericanSpacesBranch() != null && getAmericanSpacesBranch().id != null)
                    {
                    	if (attachmentObj.getAttachment().Id == null)
                    	{
                        	attachmentObj.getAttachment().ParentId = getAmericanSpacesBranch().id;
                    	}
                        attachmentObj.getInformation().Object_ID__c = getAmericanSpacesBranch().id;
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
                        
                        if (americanSpacesBranch.Type_of_Space__c != null &&
                        	!americanSpacesBranch.Type_of_Space__c.equalsIgnoreCase( 'Information Resource Center' ) && 
                            !americanSpacesBranch.Type_of_Space__c.equalsIgnoreCase( 'American Center' ) && 
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
        		Id id = [SELECT Id FROM American_Spaces_Contact__c WHERE id = :spaceId AND name = :spaceName LIMIT 1].id;
        	}
        	catch( Exception e )
        	{
        		ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, 'American Spaces: No Matches found.' ));
        		return null;
        	}
        	
        	americanSpacesBranch.Name_of_Space__c = spaceId;
        	
        	std.save();
        	americanSpacesBranch = (American_Space_Branch__c) std.getRecord();
        }
        
        if (updateAmericanSpaceContact( true ))
        {
        	Id id = [SELECT Name_of_Space__r.id FROM American_Space_Branch__c WHERE id = :getAmericanSpacesBranch().id].Name_of_Space__r.id;
        
        	returningPage = new PageReference( '/' + id );
        }
        
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
    		delete americanSpacesBranch;
    	}
		
    	List<American_Spaces_Notes_and_Attachments__c> tempDocs = [ select id FROM American_Spaces_Notes_and_Attachments__c WHERE Id in :tempIDs  ];
    	
    	delete tempDocs;
    	
    	if (americanSpacesBranch == null || americanSpacesBranch.id == null)
	   	{
	   		return std.cancel();
	   	}
    	else
	    {
    		Id id = [SELECT Name_of_Space__r.id FROM American_Space_Branch__c WHERE id = :getAmericanSpacesBranch().id].Name_of_Space__r.id;
        	
    		PageReference returningPage = new PageReference( '/' + id );
    	
        	return returningPage;
	    }
    }
    
    
    public void newAttachment()
    {
        updateAmericanSpaceContact( false );
        
        Attachment doc;
        American_Spaces_Notes_and_Attachments__c information;
        
        if (null == getAmericanSpacesBranch().id)
        {
        	std.save();
        	americanSpacesBranch = (American_Space_Branch__c) std.getRecord();  
        	isDirty = true;
        	
        	attachments = getCurrentattachments();        	
        	doc = new Attachment();
        	information = new American_Spaces_Notes_and_Attachments__c();
        }
        else
        {
        	attachments = getattachments();        	
        	doc = new Attachment( parentId=getAmericanSpacesBranch().id  );
        	information = new American_Spaces_Notes_and_Attachments__c( name='', Object_ID__c=getAmericanSpacesBranch().id  );
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
    	return isModifiable;
    }
    
    
    public boolean getIsDeletable()
    {
    	return AmericanSpacesAccess.hasDeleteAccess();
    }
}
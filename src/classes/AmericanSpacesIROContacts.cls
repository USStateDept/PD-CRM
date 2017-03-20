public class AmericanSpacesIROContacts
{
    public AmericanSpacesAttachment[] attachments;
    
    public Integer attachmentNumber{ get; set; }
    public Id postId{ get; set; }
    public String postName{ get; set; }
    
    private IRO_Contacts__c iroContact;
    private ApexPages.StandardController std;
    
    private List<Id> tempIDs = new List<Id>();
    public List<String> portfolio{get; set; }
    private boolean isModifiable = false;
    private boolean isDirty = false;
    
    public String columnName{ get; set; }
	public String ascOrDesc{ get; set; }
    
    public AmericanSpacesIROContacts()
    {
    	if (iroContact == null)
    	{
    		iroContact = new IRO_Contacts__c();
    	}
    	
    	if (columnName == null)
		{
			columnName = 'Last_Name__c';
			ascOrDesc = ' asc';
		}
		else
		{
			String urlColumn = Apexpages.currentPage().getParameters().get( 'sortBy' );
			
			if (columnName.equals( urlColumn ))
			{
				if (ascOrDesc.equals( ' asc' ))
				{
					ascOrDesc = ' desc';
					columnName = urlColumn;
				}
				else
				{
					ascOrDesc = ' asc';
					columnName = urlColumn;
				}
			}
			else
			{
				ascOrDesc = ' asc';
				columnName = urlColumn;
			}
		}
    }
    
    public AmericanSpacesIROContacts( ApexPages.StandardController stdCtrl )
    {
        std = stdCtrl;
        
        if (std != null)
        {
            iroContact = (IRO_Contacts__c) std.getRecord();
        }
        
        PermissionSetAssignment p;
            
        try
        {
            p = [SELECT PermissionSet.Label
                   FROM PermissionSetAssignment
                  WHERE PermissionSet.IsOwnedByProfile = FALSE
                    AND PermissionSetId
                        IN (SELECT ParentId FROM ObjectPermissions WHERE SObjectType = 'IRO_Contacts__c')
                    AND Assignee.Name = :Userinfo.getName() LIMIT 1];
                    
            String permissionName = p.PermissionSet.Label;
			System.debug('@@@permissionName...'+permissionName);
            if (permissionName.containsIgnoreCase( 'American Spaces Washington' ))
            {
                isModifiable = true;
            }
            else
            {System.debug('iro fn...'+iroContact.First_Name__c+', iro ln...'+iroContact.Last_Name__c);
                if (iroContact.First_Name__c.equalsIgnoreCase( Userinfo.getFirstName()) && iroContact.Last_Name__c.equalsIgnoreCase( Userinfo.getLastName() ))
                {
                    isModifiable = true;
                }
            }
        }
        catch( Exception e )
        {
            p = null;
            isModifiable = false;
        }
        
        try
        {
            Id qryPostId = [SELECT Home_Post__r.id FROM IRO_Contacts__c WHERE id = :iroContact.id].Home_Post__r.id;
            iroContact.Home_Post__c = qryPostId;
    
            American_Spaces_Post_Contacts__c aspc = [SELECT id, Name FROM American_Spaces_Post_Contacts__c WHERE id = :iroContact.Home_Post__c];
    
            postId = aspc.id;
            postName = aspc.Name;
            
            portfolio = iroContact.Portfolio__c.split( ',' );
        }
        catch( Exception e )
        {
            // New Record does not have any Home Post tied to it...
        }
    }
    
    
    public PageReference refresh()
    {
    	return null;
    }
    
    
    public IRO_Contacts__c getIroContact()
    {
        return iroContact;
    }
    public void setIroContact( IRO_Contacts__c iroContact )
    {
        this.iroContact = iroContact;
    }


    public List<AmericanSpacesAttachment> getAttachments()
    {
        if (( null != getIroContact().id ) && ( attachments == null ))
        {
            attachments = new List<AmericanSpacesAttachment>();

            for (American_Spaces_Notes_and_Attachments__c data : 
                                  [SELECT Type_of_Document__c, Description__c, Document_ID__c, Comments__c, Date__c, extension__c, name
                                     FROM American_Spaces_Notes_and_Attachments__c
                                    WHERE Object_ID__c = :getIroContact().id
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
                    if (getIroContact() != null && getIroContact().id != null)
                    {
                        if (attachmentObj.getAttachment().Id == null)
                        {
                            attachmentObj.getAttachment().ParentId = getIroContact().id;
                        }
                        attachmentObj.getInformation().Object_ID__c = getIroContact().id;
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
                ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, 'Home Post: No Matches found.' ));
                return null;
            }
            
            iroContact.Home_Post__c = postId;
            
            std.save();
            iroContact = (IRO_Contacts__c) std.getRecord();
        }

        if (updateAmericanSpaceContact( true ))
        {
            returningPage = new PageReference( '/' + getIroContact().id );
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
            delete iroContact;
        }

        List<American_Spaces_Notes_and_Attachments__c> tempDocs = [ select id FROM American_Spaces_Notes_and_Attachments__c WHERE Id in :tempIDs  ];
        
        delete tempDocs;
        
        if (Apexpages.currentPage().getParameters().get( 'retURL' ) == null)
        {
            PageReference returningPage = new PageReference( '/apex/IRO_Contacts_ListView' );
            return returningPage;
        }
        else if (iroContact == null || iroContact.id == null)
        {
            return std.cancel();
        }
        else
        {
            PageReference returningPage = new PageReference( '/' + getIroContact().id );
            return returningPage;
        }
    }
    
    
    public void newAttachment()
    {
        updateAmericanSpaceContact( false );
        
        Attachment doc;
        American_Spaces_Notes_and_Attachments__c information;
        
        if (null == getIroContact().id)
        {
            std.save();
            iroContact = (IRO_Contacts__c) std.getRecord(); 
            isDirty = true;
            
            attachments = getCurrentattachments();          
            doc = new Attachment( ParentId=getIroContact().id );
            information = new American_Spaces_Notes_and_Attachments__c();
        }
        else
        {
            attachments = getattachments();         
            doc = new Attachment( ParentId=getIroContact().id  );
            information = new American_Spaces_Notes_and_Attachments__c( name='', Object_ID__c=getIroContact().id  );
        }
        
        information.Type_of_Document__c = 'Trip Reports';
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
    
    
    public List<IRO_Contacts__c> getIroContacts()
    {
        String soql = 'SELECT id, First_Name__c, Last_Name__c, Middle_Name__c, Region__c, Home_Post__r.id, Home_Post__r.name FROM IRO_Contacts__c';
        
        if (columnName != null && columnName.length() > 0)
        {
            soql += ' ORDER BY ' + columnName + ascOrDesc;
        }
        
        return Database.query( soql );
    }
    

    public PageReference createNewAction()
    {
        PageReference returningPage = new PageReference( '/apex/AmericanSpace_IRO_Edit' );
        
        return returningPage;
    }
    
    public static testMethod void testAmericanSpacesIROContacts()
    {             
        Test.startTest();
        
        American_Spaces_Post_Contacts__c aspc = new American_Spaces_Post_Contacts__c( Name='test' );
        insert aspc;
        
        IRO_Contacts__c ascc = new IRO_Contacts__c( First_Name__c=UserInfo.getFirstName(), last_name__c=UserInfo.getLastName(), Home_Post__c=aspc.id );
        insert ascc;
        
        IRO_Contacts__c ascc2 = new IRO_Contacts__c( First_Name__c='test', last_name__c='test', Home_Post__c=aspc.id );
        
        AmericanSpacesIROContacts asiroc = new AmericanSpacesIROContacts();
        
		ApexPages.StandardController sc2 = new ApexPages.StandardController( ascc );
		ApexPages.StandardController sc3 = new ApexPages.StandardController( ascc2 );
        
        AmericanSpacesIROContacts amsc = new AmericanSpacesIROContacts( sc2 );
        AmericanSpacesIROContacts amsc2 = new AmericanSpacesIROContacts( sc3 );
        
        amsc.setIroContact( ascc );
        System.assertEquals( amsc.getIroContact().Id, ascc.Id );
        
        Attachment doc = new Attachment( name='testImg.png', parentID=ascc.Id, body=Blob.valueOf('Test Blob String'));
        insert doc;
        
        American_Spaces_Notes_and_Attachments__c asna = new American_Spaces_Notes_and_Attachments__c( Name='test', Document_ID__c=doc.id, object_ID__c=ascc.id );
        insert asna;
        
        blob img = EncodingUtil.base64Decode( '123123123123' );
        
        AmericanSpacesAttachment ascp = new AmericanSpacesAttachment( doc, img, asna );
        ascp.setAttachment( doc );
        ascp.setAttachmentDetail( img );
        ascp.setInformation( asna );
		amsc.columnName = 'Last_Name__c ';
		amsc.ascOrDesc = 'asc';
		
        amsc.attachments = amsc.getAttachments();
        System.assertEquals( amsc.attachments.size(), 1 );
        amsc.attachments.add( ascp );
        amsc.newAttachment();
        amsc2.newAttachment();
        
        amsc.attachmentNumber = 2;
        amsc.deleteAttachment();
        amsc.getIroContacts();
        amsc.createNewAction(); 
        
        amsc.refresh();
        
        amsc.updateAmericanSpaceContact( true );
        System.assertEquals( amsc.save().getUrl(), '/' + ascc.id );
        System.assertEquals( amsc.getIsModifiable(), true );
        amsc.getCurrentattachments();
        amsc.cancel();
        
        delete ascc;
    }
    
    
    public boolean getIsModifiable()
    {
        return isModifiable;
    }
}
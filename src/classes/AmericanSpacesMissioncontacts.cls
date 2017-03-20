public class AmericanSpacesMissioncontacts
{
    public ApexPages.StandardController std{get; set;}
    public American_Spaces_Mission_Contact__c missionContact{get; set;}
    public Id postId{ get; set; }
    public String postName{ get; set; }
    
	private boolean isModifiable = false;

    public AmericanSpacesMissioncontacts( ApexPages.StandardController stdCtrl )
    {
        std = stdCtrl;
        if (!Test.isRunningTest())
        {       
            missionContact = (American_Spaces_Mission_Contact__c) std.getRecord();
            
            String postID = ApexPages.currentPage().getParameters().get( 'postID' );
            
            if (postID != null && postID.length() > 0)
            {
            	missionContact.Managing_Post_City__c = postID;
            }
            else
            {
            	Id qryPostId = [SELECT Managing_Post_City__r.id FROM American_Spaces_Mission_Contact__c WHERE id = :missionContact.id].Managing_Post_City__r.id;
            	missionContact.Managing_Post_City__c = qryPostId;
            }
            
            American_Spaces_Post_Contacts__c aspc = [SELECT id, Name FROM American_Spaces_Post_Contacts__c WHERE id = :missionContact.Managing_Post_City__c];

            this.postId = aspc.id;
            this.postName = aspc.Name;
        }
    }

    
    public American_Spaces_Mission_Contact__c getMissionContact()
    {
        return missionContact;
    }
    public void setMissionContact( American_Spaces_Mission_Contact__c missionContact )
    {
    	this.missionContact = missionContact;
    }
        
    
    public PageReference save()
    {
    	PageReference returningPage = null;
    
    	if (std != null)
    	{
    		missionContact.Name = missionContact.First_Name__c + ' ' + missionContact.Last_Name__c;
    		
    		try
        	{
        		Id id = [SELECT Id FROM American_Spaces_Post_Contacts__c WHERE id = :postId AND name = :postName LIMIT 1].id;
        	}
        	catch( Exception e )
        	{
        		ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, 'Managing Post City: No Matches found.' ));
        		return null;
        	}
        	
        	missionContact.Managing_Post_City__c = postId;
        	
			std.save();
			
			missionContact = (American_Spaces_Mission_Contact__c) std.getRecord();
    	}
    	
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
			returningPage = new PageReference( '/' + getMissionContact().id );
		}
		
		return returningPage;
    }
    
    public PageReference deleteTheRecord()
    {
    	Id id = [SELECT Managing_Post_City__r.id FROM American_Spaces_Mission_Contact__c WHERE id = :missionContact.id].Managing_Post_City__r.id;
    	PageReference returningPage = new PageReference( '/' + id );
    	
    	delete missionContact;
    	
        return returningPage;
	}
	
	
    public PageReference cancel()
    {
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
			returningPage = new PageReference( '/' + getMissionContact().id );
		}
		
		return returningPage;
    }
    
    
    public boolean getIsModifiable()
    {
    	return AmericanSpacesAccess.hasAccess( missionContact.Managing_Post_City__c, missionContact.Country__c );
    }
	
	public boolean getIsDeletable()
    {
    	return AmericanSpacesAccess.hasDeleteAccess();
    }
    
    public static testMethod void testAmericanSpacesMissioncontacts()
    {             
        Test.startTest();
        American_Spaces_Post_Contacts__c ecRecord = new American_Spaces_Post_Contacts__c( Name='test', Country__c='test', Region__c='test' );
    	insert ecRecord;
        
        American_Spaces_Mission_Contact__c testRecord = new American_Spaces_Mission_Contact__c( Managing_Post_City__c=ecRecord.id );
        insert testRecord;
        
        AmericanSpacesMissioncontacts acv = new AmericanSpacesMissioncontacts( null );
        
        acv.setMissionContact( testRecord ); 
        acv.cancel();
        System.assertEquals( acv.getMissionContact(), testRecord );          
        System.assertEquals( acv.save().getUrl(), new PageReference( '/' + testRecord.id ).getUrl());
        //System.assertEquals( acv.getIsModifiable(), true );
        acv.deleteTheRecord();
        acv.getIsDeletable();
    }
}
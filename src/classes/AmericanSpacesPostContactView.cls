public class AmericanSpacesPostContactView
{
    public American_Spaces_Post_Contacts__c aspc{ get; set; }
    public List<American_Spaces_Post_Contacts__c> aspcs{ get; set; }
    public boolean isLoaded{ get; set; }
    public boolean renderCountry{ set; get; }
    public boolean renderPost{ set; get; }
    public Id childID{ set; get; }
    public American_Spaces_Statistic__c assc {get; set; }
    
    public AmericanSpacesPostContactView( ApexPages.StandardController stdCtrl )
    {
        String country = ApexPages.currentPage().getParameters().get( 'country' );
        String postID = ApexPages.currentPage().getParameters().get( 'postID' );
        String id = ApexPages.currentPage().getParameters().get( 'id' );
        
        if (country != null && country.length() > 0)
        {
        	country = EncodingUtil.urlDecode( country, 'UTF-8');
            aspcs = [SELECT id, country__c, region__c, name FROM American_Spaces_Post_Contacts__c WHERE country__c = :country];
            
            aspc = new American_Spaces_Post_Contacts__c();
            
            aspc.Region__c = aspcs.get( 0 ).Region__c;
            aspc.Country__c = aspcs.get( 0 ).Country__c;
            renderCountry = true;
            renderPost = false;
        }
        else if (postID != null && postID.length() > 0)
        {
            aspc = [SELECT id, country__c, region__c, name FROM American_Spaces_Post_Contacts__c WHERE id = :postID];
            renderPost = true;
            renderCountry = false;
        }
        else if (id != null && id.length() > 0)
        {
            aspc = [SELECT id, country__c, region__c, name FROM American_Spaces_Post_Contacts__c WHERE id = :id];
            renderPost = true;
            renderCountry = false;
        }
        else
        {
            renderPost = false;
            renderCountry = false;
            isLoaded = false;
        }
    }
    
    
    public List<IRO_Contacts__c> getIroContacts()
    {
        Id postId;
        
        if (aspc.Id != null)
        {
            postId = aspc.id;
        }
        
        String soql = 'SELECT First_Name__c, Last_Name__c, Id, Portfolio__c FROM IRO_Contacts__c WHERE Portfolio__c like ';
        
        if (renderCountry || renderPost)
        {
            String country = String.escapeSingleQuotes( aspc.Country__c );
            soql += '\'%' + country + '%\'';
            if (postId != null)
            {
                soql += ' OR Home_Post__c = :postId'; 
            }
        }
        else
        {
            return null;
        }
        
        List<IRO_Contacts__c> moreFilteredList = new List<IRO_Contacts__c>();
        
		for (IRO_Contacts__c myContact : Database.query( soql ))
		{
			if (myContact.Portfolio__c != null)
			{
				List<String> portfolios = myContact.Portfolio__c.split( ',' );
				
				Boolean exist = false;
				
				for (Integer i = 0; i < portfolios.size(); i++)
				{
					System.debug( portfolios[i] );
					if (portfolios[i].equals( ' Republic of' ))
					{
						String actualCountry = portfolios[i - 1] + ', ' + 'Republic of';
						
						if (actualCountry.equals( aspc.Country__c ))
						{
							moreFilteredList.add( myContact );
							break;
						}
					}
					else if (portfolios[i].equals( ' Republic of the' ))
					{
						String actualCountry = portfolios[i - 1] + ', ' + 'Republic of the';
						
						if (actualCountry.equals( aspc.Country__c ))
						{
							moreFilteredList.add( myContact );
							break;
						}
					}		
					else if (portfolios[i].equals( aspc.Country__c ))
					{
						moreFilteredList.add( myContact );
						break;
					}
				}
			}
		}
		
		return moreFilteredList;
	}

    
    public List<American_Spaces_Contact__c> getAmericanSpaceContacts()
    {
        String soql = 'SELECT id, Name, Managing_Post_City__r.name, Type_of_Space__c, City__c, Status__c, Open_to_public__c FROM American_Spaces_Contact__c ';
        
        if (renderCountry)
        {
            String country = aspc.Country__c;
            soql += 'WHERE Country__c = :country';  
        }
        else if (renderPost)
        {
            Id postID = aspc.Id;
            soql += 'WHERE Managing_Post_City__c = :postID';
        }
        else
        {
            return null;
        }
        
		soql += ' ORDER BY Name';
        
        return Database.query( soql );
    }
    
    
    public List<American_Spaces_Mission_Contact__c> getAmericanSpaceMissionContacts()
    {
        String soql = 'SELECT Id, Managing_Post_City__r.name, Last_Name__c, Middle_Name__c, First_Name__c, Job_Tite__c FROM American_Spaces_Mission_Contact__c ';
        
        if (renderCountry)
        {
            String country = aspc.Country__c;
            soql += 'WHERE Country__c = :country';  
        }
        else if (renderPost)
        {
            Id postID = aspc.Id;
            soql += 'WHERE Managing_Post_City__c = :postID';
        }
        else
        {
            return null;
        }
        
        return Database.query( soql );
    }


    public PageReference createNewMissionContact()
    {
        PageReference returningPage;
        
        String country = ApexPages.currentPage().getParameters().get( 'country' );
        String postID = ApexPages.currentPage().getParameters().get( 'postID' );
        String idStr = ApexPages.currentPage().getParameters().get( 'id' );
        
        if (country != null && country.length() > 0)
        {
            returningPage = new PageReference( '/apex/AmericanSpace_Mission_Edit?country=' + country );
        }
        else if (postID != null && postID.length() > 0)
        {
            returningPage = new PageReference( '/apex/AmericanSpace_Mission_Edit?postID=' + postID );
        }
        else if (idStr != null && idStr.length() > 0)
        {
            returningPage = new PageReference( '/apex/AmericanSpace_Mission_Edit?postID=' + idStr );
        }

        return returningPage;
    }

    
    public PageReference createNewAmericanSpace()
    {
        PageReference returningPage;
        
        String country = ApexPages.currentPage().getParameters().get( 'country' );
        String postID = ApexPages.currentPage().getParameters().get( 'postID' );
        String idStr = ApexPages.currentPage().getParameters().get( 'id' );
        
        if (country != null && country.length() > 0)
        {
            returningPage = new PageReference( '/apex/AmericanSpace_Contact_Edit?country=' + country );
        }
        else if (postID != null && postID.length() > 0)
        {
            returningPage = new PageReference( '/apex/AmericanSpace_Contact_Edit?postID=' + postID );
        }
        else if (idStr != null && idStr.length() > 0)
        {
            returningPage = new PageReference( '/apex/AmericanSpace_Contact_Edit?postID=' + idStr );
        }

        return returningPage;
    }
    
    
    public boolean getHasCreateAccess()
    {
        Map<String,ID> psMap = new Map<String,ID>();
        
        try
        {
	        List<PermissionSetAssignment> permissionSets = 
                [SELECT ID, PermissionSet.Label
                 FROM PermissionSetAssignment
                 WHERE PermissionSet.IsOwnedByProfile = FALSE
                 AND PermissionSetId
                 IN (SELECT ParentId FROM ObjectPermissions WHERE SObjectType = 'American_Spaces_Mission_Contact__c')
                 //AND Assignee.Name = :Userinfo.getName() LIMIT 1].PermissionSet.Label;
                 /* 
                  * Stephanie (08/26/15) - Fixed query to returns all permission sets
                  */
                 AND Assignee.Name = :Userinfo.getName()];
            for(PermissionSetAssignment psa : permissionSets) {
                psMap.put(psa.PermissionSet.Label, psa.Id);
            }
        }
        catch (Exception e)
        {
        	psMap = new Map<String,ID>();
        }
        
        if (psMap.containsKey('American Spaces Washington'))
        {
        	return true;
        }
        
        return false;
    }
}
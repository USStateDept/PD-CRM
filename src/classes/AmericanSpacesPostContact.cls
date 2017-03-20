public class AmericanSpacesPostContact
{
	private List<PostContactView> postContacts;

	public American_Spaces_Contact__c space{ get; set; }

	public String region{ get; set; }
	public String country{ get; set; }
	public String name{ get; set; }
	public String columnName{ get; set; }
	public String spaceName{ get; set; }
	public String spaceType{ get; set; }
	public String ascOrDesc{ get; set; }
	public Boolean bGroup{ get; set; }
	
	public AmericanSpacesPostContact()
	{
		region = Apexpages.currentPage().getParameters().get( 'region' );
		
		if (bGroup == null)
		{
			bGroup = false;	
		}
		if (spaceName == null)
		{
			spaceName = '';
		}
		if (spaceType == null)
		{
			spaceType = '';
		}
		if (region == null)
		{
			region = '';
		}
		if (country == null)
		{
			country = '';
		}
		if (name == null)
		{
			name = '';
		}
		if (ascOrDesc == null)
		{
			ascOrDesc = ' asc';
		}

		if (columnName == null)
		{
			columnName = 'Managing_Post_City__r-region__c, Managing_Post_City__r-country__c';
		}
	}
	

	public PageReference refresh()
    {
    	return null;
    }
    
    
    public PageReference reset()
    {
    	PageReference returningPage  = new PageReference( '/apex/AmSpaces_Post_Contacts_ListView' );
    	region = '';
    	country = '';
    	name = '';
    	columnName = '';
    	spaceName = '';
    	spaceType = '';
    	return returningPage;
    }
	
	
	public List<postContactView> getPostContacts()
	{
		String soql = 'SELECT id, Managing_Post_City__r.id, Managing_Post_City__r.name, Managing_Post_City__r.country__c, Managing_Post_City__r.region__c, Name, Type_of_Space__c, City__c FROM American_Spaces_Contact__c';

      	String countryStr = country + '%';	
      	String regionStr = region + '%';
      	String nameStr = name + '%';
      	String spaceNameStr = spaceName + '%';
      	
      	soql += ' WHERE Managing_Post_City__r.Country__c like :countryStr AND Managing_Post_City__r.Region__c like :regionStr AND Managing_Post_City__r.name like :nameStr';
      	soql += ' AND name like :spaceNameStr';
      	
      	if (spaceType != null && spaceType.length() > 0)
      	{
      		String spaceTypeStr = spaceType + '%';
      		soql += ' AND City__c like :spaceTypeStr';
      	}
	
		if (columnName != null && columnName.length() > 0)
		{
			String filteredColumnName = columnName.replaceAll( '-', '.' );
			soql += ' ORDER BY ' + filteredColumnName + ' ' + ascOrDesc;
		}
		
		Map<American_Spaces_Post_Contacts__c, List<American_Spaces_Contact__c>> results = new Map<American_Spaces_Post_Contacts__c, List<American_Spaces_Contact__c>>();
		postContacts = new List<PostContactView>();

		for (American_Spaces_Contact__c ascc : Database.query( soql ))
		{
			American_Spaces_Post_Contacts__c currentPost = new American_Spaces_Post_Contacts__c( Id= ascc.Managing_Post_City__r.id );
			currentPost.name = ascc.Managing_Post_City__r.name;
			currentPost.country__c = ascc.Managing_Post_City__r.country__c;
			currentPost.region__c = ascc.Managing_Post_City__r.region__c;
			
			String spaceName = ascc.name;
			Id spaceID = ascc.id;
			String spaceType = ascc.City__c;
			
			if (bGroup)
			{
				if (results.containsKey( currentPost ))
				{
					results.get( currentPost ).add( ascc );
				}
				else
				{
					List<American_Spaces_Contact__c> newSpaces = new List<American_Spaces_Contact__c>();
					newSpaces.add( ascc );
					
					results.put( currentPost, newSpaces );
				}
			}
			else
			{
				List<American_Spaces_Contact__c> newSpaces = new List<American_Spaces_Contact__c>();
				newSpaces.add( ascc );
				
				PostContactView view = new PostContactView();
				view.post = currentPost;
				view.spaces = newSpaces;

				postContacts.add( view );
			}
		}

		if (bGroup)
		{
			for (American_Spaces_Post_Contacts__c postContact : results.keySet())
			{
				PostContactView view = new PostContactView();
				view.post = postContact;
				view.spaces = results.get( postContact );
				view.filterName = columnName;
				view.filterDirection = ascOrDesc;
				postContacts.add( view );
			}
	
			postContacts.sort();
		}
		
		return postContacts;
	}
	
	
	public String getTypeOfSpaces()
	{
		String listStr = '';
        
        for (SelectOption so : GLOBAL_Library.getPicklistValues( new American_Spaces_Contact__c(), 'Type_of_Space__c' ))
        {
            listStr += so.getLabel() + ';';
        }
        
        return listStr;
	}
	
	
	class PostContactView implements Comparable
	{
		public American_Spaces_Post_Contacts__c post{ get; set; }
		public List<American_Spaces_Contact__c> spaces{ get; set; }
		public String filterName{ get; set; }
		public String filterDirection{ get; set; }
		
		public PostContactView()
        {
        }
		
		public Integer compareTo( Object compareTo )
		{
			PostContactView other = (PostContactView) compareTo;
			Integer retVal = 0;
			
			if (filterName != null && filterName.length() > 0)
			{
				if ('Managing_Post_City__r-region__c'.equals( filterName ))
				{
					retVal = this.post.Region__c.compareTo( other.post.Region__c );
				}
				else if ('Managing_Post_City__r-country__c'.equals( filterName ))
				{
					retVal = this.post.Country__c.compareTo( other.post.Country__c );
				}
				else if ('Managing_Post_City__r-name'.equals( filterName ))
				{
					retVal = this.post.name.compareTo( other.post.name );
				}

				if ('desc'.equals( filterDirection.trim() ))
	            {
	            	retVal = retVal * -1;
	            }
			}

			return retVal;
		}
	}
}
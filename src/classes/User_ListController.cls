public class User_ListController
{
	private final static String profileName = 'Overage Authenticated Website User';
	public String firstName{get;set;}
	public String lastName{get;set;}
	public String username{get;set;}
	public Id userId{get;set;}
	
	public User_ListController()
	{
		firstName = '';
		username = '';
		lastName = '';
	}
	
	
	public List<User> getListOfSitecomUsers()
	{
		String soql = 'SELECT Name, Username, LastLoginDate, LastPasswordChangeDate, accountid, isActive FROM User WHERE profile.name = :profileName';
		
		if (firstName != null && firstName.length() > 0)
		{
			String firstNameFilter = firstName + '%';
			soql += ' AND firstName like :firstNameFilter';
		}
		
		if (username != null && username.length() > 0)
		{
			String usernameFilter = username + '%';
			soql += ' AND username like :usernameFilter';
		}
		
		if (lastName != null && lastName.length() > 0)
		{
			String lastNameFilter = lastName + '%';
			soql += ' AND lastName like :lastNameFilter';
		}
		
		List<User> userWithModifiedInfo = new List<User>();
		Map<String, User_Reset_History__c> info = new Map<String, User_Reset_History__c>();
		
		for (User_Reset_History__c  hist : [SELECT User__r.id, CreatedDate, CreatedBy.name FROM User_Reset_History__c])
		{
			if (info.containsKey( hist.User__r.id ))
			{
				User_Reset_History__c currentHist = info.get( hist.User__r.id );
				
				if (currentHist.CreatedDate < hist.CreatedDate)
				{
					info.put( hist.User__r.id, hist );
				}
			}
			else
			{
				info.put( hist.User__r.id, hist );
			}
		}
		
		For (User u : Database.query( soql ))
		{
			u.CommunityNickname = '';
			
			if (info.containsKey( u.id ))
			{
				u.CommunityNickname = info.get( u.id ).CreatedBy.name;
			}
			
			userWithModifiedInfo.add( u );
		}
		
		return userWithModifiedInfo;
	}
	
	 
	public PageReference create()
	{
		return new PageReference( '/apex/User_Edit' );
	}
	
	
	public PageReference refresh()
	{
		return null;
	}
	
	
	public void resetPassword()
	{
		System.ResetPasswordResult newPassword = System.resetPassword( userID, false );
		
		User u = [SELECT email, name, username, Contact.account.id FROM user WHERE id = :userID];
		ID accountID = u.contact.account.id;

		String url = [select Website from Account where id = :accountID].website;
		String body;
		String emailTemplate;
		String subject;
		
		try
		{
			body = [SELECT body FROM Note WHERE ParentId = :accountID and Title = 'Email'].body;
			emailTemplate = [SELECT body FROM Note WHERE ParentId = :accountID and Title = 'EmailTemplate'].body;
			subject = [SELECT body FROM Note WHERE ParentId = :accountID and Title = 'Subject'].body;
		}
		catch (Exception e)
		{
			
		}
		
		if (subject == null || subject.length() == 0)
		{
			subject = 'DO NOT REPLY: Your new Salesforce Login and Password';
		}
		
		String emailBody = '';
		
		if (body != null && body.length() > 0)
		{
			emailBody = body;
			emailBody = emailBody.replace( '{username}', u.name );
			emailBody = emailBody.replace( '{userid}', u.Username );
			emailBOdy = emailBody.replace( '{password}', newPassword.getPassword() );
		}
		else
		{
			emailBody += 'Hello ' + u.name + ',<br/><br/>';
			emailBody += 'This e-mail contains your access information for the Salesforce system. Your user name and temporary password are below:<br/><br/>';
			emailBody += 'User name: ' + u.username + '<br/>';
			emailBody += 'Temporary password: ' + newPassword.getPassword() + '<br/><br/>';
			emailBody += 'Please navigate to <a href="' + url + '">Link</a> and login with the credentials below.  Make sure to change your password as soon as possible.<br/><br/>';
			emailBody += 'Remember to maintain proper security when dealing with Logins and Passwords:<br/>';
			emailBody += '   -Never share a login and password with anyone.<br/>';
			emailBody += '   -Never provide login and password information when submitting a help ticket. ';
			emailBody += 'Many people have access to the help ticket system, and by e-mailing a login and password to this address, ';
			emailBody += 'the user is broadcasting this sensitive information to many people. We can assist you without compromising your password.<br/><br/>';
			emailBody += 'If you experience any issues logging in to the system or changing your password,';
			emailBody += ' please contact our help desk at embassy-help@getusinfo.com and a team member will assist you during Washington, DC business hours.<br/><br/>';
			emailBody += 'Thank you.';
		}

		if (emailTemplate != null && emailTemplate.length() > 0)
		{
			SYstem.debug( 'came here1' + emailTemplate );
			GLOBAL_Library.sendEmail( u.email, emailTemplate, subject, emailBody );
		}
		else
		{
			SYstem.debug( 'came here2' );
			GLOBAL_Library.sendEmail( u.email, 'HTML Email Queue', subject, emailBody );
		}
		
		User_Reset_History__c hist = new User_Reset_History__c();
		hist.User__c = u.id;
		
		insert hist;
	}
	
	
	public void activateUser()
	{
		User u = [SELECT id, isActive FROM User WHERE id = :userID];
		u.IsActive = true;
		update u;
	}
	
	
	public void deactivateUser()
	{
		User u = [SELECT id, isActive FROM User WHERE id = :userID];
		u.IsActive = false;
		update u;
	}
}
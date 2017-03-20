public class User_Controller
{
    private ApexPages.StandardController std;
    private String profileName = 'Overage Authenticated Website User';
    private Id profileID;
    private User user;
    
    public String application{get; set;}
    
    public User_Controller( ApexPages.StandardController stdCtrl )
    {
        std = stdCtrl;
        
        if (std != null)
        {
            user = (User) std.getRecord();
            
            if (user.id != null)
            {
                String email = user.Email;
                application = [SELECT account.name FROM Contact where Email = :email limit 1].account.name;
            }
            
            profileID = [SELECT id FROM profile where Name = :profileName].id;
        }
    }
    
    
    public PageReference save()
    {
        if (application != null && !application.equals( 'None' ))
        {
            Account myAccount = [select id from account where name  = :application];
            
            Contact newContact;
            
            user.TimeZoneSidKey = 'GMT';
            user.LocaleSidKey = 'en_US';
            user.EmailEncodingKey = 'ISO-8859-1';
            user.LanguageLocaleKey = 'en_US';
            
            try
            {
                if (user.id == null)
                {
                    newContact = new Contact();
                    newContact.AccountId = myAccount.id;
                    newContact.LastName = user.LastName;
                    newContact.Email = user.Email;
                    insert newContact;
                    
                    user.ContactId = newContact.id;
                    user.ProfileId = profileID;
                    insert user;
                }
                else
                {
                    update user;
                }
                
                return new PageReference( '/apex/User_List' );
            }
            catch (DmlException e)
            {
                if (newContact != null && newContact.id != null)
                {
                    delete newContact;
                }   
            }
        }
        else
        {
            ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, 'Please select an application.' ));
        }
        
        return null;    
    }
    
    
    public String getApplications()
    {
        String apps = 'None;';
        for (Account a : [SELECT Name FROM Account])
        {
            apps += a.Name + ';';
        }
        
        return apps;
    }
}
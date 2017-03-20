public class CRM_EmbassyContactsValidation
{
    private ApexPages.StandardController std{get; set;}
    private Embassy_Contacts__c embassyContact{get; set;}


    public CRM_EmbassyContactsValidation( ApexPages.StandardController stdCtrl )
    {
        std = stdCtrl;
        
        if (std != null)
        {       
            embassyContact = (Embassy_Contacts__c) std.getRecord();
            
            if (embassyContact.id != null)
            {
                embassyContact.Job_Title__c = embassyContact.Job_Title_x__c;
            }
        } 
    }

    
    public PageReference save()
    {
        boolean bSaved = false;
        
        if (embassyContact.Job_Title__c == null)
        {
            ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, 'Job Title: You must enter a value' ));
            return null;
        }
        else
        {
            embassyContact.Job_Title_x__c = embassyContact.Job_Title__c;
            embassyContact.Job_Title__c = null;
        }
        
        std.save();
        
        embassyContact = (Embassy_Contacts__c) std.getRecord();
        
        return new PageReference( '/' + embassyContact.id );
    }
    
    
  
}
public class CRM_AdditionalContactValidation
{
    public ApexPages.StandardController std{get; set;}
    public Additional_Contact_Information__c additionalContact{get; set;}


    public CRM_AdditionalContactValidation( ApexPages.StandardController stdCtrl )
    {
        std = stdCtrl;
        if (std != null)
        {       
            additionalContact = (Additional_Contact_Information__c) std.getRecord();
            additionalContact.Job_Title__c = additionalContact.Job_Title_x__c;
        }            
    }


    public PageReference save()
    {
        boolean bSaved = false;
        
        PageReference returningPage = null;
        
        if (additionalContact.Job_Title__c == null)
        {
            ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, 'Job Title: You must enter a value' ));
            return null;
        }
        else
        {
            additionalContact.Job_Title_x__c = additionalContact.Job_Title__c;
            additionalContact.Job_Title__c = null;
        }
        
        std.save();
        additionalContact = (Additional_Contact_Information__c) std.getRecord();

        Id id = [SELECT City__r.id FROM Additional_Contact_Information__c WHERE id = :additionalContact.id].City__r.id;
        return new PageReference( '/' + id );
    }
    
    
    
}
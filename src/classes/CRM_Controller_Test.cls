@isTest
public class CRM_Controller_Test {

    public static testMethod void testEmbassyContactsValidation()
    {             
        Test.startTest();
        
        User u3 = [SELECT Id FROM User WHERE name like 'Integrator Functional%' LIMIT 1];
        
        Embassy_Contacts__c ecc = new Embassy_Contacts__c();
        insert ecc;
        
        Embassy_Contacts__c ecc2 = new Embassy_Contacts__c();
        insert ecc2;
        
        System.RunAs( u3 )
        {
            ApexPages.StandardController sc = new ApexPages.StandardController( ecc );
            CRM_EmbassyContactsValidation ecv = new CRM_EmbassyContactsValidation( sc );
            ecv.embassyContact.Job_Title__c = 'test';
            
            System.assertEquals( '/' + ecc.id, ecv.save().getUrl() );
            
            ApexPages.StandardController sc2 = new ApexPages.StandardController( ecc2 );
            CRM_EmbassyContactsValidation ecv2 = new CRM_EmbassyContactsValidation( sc2 );
            
            System.assertEquals( null, ecv.save() );
        }
        
        Test.stopTest();
    }
}
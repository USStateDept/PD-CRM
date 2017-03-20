@isTest
public class CRM_Controller_Additional_Test {

      public static testMethod void testAdditionalContactValidation()
    {             
        Test.startTest();
        Embassy_Contacts__c ecc = new Embassy_Contacts__c( first_name_x__c='test' );
        insert ecc;
        
        Additional_Contact_Information__c acic = new Additional_Contact_Information__c( City__c=ecc.id, Email_Work__c='test@test.com' );
        insert acic;
        
        Additional_Contact_Information__c acic2 = new Additional_Contact_Information__c( City__c=ecc.id, Email_Work__c='test@test.com' );
        insert acic2;
        User u3 = [SELECT Id FROM User WHERE name like 'Integrator Functional%' LIMIT 1];
        
        System.RunAs( u3 )
        {
            ApexPages.StandardController sc = new ApexPages.StandardController( acic );
            CRM_AdditionalContactValidation acv = new CRM_AdditionalContactValidation( sc );   
            acv.additionalContact.Job_Title__c = 'test';
            System.assertEquals( '/' + ecc.id, acv.save().getUrl() );
            
            ApexPages.StandardController sc2 = new ApexPages.StandardController( acic2 );
            CRM_AdditionalContactValidation acv2 = new CRM_AdditionalContactValidation( sc2 );   
            System.assertEquals( null, acv.save() );
        
        }
        
        Test.stopTest();
    }
}
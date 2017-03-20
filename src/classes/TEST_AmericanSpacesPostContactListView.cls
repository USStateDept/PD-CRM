@isTest
public class TEST_AmericanSpacesPostContactListView
{
	public static testMethod void testAmericanSpacesPostContact()
    {             
        Test.startTest();
        
        ApexPages.currentPage().getParameters().put( 'sortBy', 'name' );
        
        American_Spaces_Post_Contacts__c aspc = new American_Spaces_Post_Contacts__c( Name='test', Region__c='test', Country__c='test' );
        insert aspc;
        
        American_Spaces_Contact__c ascc = new American_Spaces_Contact__c( Name='test', City__c='test', Managing_Post_City__c=aspc.id );
        insert ascc;
        
        AmericanSpacesPostContact asp = new AmericanSpacesPostContact();
        
        System.assertEquals( asp.refresh(), null );
        
        asp.columnName = 'Country__c';
        asp.spaceType = 'test';
        
        System.assertEquals( asp.getPostContacts().size(), 1 );

        asp.reset();
    }
}
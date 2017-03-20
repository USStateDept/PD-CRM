@isTest
public class TEST_AmericanSpacesPostContactView {
	@isTest
    static void testAmericanSpacesPostContactView()
    {             
        Test.startTest();
      
        American_Spaces_Post_Contacts__c aspc = new American_Spaces_Post_Contacts__c( Name='test', region__c='EUR', country__c='Brazil' );
        insert aspc;
        
        American_Spaces_Contact__c ascc1 = new American_Spaces_Contact__c( Name='test', Managing_Post_City__c=aspc.id, Type_of_Space__c='Information Resource Center' );
        insert ascc1;
        
        American_Spaces_Contact__c ascc2 = new American_Spaces_Contact__c( Name='test', Managing_Post_City__c=aspc.id, Type_of_Space__c='American Center' );
        insert ascc2;
        
        American_Spaces_Contact__c ascc3 = new American_Spaces_Contact__c( Name='test', Managing_Post_City__c=aspc.id, Type_of_Space__c='Binational Center' );
        insert ascc3;
        
        American_Spaces_Contact__c ascc4 = new American_Spaces_Contact__c( Name='test', Managing_Post_City__c=aspc.id, Type_of_Space__c='Science Corner' );
        insert ascc4;
        
         American_Spaces_Contact__c ascc5 = new American_Spaces_Contact__c( Name='test', Managing_Post_City__c=aspc.id, Type_of_Space__c='American Corner' );
        insert ascc5;
        
        American_Spaces_Statistic__c testRecord1 = new American_Spaces_Statistic__c( Name_of_Space__c=ascc1.id, Number_of_Programs__c=1, Number_of_Program_Attendees__c=1, Number_of_Visitors__c=1, Month__c='October', Year__c='2011' );
        insert testRecord1;
        
        American_Spaces_Statistic__c testRecord2 = new American_Spaces_Statistic__c( Name_of_Space__c=ascc2.id, Number_of_Programs__c=1, Number_of_Program_Attendees__c=1, Number_of_Visitors__c=1, Month__c='October', Year__c='2011' );
        insert testRecord2;
        
        American_Spaces_Statistic__c testRecord3 = new American_Spaces_Statistic__c( Name_of_Space__c=ascc3.id, Number_of_Programs__c=1, Number_of_Program_Attendees__c=1, Number_of_Visitors__c=1, Month__c='October', Year__c='2011' );
        insert testRecord3;
        
        American_Spaces_Statistic__c testRecord4 = new American_Spaces_Statistic__c( Name_of_Space__c=ascc4.id, Number_of_Programs__c=1, Number_of_Program_Attendees__c=1, Number_of_Visitors__c=1, Month__c='October', Year__c='2011');
        insert testRecord4;
        
        American_Spaces_Statistic__c testRecord5 = new American_Spaces_Statistic__c( Name_of_Space__c=ascc5.id, Number_of_Programs__c=1, Number_of_Program_Attendees__c=1, Number_of_Visitors__c=1, Month__c='October', Year__c='2011' );
        insert testRecord5;

   
        ApexPages.currentPage().getParameters().put( 'country', 'Brazil' );
        ApexPages.currentPage().getParameters().put( 'postID', 'test' );
        
        AmericanSpacesPostContactView aspcv = new AmericanSpacesPostContactView( null );
        
        aspcv.childID= aspc.id;
        
        Test.stopTest();
        
        System.assertEquals( aspcv.getAmericanSpaceContacts().size(), 5 );
        System.assertEquals( aspcv.getAmericanSpaceMissionContacts().size(), 0 );
        
        System.assertEquals( aspcv.createNewAmericanSpace().getUrl(), '/apex/AmericanSpace_Contact_Edit?country=' + aspc.Country__c );
        System.assertEquals( aspcv.createNewMissionContact().getUrl(), '/apex/AmericanSpace_Mission_Edit?country=' + aspc.Country__c );
    }
    
    @isTest
    static void testAmericanSpacesPostContactViewById() {
        Test.startTest();
      
        American_Spaces_Post_Contacts__c aspc = new American_Spaces_Post_Contacts__c( Name='test', region__c='EUR', country__c='Brazil' );
        insert aspc;
        
        ApexPages.currentPage().getParameters().put( 'id', aspc.Id);
        AmericanSpacesPostContactView aspcv = new AmericanSpacesPostContactView(null);
        System.assert(aspcv.renderPost);
        
        Test.stopTest();
    }
    
    @isTest
    static void testGetAmericanSpacesContactsByPostId() {
       	Test.startTest();
      
        American_Spaces_Post_Contacts__c aspc = new American_Spaces_Post_Contacts__c( Name='test', region__c='EUR', country__c='Brazil' );
        insert aspc;
        
        American_Spaces_Contact__c ascc1 = new American_Spaces_Contact__c( Name='test', Managing_Post_City__c=aspc.id, Type_of_Space__c='Information Resource Center' );
        insert ascc1;
        
        American_Spaces_Contact__c ascc2 = new American_Spaces_Contact__c( Name='test', Managing_Post_City__c=aspc.id, Type_of_Space__c='American Center' );
        insert ascc2;
        
        ApexPages.currentPage().getParameters().put( 'postID', aspc.Id);
        
        AmericanSpacesPostContactView aspcv = new AmericanSpacesPostContactView(null);
        System.assertEquals(2, aspcv.getAmericanSpaceContacts().size());
        
        Test.stopTest();
    }
    
    @isTest
    static void testGetAmericanSpaceMissionContactsByPostId() {
       	Test.startTest();
      
        American_Spaces_Post_Contacts__c aspc = new American_Spaces_Post_Contacts__c( Name='test', region__c='EUR', country__c='Brazil' );
        insert aspc;
        
        American_Spaces_Contact__c ascc1 = new American_Spaces_Contact__c( Name='test', Managing_Post_City__c=aspc.id, Type_of_Space__c='Information Resource Center' );
        insert ascc1;

		American_Spaces_Mission_Contact__c asmc1 = new American_Spaces_Mission_Contact__c(first_name__c='test', last_name__c='test', Managing_Post_City__c=aspc.id);
        insert asmc1;
        
        ApexPages.currentPage().getParameters().put( 'postID', aspc.Id);
        
        AmericanSpacesPostContactView aspcv = new AmericanSpacesPostContactView(null);
        System.assertEquals(1, aspcv.getAmericanSpaceMissionContacts().size());
    
    	Test.stopTest();
    }
    
    @isTest
    static void testGetIROContacts() {
        Test.startTest();
        
        American_Spaces_Post_Contacts__c aspc = new American_Spaces_Post_Contacts__c( Name='test', region__c='AF', country__c='Brazil' );
        insert aspc;
        
        American_Spaces_Contact__c ascc1 = new American_Spaces_Contact__c( Name='test', Managing_Post_City__c=aspc.id, Type_of_Space__c='Information Resource Center' );
        insert ascc1;
        
        IRO_Contacts__c ascc = new IRO_Contacts__c( First_Name__c='test', last_name__c='test', Home_Post__c=aspc.id , Portfolio__c='Brazil, Congo, Republic of the');
        insert ascc;
        
        ApexPages.currentPage().getParameters().put( 'postID', aspc.Id);
        
        AmericanSpacesPostContactView aspcv = new AmericanSpacesPostContactView(null);
        System.assertEquals(1, aspcv.getIroContacts().size());
        
        Test.stopTest();
    }
    
    @isTest
    static void testCreateNewMissionContactUsingPostId() {
        Test.startTest();
        
        American_Spaces_Post_Contacts__c aspc = new American_Spaces_Post_Contacts__c( Name='test', region__c='AF', country__c='Brazil' );
        insert aspc;
        
        American_Spaces_Contact__c ascc1 = new American_Spaces_Contact__c( Name='test', Managing_Post_City__c=aspc.id, Type_of_Space__c='Information Resource Center' );
        insert ascc1;   
        
        ApexPages.currentPage().getParameters().put( 'postID', aspc.Id);
        
        AmericanSpacesPostContactView aspcv = new AmericanSpacesPostContactView(null);
        System.assertEquals( aspcv.createNewMissionContact().getUrl(),  '/apex/AmericanSpace_Mission_Edit?postID=' + aspc.Id );
        
        Test.stopTest();
    }

    @isTest
    static void testCreateNewMissionContactUsingId() {
        Test.startTest();
        
        American_Spaces_Post_Contacts__c aspc = new American_Spaces_Post_Contacts__c( Name='test', region__c='AF', country__c='Brazil' );
        insert aspc;
        
        American_Spaces_Contact__c ascc1 = new American_Spaces_Contact__c( Name='test', Managing_Post_City__c=aspc.id, Type_of_Space__c='Information Resource Center' );
        insert ascc1;   
        
        ApexPages.currentPage().getParameters().put( 'id', aspc.Id);
        
        AmericanSpacesPostContactView aspcv = new AmericanSpacesPostContactView(null);
        System.assertEquals( aspcv.createNewMissionContact().getUrl(),  '/apex/AmericanSpace_Mission_Edit?postID=' + aspc.Id );
        
        Test.stopTest();
    }
    
    @isTest
    static void testCreateNewAmericanSpaceUsingPostId() {
        Test.startTest();
        
        American_Spaces_Post_Contacts__c aspc = new American_Spaces_Post_Contacts__c( Name='test', region__c='AF', country__c='Brazil' );
        insert aspc;
        
        American_Spaces_Contact__c ascc1 = new American_Spaces_Contact__c( Name='test', Managing_Post_City__c=aspc.id, Type_of_Space__c='Information Resource Center' );
        insert ascc1;   
        
        ApexPages.currentPage().getParameters().put( 'postID', aspc.Id);
        
        AmericanSpacesPostContactView aspcv = new AmericanSpacesPostContactView(null);
        System.assertEquals( aspcv.createNewAmericanSpace().getUrl(),  '/apex/AmericanSpace_Contact_Edit?postID=' + aspc.Id );
        
        Test.stopTest();
    }
    
    @isTest
    static void testCreateNewAmericanSpaceUsingId() {
        Test.startTest();
        
        American_Spaces_Post_Contacts__c aspc = new American_Spaces_Post_Contacts__c( Name='test', region__c='AF', country__c='Brazil' );
        insert aspc;
        
        American_Spaces_Contact__c ascc1 = new American_Spaces_Contact__c( Name='test', Managing_Post_City__c=aspc.id, Type_of_Space__c='Information Resource Center' );
        insert ascc1;   
        
        ApexPages.currentPage().getParameters().put( 'id', aspc.Id);
        
        AmericanSpacesPostContactView aspcv = new AmericanSpacesPostContactView(null);
        System.assertEquals( aspcv.createNewAmericanSpace().getUrl(),  '/apex/AmericanSpace_Contact_Edit?postID=' + aspc.Id );
        
        Test.stopTest();
    }
    
    @isTest 
    static void testGetHasCreateAccess() {
        Test.startTest();
        User currentUser = [SELECT id FROM User WHERE name = :UserInfo.getName() Limit 1];
        TestDataFactory.setPermissionSet(currentUser, 'American Spaces Washington');
        AmericanSpacesPostContactView aspcv = new AmericanSpacesPostContactView(null);
        System.assert( aspcv.getHasCreateAccess());
		Test.stopTest();
    }

}
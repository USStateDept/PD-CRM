@isTest
public class TEST_AmericanSpacesAttachments
{
	static testMethod void americanSpacesAttachment()
	{
		Blob myBlob = Blob.valueOf('Test Blob String');
		
		American_Spaces_Post_Contacts__c aspc = new American_Spaces_Post_Contacts__c( Name='test' );
        insert aspc;
        
        American_Spaces_Contact__c asccc = new American_Spaces_Contact__c( Name='test', Managing_Post_City__c=aspc.id );
        insert asccc;
        
        American_Space_Branch__c ascc = new American_Space_Branch__c( Name_of_Space__c=asccc.id );
        insert ascc;
		
		Attachment doc = new Attachment( name='testImg.png', parentId=ascc.Id, body=myBlob );
        insert doc;
        
        American_Spaces_Notes_and_Attachments__c asna = new American_Spaces_Notes_and_Attachments__c( Name='test', Document_ID__c=doc.id, object_ID__c=ascc.id );
        insert asna;
        
        Test.startTest();
        
        AmericanSpacesAttachment newObj = new AmericanSpacesAttachment( doc, myBlob, asna );
        
        newObj.setAttachment( doc );
        System.assertEquals( doc, newObj.getAttachment() );
        
        newObj.setInformation( asna );
        System.assertEquals( asna, newObj.getInformation() );
        
        newObj.setAttachmentDetail( myBlob );
        System.assertEquals( myBlob, newObj.getAttachmentDetail() );
        
        newObj.deleteObj();
        System.assertEquals( null, newObj.getAttachmentDetail() );
        
        Test.stopTest();
	}
}
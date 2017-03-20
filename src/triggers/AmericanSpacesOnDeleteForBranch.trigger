trigger AmericanSpacesOnDeleteForBranch on American_Space_Branch__c (before delete)
{
    for(American_Space_Branch__c X : Trigger.old)
    {
        List<Attachment> docs = new List<Attachment>();
        List<American_Spaces_Notes_and_Attachments__c> infos = new List<American_Spaces_Notes_and_Attachments__c>();
        
        for (American_Spaces_Notes_and_Attachments__c attachment :
                [ select id, Document_ID__c from American_Spaces_Notes_and_Attachments__c where Object_ID__c like :x.Id ])
        {
            Attachment d = new Attachment( id=attachment.Document_ID__c );
            docs.add( d );
            infos.add( attachment );
        }
        
        delete( docs );
        delete( infos );
    }
}
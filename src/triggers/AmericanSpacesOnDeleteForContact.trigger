trigger AmericanSpacesOnDeleteForContact on American_Spaces_Contact__c (before delete)
{
    for(American_Spaces_Contact__c X : Trigger.old)
    {
        List<Attachment> docs = new List<Attachment>();
        List<American_Space_Branch__c> branches = new List<American_Space_Branch__c>();
        List<American_Spaces_Statistic__c> statistics = new List<American_Spaces_Statistic__c>();
        List<American_Spaces_Notes_and_Attachments__c> infos = new List<American_Spaces_Notes_and_Attachments__c>();
        
        for (American_Spaces_Notes_and_Attachments__c attachment :
                [ select id, Document_ID__c from American_Spaces_Notes_and_Attachments__c where Object_ID__c like :x.Id ])
        {
            Attachment d = new Attachment( id=attachment.Document_ID__c );
            docs.add( d );
            infos.add( attachment );
        }
        
        for (American_Space_Branch__c branch :
                [ select id from American_Space_Branch__c where Name_of_Space__r.id = :x.Id ])
        {
            branches.add( branch );
        }
        
        for (American_Spaces_Statistic__c statistic :
                [ select id from American_Spaces_Statistic__c where Name_of_Space__r.id = :x.Id ])
        {
            statistics.add( statistic );
        }
        
        delete( docs );
        delete( infos );
        delete( branches );
        delete( statistics );
    }
}
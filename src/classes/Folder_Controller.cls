public class Folder_Controller
{
    private ApexPages.StandardController std;
    public File__c file{ get; set; }
    public Folder__c folder{ get; set; }
    public String comments{ get; set; }
    public List<ContentDoc> availableDoc{ get; set; }
    
    //Filter
    public String fileName{get; set;}
    public String fileType{get; set;}
    public Boolean isNotInFile{get; set;}
    
    public Folder_Controller( ApexPages.StandardController stdCtrl )
    {
         file = (File__c) stdCtrl.getRecord();
        String folderID = ApexPages.currentPage().getParameters().get( 'parentID' );
        folder = [SELECT id, name, status__c, CreatedbyId, LastModifiedById FROM Folder__c WHERE id = :folderID];
    }


    public List<ContentDoc> getAvailableFiles()
    {
        availableDoc = new List<ContentDoc>();
        List<ID> RelatedRecordIds = new List<ID>();
        
        String soql = 'SELECT Title, PublishStatus, OwnerId, LatestPublishedVersionId, LatestPublishedVersion.fileType, LastModifiedDate, ' +
                             'LastModifiedById, IsDeleted, IsArchived, Id, CreatedDate, CreatedById, ArchivedDate, ArchivedById ' +
                        'FROM ContentDocument ';
        
        if (isNotInFile != null && isNotInFile)
        {
            for (File__Feed ff : [SELECT RelatedRecordId FROM File__Feed WHERE Type = 'ContentPost'])
            {
                RelatedRecordIds.add( ff.RelatedRecordId );
            }
            
            soql += 'WHERE id not IN (SELECT ContentDocumentId FROM ContentVersion WHERE id IN :RelatedRecordIds)';
        }
        else
        {
            for (File__Feed ff : getMyFolderFiles())
            {
                RelatedRecordIds.add( ff.RelatedRecordId );
            }
            
            soql += 'WHERE id not IN (SELECT ContentDocumentId FROM ContentVersion WHERE id IN :RelatedRecordIds)';
        }
                
        if (fileName != null)
        {
            String searchName = '%' + fileName + '%';
            soql += 'AND Title like :searchName ';
        }
        if (fileType != null)
        {
            String searchType = '%' + fileType + '%';
            soql += 'AND LatestPublishedVersion.fileType like :searchType ';
        }
        
        soql += 'ORDER BY LastViewedDate DESC';
        
        for(ContentDocument myContent : Database.query( soql ))
        {
            ContentDoc newDoc = new ContentDoc( myContent );
            newDoc.file.Folder__c = folder.id;
            availableDoc.add( newDoc );
        }
        
        return availableDoc;
    }
    
    
    public List<File__Feed> getMyFolderFiles()
    {
        return [SELECT CreatedById, RelatedRecordId, CreatedDate, Id, title, body, Parent.Status__c FROM File__Feed 
                 WHERE ParentId IN (SELECT id FROM File__c WHERE folder__c = :folder.id)
                   AND Type = 'ContentPost'];
    }
    
    public PageReference refresh()
    {
        return null;    
    }
    
    public PageReference saveMe()
    {
        List<FeedItem> newFeeds = new List<FeedItem>();
        List<File__c> newFiles = new List<File__c>();
        
        for (ContentDoc doc : availableDoc)
        {
            if (doc.checked)
            {
                doc.file.File_ID__c = doc.content.LatestPublishedVersionId;
                newFiles.add( doc.file );
            }
        }
        
        insert newFiles;
        
        for (ContentDoc doc : availableDoc)
        {
            if (doc.checked)
            {
                FeedItem newFeed = new FeedItem();
                newFeed.Type = 'ContentPost';
                newFeed.Title = doc.content.title;
                newFeed.RelatedRecordId = doc.content.LatestPublishedVersionId;
                newFeed.body = doc.comments;
                newFeed.ParentId = doc.file.id;
                newFeeds.add( newFeed );
            }
        }
        
        insert newFeeds;
        
        return new PageReference( '/' + folder.id );
    }
    
    
    public class ContentDoc
    {
        public ContentDocument content{ set; get; }
        public boolean checked{ set; get; }
        public String comments{ set; get; }
        public File__c file{ set; get; }
        
        public ContentDoc( ContentDocument content )
        {
            this.content = content;
            this.checked = false;
            this.file = new File__c();
            this.file.name = content.title;
            this.file.status__c = 'Open';
        }
    }
}
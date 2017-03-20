trigger DA_AfterUpdate on Digital_Asset__c (after insert, after update)
{
   for(Digital_Asset__c X : Trigger.new)
   {
      if(X.Publication_Title__c != null)
      {
         DA_TableOfContents.AddAssetTOC(X.Slug_ID__c, X.Publication_Title__c);
      }
   }
}
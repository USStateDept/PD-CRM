trigger DA_BeforeDelete on Digital_Asset__c (before delete) 
{
	Map<Id,String> mapProfileIdToName = new Map<Id,String>();
	for(Profile p: [select Id, Name from Profile])
	{
		mapProfileIdToName.put(p.Id,p.Name);
	}
	
	for(Digital_Asset__c a: trigger.old)
	{
		if (a.Status__c =='Published' || a.Status__c == 'Copy Desk' || a.Status__c == 'Approved Not Published')
		{
			if(mapProfileIdToName.get(UserInfo.getProfileId()) != 'System Administrator' && mapProfileIdToName.get(UserInfo.getProfileId()) != 'Publishing Copy Desk')
				a.addError('<strong><br/><br/>You cannot delete an asset that has the status Published, Copy Desk, or Approved Not Published.<br/>Please contact the help desk for additional assistance.</strong>');
		}
		
		if (a.Status__c =='In Translation')
		{
			if(a.OwnerId != UserInfo.getUserId())
				a.addError('<strong><br/><br/>You cannot delete an asset that you do not own.  Please contact the help desk for additional assistance.</strong>');
		}
			
	}
}
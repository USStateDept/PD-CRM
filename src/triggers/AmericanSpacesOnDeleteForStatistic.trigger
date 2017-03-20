trigger AmericanSpacesOnDeleteForStatistic on American_Spaces_Statistic__c( before delete )
{
	String myPermissionset = GLOBAL_Library.getPermissionset( Userinfo.getName(), 'American_Spaces_Statistic__c' );
	
	for(American_Spaces_Statistic__c x : Trigger.old)
    {
    	if (myPermissionset == 'American Spaces Washington_SITECOM')
    	{
    		if (x.CreatedById != UserInfo.getUserId())
    		{
    			x.adderror( 'You cannot delete this statistic. Please contact American Spaces Washington.' );
    		}
    	}
    }
}
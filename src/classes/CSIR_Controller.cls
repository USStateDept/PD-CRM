public with sharing class CSIR_Controller
{
	public ApexPages.StandardController std{get; set;}
	public Customer_Support_Incident_Report__c incident{get; set;}
	public String myPermissionset{get; set;}
	
	public CSIR_Controller( ApexPages.StandardController stdCtrl )
	{
		std = stdCtrl;
		incident = (Customer_Support_Incident_Report__c) std.getRecord();
		
		myPermissionset = GLOBAL_Library.getPermissionset( UserInfo.getName(), 'Customer_Support_Incident_Report__c' );
	}
}
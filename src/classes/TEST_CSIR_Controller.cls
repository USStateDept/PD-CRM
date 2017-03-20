@isTest	
public class TEST_CSIR_Controller
{
	public static testMethod void testCSIR_Controller()
    {
    	Customer_Support_Incident_Report__c record = new Customer_Support_Incident_Report__c();
    	record.Responsible_Vendor__c = 'test';
    	insert record;
		
		ApexPages.StandardController sc = new ApexPages.StandardController( record );
		CSIR_Controller testObj = new CSIR_Controller( sc );
    }
}
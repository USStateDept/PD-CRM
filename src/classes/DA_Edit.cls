public with sharing class DA_Edit
{
	public DA_Edit(ApexPages.StandardController controller)
	{
		//Do nothing!
	}




	@RemoteAction
	public static Boolean updateFieldValue(Id recordId, String fieldName, Object fieldValue)
	{
		//First let us retrieve the name of the sObject to which this Id is a record of.
		
		String sObjectName = recordId.getSObjectType().getDescribe().getName();
		System.Debug('DEBUG:: sObjectName: ' + sObjectName);
		System.Debug('DEBUG:: fieldName: ' + fieldName);
		System.Debug('DEBUG:: fieldValue: ' + fieldValue);

		//Now retrieve the object and the field with this Id
		String queryString = 'Select Id, ' + String.escapeSingleQuotes(fieldName) + ' From ' + String.escapeSingleQuotes(sObjectName) + ' Where Id = \'' + String.escapeSingleQuotes(recordId) + '\'';
		Sobject record = Database.query(queryString);

		record.put(fieldName, fieldValue);
		update record;		

		return true;
	}
}
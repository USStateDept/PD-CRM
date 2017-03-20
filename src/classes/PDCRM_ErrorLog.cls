global with sharing class PDCRM_ErrorLog {
	
	global static void CreateNewError(String ErrorCode,String ErrorDesc,String Func,String Method,String ProcessName,String WebServiceName, String WebServiceURL){
		Error_Log__c errLog = new Error_Log__c();
		errLog.Error_Code__c = ErrorCode;
		errLog.Error_Description__c = ErrorDesc;
		errLog.Function__c = Func;
		errLog.Method__c = Method;
		errLog.Process_Name__c = ProcessName;
		errLog.WebService__c = WebServiceName;
		errLog.WebServiceURL__c = WebServiceURL;
		insert errLog;		
	}
    
}
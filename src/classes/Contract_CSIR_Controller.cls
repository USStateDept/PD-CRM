public with sharing class Contract_CSIR_Controller {

        public ApexPages.StandardController std{get; set;}
        public Contract_CSIR__c incident{get; set;}
        public String myPermissionset{get; set;}
        
        public Contract_CSIR_Controller( ApexPages.StandardController stdCtrl )
        {
                std = stdCtrl;
                incident = (Contract_CSIR__c) std.getRecord();
                myPermissionset = GLOBAL_Library.getPermissionset( UserInfo.getName(), 'Contract_CSIR__c' );
        }
}
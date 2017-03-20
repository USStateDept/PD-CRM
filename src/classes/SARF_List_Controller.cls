public with sharing class SARF_List_Controller {
    
    // Controller
    public ApexPages.StandardController std {get;set;} // standard Controller
    
    // Constructor
    public SARF_List_Controller(ApexPages.StandardController controller) {
        std = controller;
       	//sarfs = [];
    }
    
    // Empty constructor
    public SARF_List_Controller() {}
    
    // List View search input
    public List<CMS_SARF__c> sarfs {get; set;}    // search results list of records
    public String searchLN {get; set;}            // last name search input
    public String searchFN {get;set;}             // first name search input
    public String searchSARFUserID {get;set;}     // SARF User ID search input
    public String noSarfsFound {get;set;}         // message to display no SARFs found in search
    public Boolean filter {get;set;}              // show/hide table of filtered records
    
    // Clear filter fields and data values for SARF filter/search
    public void clearFilter(){
        searchFN = '';
        searchLN = '';
        searchSarfUserID = '';
        filter = false;
        noSarfsFound = '';
     }
    
    // Filter SARF function
    public void doSearch(){
        searchFN.trim();
        searchLN.trim();
        searchSARFUserID.trim();
        
        // Search excludes SARF
        if(searchSARFUserID.length() < 1){
            // Search only first name
            if(searchFN.length() >0 && searchLN.length() == 0){
            sarfs = [SELECT name, SARF_Name__c, SARF_User_ID__c, Last_Name__c, First_Name__c, Email_Address__c, Phone_Number__c, is_current__c FROM CMS_SARF__c
                    WHERE first_name__c = :searchFN ORDER BY version_number__c DESC];
            }
            // Search only last name
            else if (searchFN.length() == 0 && searchLN.length() > 0){
            sarfs = [SELECT name, SARF_Name__c, SARF_User_ID__c, Last_Name__c, First_Name__c, Email_Address__c, Phone_Number__c, is_current__c FROM CMS_SARF__c
                    WHERE last_name__c = :searchLN ORDER BY version_number__c DESC];
            }
            // Search both first and last name
            else if (SearchFN.length() > 0 && SearchLN.length() > 0){
            sarfs = [SELECT name, SARF_Name__c, SARF_User_ID__c, Last_Name__c, First_Name__c, Email_Address__c, Phone_Number__c, is_current__c FROM CMS_SARF__c
                    WHERE first_name__c = :searchFN AND last_name__c = :searchLN ORDER BY version_number__c DESC];    
            }
        }
        // Search includes SARF ID
        else{
            // Search only first name
            if(searchFN.length() >0 && searchLN.length() == 0){
                sarfs = [SELECT name, SARF_Name__c, SARF_User_ID__c, Last_Name__c, First_Name__c, Email_Address__c, Phone_Number__c, is_current__c FROM CMS_SARF__c
                        WHERE first_name__c = :searchFN AND sarf_user_id__c = :searchSarfUserID ORDER BY version_number__c DESC];
            }
            // Search only last name
            else if (searchFN.length() == 0 && searchLN.length() > 0){
                sarfs = [SELECT name, SARF_Name__c, SARF_User_ID__c, Last_Name__c, First_Name__c, Email_Address__c, Phone_Number__c, is_current__c FROM CMS_SARF__c
                        WHERE last_name__c = :searchLN AND sarf_user_id__c = :searchSarfUserID ORDER BY version_number__c DESC];
            }
            // Search both first and last name
            else if (SearchFN.length() > 0 && SearchLN.length() > 0){
            sarfs = [SELECT name, SARF_Name__c, SARF_User_ID__c, Last_Name__c, First_Name__c, Email_Address__c, Phone_Number__c, is_current__c FROM CMS_SARF__c
                     WHERE first_name__c = :searchFN AND last_name__c = :searchLN AND sarf_user_id__c = :searchSarfUserId ORDER BY version_number__c DESC];    
            }
            // Search only SARF ID
            else if (searchFN.length() == 0 && searchLN.length() == 0){
            sarfs = [SELECT name, SARF_Name__c, SARF_User_ID__c, Last_Name__c, First_Name__c, Email_Address__c, Phone_Number__c, is_current__c FROM CMS_SARF__c
                     WHERE sarf_user_id__c = :searchSARFUserID ORDER BY version_number__c DESC];
            }
        }
        // Display filter
        if(sarfs.size() > 0){
            filter = true;     // show table of filtered records
            noSarfsFound = ''; // clear no SARFs found msg
        }
        else{
            noSarfsFound = 'No records found'; // populate no SARFs found msg
        }
    }

}
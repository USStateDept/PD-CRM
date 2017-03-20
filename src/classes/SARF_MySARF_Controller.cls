public with sharing class SARF_MySARF_Controller {
    
    public CMS_SARF__c mySARF {get; set;}
    public ApexPages.StandardController std {get;set;} // standard Controller
    public Boolean hasCurrentSARF {get; set;}
    public List<CMS_SARF__c> allSARFs {get; set;}

    
    public SARF_MySARF_Controller(ApexPages.StandardController controller) {
        
        std = controller;
        mySarf = (CMS_SARF__c) std.getRecord();
        List<CMS_SARF__c> sarfs = [SELECT id, sarf_name__c, first_name__c, last_name__c, email_address__c, version_number__c, employee_type__c, 
                                    phone_number__c, is_current__c, user_id__c, expiration_date__c, office__c, title__c,
                                    sarf_history__c, permission_sets_default__c, role__c, profileTemp__c, access_comments__c,
                                    permission_sets__c, general_comments__c, date_approved__c, current_time_tracker__c, sarf_user_id__c
            FROM CMS_SARF__c WHERE user_id__c = :Userinfo.getUserId() AND is_current__c = :TRUE LIMIT 1];
        if(sarfs != NULL && sarfs.size() > 0){
            mySARF = sarfs.get(0);
            hasCurrentSARF = true;
        }else{
            hasCurrentSARF = false;
        }
        System.debug('@@@hasCurrentSARF...'+hasCurrentSARF+', mySARF...'+mySARF);
        showAllSARFs();       
    }
    
    public PageReference goToSARF(){
        PageReference pageRef = ApexPages.currentPage();
        return pageRef = new PageReference('/'+mySarf.Id);
    }
    
    public PageReference showAllSARFs(){
        allSarfs = [SELECT id, name, SARF_Name__c, SARF_User_ID__c, Last_Name__c, First_Name__c, Email_Address__c, Phone_Number__c, is_current__c, version_number__c,
                    isPendingApproval__c, sarf_end_date__c, current_time_tracker__c
                    FROM CMS_SARF__c
                    WHERE sarf_user_id__c = :mySarf.sarf_user_id__c ORDER BY version_number__c DESC];
        return null;
    }
   
}
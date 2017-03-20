public class SARF_User_Search_Controller {
    
     // Controller
    public ApexPages.StandardController std {get;set;} // standard Controller
    
     // CMS SARF records
    public CMS_SARF__c sarf {get;set;}            // this record
    
    // Edit Mode User search input
    public String searchULN {get; set;}           // last name search input
    public String searchUFN {get;set;}            // first name search input
    public String noUsersFound {get;set;}         // message to display no Users found in search
    public List<User> existingUsers {get; set;}   // search results list of records
    public User existingUser {get;set;}           // the selected User from the results list to populate the SARF
    public String userid {get;set;}               // id from selected User used to populate the SARF
    public Boolean userFilter {get;set;}          // show table of filtered records
    public Boolean userSelected {get;set;}        // a User has been selected to populate the SARF
    
    // Constructor
    public SARF_User_Search_Controller(ApexPages.StandardController controller) {
        std = controller;
        sarf = (CMS_SARF__c) std.getRecord();
    }

//---------------------------------------------------------------------------------------------------------------------------------------------------------/
//  User Search - SARF NEW                                                                                                                                 /
//---------------------------------------------------------------------------------------------------------------------------------------------------------/

    public void filterUsers(){
        userID = ''; // this ensures UserID field resets if the User searches a User after populating the SARF with another UserID
        searchUFN.trim();
        searchULN.trim();
            // Search only first name
            if(searchUFN.length() >0 && searchULN.length() == 0){
                existingUsers = [SELECT name, id, firstName, lastName, Email, alias, Phone, userroleid, profileid, title, division FROM User
                    WHERE firstName = :searchUFN ORDER BY lastname];
            }
            // Search only last name
            else if (searchUFN.length() == 0 && searchULN.length() > 0){
            existingUsers = [SELECT name, id, firstName, lastName, Email, alias, Phone, userroleid, profileid, title, division FROM User
                    WHERE lastName = :searchULN ORDER BY lastname];
            }
            // Search both first and last name
            else if (SearchUFN.length() > 0 && SearchULN.length() > 0){
            existingUsers = [SELECT name, id, firstName, lastName, Email, alias, Phone, userroleid, profileid, title, division FROM User
                    WHERE lastName = :searchULN and firstName = :searchUFN ORDER BY lastname];    
            }
        // Display filter
        if(existingUsers.size() > 0){
            userFilter = true;
            noUsersFound = '';
        }else{
            noUsersFound = 'No records found';
        }
    }
    
    public void clearUserFilter(){ 
        searchUFN = '';
        searchULN = '';
        userFilter = false;
        noUsersFound = '';
    }
    
    public PageReference populate(){
        List<User> eu = [SELECT name, lastname, firstname, timezonesidkey, email, phone, alias, userroleid, username, profileid, id, title, division FROM User WHERE id = :userid LIMIT 1];
        existingUsers = eu;
        if (eu.size() > 0 && eu != NULL){
            existingUser = eu.get(0);
            sarf.user_type__c = 'Existing User';
            sarf.last_name__c = existingUser.lastname;
            sarf.first_name__c = existingUser.firstname;
            sarf.email_address__c = existingUser.email;
            sarf.phone_number__c = existingUser.phone;
            sarf.user_id__c = existingUser.id;
            sarf.title__c = existingUser.title;
            sarf.office__c = existingUser.division;        
            userFilter = TRUE;
        }
        else{
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Invalid User ID');
            ApexPages.addMessage(myMsg);
            userSelected = false;
        }
        return null;
    }
    
    public void disableTestUsers(){
        List<User> testUsers = [Select name, id, isActive, title FROM User WHERE title = :'TEST_USER'];
        for (User u: testUsers){
            System.debug(u.name + ', ' + u.isActive + ', ' + u.title);
            u.isActive = false;
            update(u);
            System.debug(u.name + ', ' + u.isActive + ', ' + u.title);
        }
    }
}
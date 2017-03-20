public with sharing class SARF_Controller {
    
    public final static String SARF_OVERRIDE = 'SARF Override';
    public final static String AMS_SITE_DOT_COM = 'American Spaces Site.com';
    
    //---------------------------------------------------------------------------------------------------------------------------------------------------------/
    //  Instance Variables                                                                                                                                     /
    //---------------------------------------------------------------------------------------------------------------------------------------------------------/
    
    public String profileID;
    // Controller
    public ApexPages.StandardController std {get;set;} // standard Controller
    
    // CMS SARF records
    public CMS_SARF__c sarf {get;set;}            // this record
    public CMS_SARF__c sarf2 {get;set;}           // newly cloned record
   
    // Boolean values to keep track of the various edit modes for the SARF (Edit vs. Clone, Rejected, etc.)
    public Boolean isEdit {get;set;}              // the record is in Edit state
    public Boolean isUpdate {get;set;}            // the record is in Clone state 
    public Boolean showRejInputBlock {get;set;}   // the comment box allows manager to input comments after rejecting SARF
    public Boolean showRejOutputBlock {get;set;}  // the comment box displays on thz record to show why it was rejected
    public Boolean showMorePS {get;set;}          // the additional permission sets box will display
    public Boolean accessCommentsReq {get;set;}   // field must contain justification for needing additional permission sets            
    public Boolean userUpdated {get;set;}         // value to determine if "Finish" button appears on User update confirmation page
    public Boolean userCreatedPushed {get;set;}   // not sure if this needs to be used                                                  ---check usefulness---
    public Boolean quickApprove {get;set;}        // SARF has been submitted and approved all at once by a manager
    public Boolean showAdditionalAccessLink {get;set;} //Whether show additional access link or not depends on role
    
    // Edit Mode User search input
    public String searchULN {get; set;}           // last name search input
    public String searchUFN {get;set;}            // first name search input
    public String noUsersFound {get;set;}         // message to display no Users found in search
    public List<User> existingUsers {get; set;}   // search results list of records
    public User existingUser {get;set;}           // the selected User from the results list to populate the SARF
    public String userid {get;set;}               // id from selected User used to populate the SARF
    public Boolean userFilter {get;set;}          // show table of filtered records
    public Boolean userSelected {get;set;}        // a User has been selected to populate the SARF 
    public Boolean newVersionExists {get; set;}   // a newer SARF version exists
    public Boolean isCurrentAMSRole {get; set;}   // it is true if current user is an AMS site.com user
    public Boolean isApproved {get;set;}          //it is true if previous sarf approved
    
    // Customer Portal User variables
    public String accountId;
    public Contact c;
    public Id cId;
    public User u;
    public User approvingManager;
    
    // Not used currently or not sure how they are used
    public List<String> defaultPSList {get;set;}  // set after assignment object has been created and assignments have been populated
    public List<SelectOption> extraPSListOptions {get;set;}
    public String profile {get;set;}
    public String myPermissionset {get; set;}     // permission set of currently logged-in user
    public Id myId {get; set;}                            // Id of currently logged-in user
    public String useralias {get;set;}
    //public String psPickValSelected {get; set;} // user-selected values
    public List<String> psSelected {get; set;}
    public String eUserMessage {get; set;}        // mesage about possible existing User
    
    private Map<String,String> tempPsMap = new Map<String,String>();
    private List<PermissionSetAssignment> myExtraApprovingAssignments;      //permission set of backup approving manager
    
    //TEST
    public Set<String> originalvalues = new Set<String>();
    public List<string> leftselected{get;set;}
    public List<string> rightselected{get;set;}
    public Set<string> leftvalues = new Set<string>();
    public Set<string> rightvalues = new Set<string>();
    public String roleSelected {get; set;}
    
    // Our test variable for hidden input javascript value     
    public String myString {get; set;}
    
    //---------------------------------------------------------------------------------------------------------------------------------------------------------/
    //  Constructor                                                                                                                                            /
    //---------------------------------------------------------------------------------------------------------------------------------------------------------/
    
    public SARF_Controller() {}
    
    public SARF_Controller(ApexPages.StandardController controller) {
        isApproved = false;
        PermissionSet ps; 
        myExtraApprovingAssignments = new List<PermissionSetAssignment>();
        // Test for Customer Portal User
        c = new Contact();
        u = new User();
               
        try {
            accountId = [SELECT id, name FROM Account where name = 'American Spaces' LIMIT 1].id; // Id for Organization American Spaces
            profileId = getProfileId(); //Id for Profile Overage Authenticated Website User
        } catch(Exception e) {
            System.debug(LoggingLevel.ERROR, e.getMessage());
        }        
        std = controller;
        sarf = (CMS_SARF__c) std.getRecord();
        myId = UserInfo.getUserId();
        List<PermissionSetAssignment> myAssignments = [SELECT Id, PermissionSet.Name, PermissionSet.Id, AssigneeId
                                                       FROM PermissionSetAssignment
                                                       WHERE AssigneeId = :Userinfo.getUserId()];

        if(myAssignments != NULL && myAssignments.size() > 0){
            // first check to see if someone is a manager
            for (PermissionSetAssignment psa:  myAssignments){
                //System.debug(psa);
                String psName = psa.PermissionSet.Name;
                String approvingPSName = parseApproverPs(psName);
                if(String.isNotEmpty(approvingPSName))
                    myExtraApprovingAssignments.add(psa);                
                
                ps = getPermissionSetByName(psName);
                if(ps != null && ps.Label.equals('SARF Manager')) {
                    myPermissionset = ps.Label;
                }
            }
            // then check to see if user is an override. Must keep this method second because
            // if user has both ps, this is the one we need, as it overrides the manager ps
            for (PermissionSetAssignment psa:  myAssignments){
                ps = getPermissionSetByName(psa.PermissionSet.Name);
                if(ps != null && ps.Label.equals(SARF_OVERRIDE)) {
                    myPermissionset = ps.Label;
                    break;
                }
            }             
        }//end of if myAssignments 
        System.debug('MyPermissionSet: ' + myPermissionSet);       
        leftValues = new Set<String>();
        rightvalues = new Set<String>();        
        if(sarf.version_number__c == NULL){
            sarf.user_type__c = 'New User';
            leftValues.addAll(getOriginalValues());
        }
        else {
            String currentPermissionSets = sarf.Permission_Sets__c;
            // Need to parse the existing addtional permission sets list with delimiter ';' and add them to the Set
            if(currentPermissionSets != NULL){
                List<String> existingAddPsList = currentPermissionSets.trim().split(';');
                rightValues.addAll(existingAddPsList);
            }
            // Loop thru the original list of ps and check if any permission set exists in the rightValues,
            // then adding to the leftValues.
            // Only check the rightValues list if it contains additional permission sets
            if(!rightValues.isEmpty()) {
                for(String originalPs : getOriginalValues()) {
                    if(!rightvalues.contains(originalPs)) {
                        leftvalues.add(originalPs);
                    }
                }
            }
            else {
                leftValues.addAll(getOriginalValues());
            }
        }

        //Set up a temporary permission sets to map values from selected role
        //with additional access list(left side)
        tempPsMap.put('Enable SMS-based identity confirmation', 'Enable SMS-based Identity Confirmation');
        tempPsMap.put('American Spaces Washington', 'American Spaces-Washington');
        tempPsMap.put('American Spaces Site Com', 'American Spaces Site.com');
        
        isEdit = false; // a new SARF is not considered edit
        isUpdate = false; // is not a clone
        showRejInputBlock = false; // do not display rejection comment input
        quickApprove = false; // default to non-approving manager, req save first
        
        newVersionExists = hasNewVersion();  
    }
    
    public CMS_SARF__c getSARF(){
        return sarf;
    }
    
    public Boolean hasNewVersion(){
        boolean newVersionExists = false;
        isCurrentAMSRole = false;
        // Retrieve CURRENT SARF
        List<CMS_SARF__c> curr = [SELECT id, sarf_user_id__c, email_address__c, version_number__c, is_current__c, isApproved__c, Role__c
                                  FROM CMS_SARF__c
                                  WHERE email_address__c = :sarf.Email_Address__c 
                                  AND sarf_user_id__c = :sarf.SARF_User_ID__c
                                  AND is_current__c = :true LIMIT 1];
        // If there is a CURRENT SARF, query to see if a newer one exists
        if(curr.size() == 1){
            CMS_SARF__c currentSarf = curr.get(0);
            if(currentSarf.Role__c.equalsIgnoreCase(AMS_SITE_DOT_COM))
                isCurrentAMSRole = true;
            isApproved = currentSarf.isApproved__c;
            
            List<CMS_SARF__c> newest = [SELECT id, sarf_user_id__c, email_address__c, version_number__c, is_current__c
                                        FROM CMS_SARF__c
                                        WHERE sarf_user_id__c = :curr.get(0).sarf_user_id__c
                                        AND is_current__c = :false
                                        AND version_number__c = :curr.get(0).version_number__c + 1 LIMIT 1];
            
            if(newest.size() ==1){
                newVersionExists = true;
            }else
                newVersionExists = false;
        }
        return newVersionExists;
    }
    
    //---------------------------------------------------------------------
    // Methods for Customer Portal User
    // --------------------------------------------------------------------
    
    // Create the Contact that will be associated with portal user
    public Id createContact(Id acctId){
        c.accountId = acctId;
        c.email = sarf.email_address__c;
        c.firstName = sarf.first_name__c;
        c.lastName = sarf.last_name__c;
        insert c;
        return c.id;
    }
    
    // This method should be invoked with VF page button "Create Portal User"
    public PageReference createPortalUser(){
        //Create the Contact associated to the previously created Contact
        Id contactId = createContact(accountId);
        profileId = getProfileId();
        SARF_Controller.createUser(contactId, c.email, c.FirstName, c.LastName, profileId, sarf.Id);
        
        return Page.SARF_Confirm_Portal_User;
    }
    
/**
* 
* This function will generate an email with an user login and a temporary password
* when user is created successfully for American Spaces site.com
* 
**/ 
    public static void portalUserLoginEmail(Id userId)
    {      
        String url;
        String body;
        String emailTemplate;
        String subject;
        User u = new User();        
        if(userId != null) {
            List<User> users = [SELECT id, email, name, username, Contact.account.id FROM User WHERE id = :userId];
            if(users != null && users.size() > 0) {
                u = users.get(0);
            }
        }        
        ID accountID = u.contact.account.id;        
        System.ResetPasswordResult newPassword = System.resetPassword(u.ID, false);        
        try
        {
            url = [select Website from Account where id = :accountID].website;
            body = [SELECT body FROM Note WHERE ParentId = :accountID and Title = 'Email'].body;
            emailTemplate = [SELECT body FROM Note WHERE ParentId = :accountID and Title = 'EmailTemplate'].body;
            subject = [SELECT body FROM Note WHERE ParentId = :accountID and Title = 'Subject'].body;
        }
        catch (Exception e)
        {
            System.debug(LoggingLevel.ERROR, e.getMessage());
        }
        
        if (subject == null || subject.length() == 0)
        {
            subject = 'DO NOT REPLY: Your new Salesforce Login and Password';
        }
        
        String emailBody = '';
        
        if (body != null && body.length() > 0)
        {
            emailBody = body;
            emailBody = emailBody.replace( '{username}', u.name );
            emailBody = emailBody.replace( '{userid}', u.Username );
            emailBOdy = emailBody.replace( '{password}', newPassword.getPassword() );
        }
        else
        {
            emailBody += 'Hello ' + u.name + ',<br/><br/>';
            emailBody += 'This e-mail contains your access information for the Salesforce system. Your user name and temporary password are below:<br/><br/>';
            emailBody += 'User name: ' + u.username + '<br/>';
            emailBody += 'Temporary password: ' + newPassword.getPassword() + '<br/><br/>';
            emailBody += 'Please navigate to <a href="' + url + '">Link</a> and login with the credentials below.  Make sure to change your password as soon as possible.<br/><br/>';
            emailBody += 'Remember to maintain proper security when dealing with Logins and Passwords:<br/>';
            emailBody += '   -Never share a login and password with anyone.<br/>';
            emailBody += '   -Never provide login and password information when submitting a help ticket. ';
            emailBody += 'Many people have access to the help ticket system, and by e-mailing a login and password to this address, ';
            emailBody += 'the user is broadcasting this sensitive information to many people. We can assist you without compromising your password.<br/><br/>';
            emailBody += 'If you experience any issues logging in to the system or changing your password,';
            emailBody += ' please contact our help desk at embassy-help@getusinfo.com and a team member will assist you during Washington, DC business hours.<br/><br/>';
            emailBody += 'Thank you.';
        }
        
        if (emailTemplate != null && emailTemplate.length() > 0)
        {
            SYstem.debug( 'came here1' + emailTemplate );
            GLOBAL_Library.sendEmail( u.email, emailTemplate, subject, emailBody );
        }
        else
        {
            System.debug( 'came here2' );
            GLOBAL_Library.sendEmail( u.email, 'HTML Email Queue', subject, emailBody );
        }
    }
    
    @future static void createUser(String contactId, String email, String firstName, String lastName, String profileId, String sarfId) {        
        System.debug('@future static method createUser entered!');
        String userTitle;
        
        try {
            CMS_SARF__c newSarf = [SELECT id, title__c FROM CMS_SARF__c WHERE id = :sarfId];
            userTitle = newSarf.Title__c;
        } catch(Exception e) {
            System.debug(LoggingLevel.ERROR, e.getMessage());
        }
        
        User u = new User();
        u.ContactId = contactId;
        u.email = email;
        u.firstName = firstName;
        u.lastName = lastName;
        u.profileId = profileId;
        u.emailencodingkey='UTF-8';
        u.languagelocalekey='en_US';
        u.localesidkey='en_US';
        u.timezonesidkey='America/Los_Angeles';
        u.title = userTitle;
        //Set unique values with random appended numbers
        SARF_unique_ID_Generator rc = new SARF_unique_ID_Generator();
        String[] splitList = email.split('@',0);
        String tempUN = splitList[0];  // first half
        String tempUN2 = splitList[1]; // second half
        if(tempUN != NULL){
            System.debug(tempUN);
            tempUN = rc.queryUsername(tempUN, tempUn2);
        }
        u.username = tempUn + '@' + tempUN2;
        //Need to create a method that checks for unique alias and modifies if necessary
        String temp = ''; // temp will get a standard value and then pass it to the alias generator for final unique alias creation
        if(u.lastname.length() > 4){
            temp = u.lastname.substring(0,4) + u.firstname.substring(0,1);
        }else{
            temp = u.lastname + u.firstname.substring(0,1);
        }
        temp = rc.queryAlias(temp);
        u.Alias = temp;
        u.CommunityNickname = temp; // set to same as alias

        insert u;
        
        //Update SARF with user id was just created
        confirmPortalUser(sarfId);
        
        // resetPassword(u);
        //System.resetPassword(u.Id, true);
        portalUserLoginEmail(u.Id);
    }
    
    //---------------------------------------------------------------------------------------------------------------------------------------------------------/
    // MULTIPICKLIST PERMISSION SETS                                                                                        
    //---------------------------------------------------------------------------------------------------------------------------------------------------------/
    
    // Method for testing a hidden field functionality 
    public PageReference myMethod(){
        System.debug('myString: ' + myString);
        return null;
    }
    
    public PageReference selectclick(){
        rightselected.clear();
        for(String s : leftselected){
            leftvalues.remove(s);
            rightvalues.add(s);
        }
        return null;
    }
    
    public PageReference unselectclick(){
        leftselected.clear();
        for(String s : rightselected){
            rightvalues.remove(s);
            leftvalues.add(s);
        }
        return null;
    }
    
    public List<SelectOption> getunSelectedValues(){
        List<SelectOption> options = new List<SelectOption>();
        List<string> tempList = new List<String>();
        tempList.addAll(leftvalues);
        tempList.sort();
        for(string s : tempList)
            options.add(new SelectOption(s,s));
        return options;
    }
    
    public List<SelectOption> getSelectedValues(){
        List<SelectOption> options1 = new List<SelectOption>();
        List<string> tempList = new List<String>();        
        tempList.addAll(rightvalues);
        tempList.sort();
        for(String s : tempList)
            options1.add(new SelectOption(s,s));
        return options1;
    }
    
    // Query available permission sets and add to the list
    public Set<String> getOriginalValues() {
        originalValues = new Set<String>();

        Schema.DescribeFieldResult fieldResult = CMS_SARF__c.Permission_Sets__c.getDescribe();
        if(fieldResult != null) { 
            List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();  
            for(Schema.PicklistEntry f : ple){
                if(f.getValue() != 'American Spaces-Washington Site.com'){
                    originalValues.add(f.getValue());
                }
            }
        }
        
        return originalValues;
    }
    
    //---------------------------------------------------------------------------------------------------------------------------------------------------------/
    //  SAVE and EDIT Methods                                                                                                                                  /
    //---------------------------------------------------------------------------------------------------------------------------------------------------------/
    
    // NOT IMPLEMENTED YET
    /*public void setManager(){
        // Capture Role
        String roleSelected = sarf.role__c;
        System.debug('Selected role: ' + roleSelected);
        Schema.DescribeFieldResult fieldResult = CMS_SARF__c.APproving_Manager__c.getDescribe();
        if(fieldResult != null){
            List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues(); 
            for(Schema.PicklistEntry f : ple){
                //if value is valid for CMS_SARF__c.Role__c value
            }
        }
    }*/
    
    // Field validation - set error and display on page if missing exp date or access comments
    public Boolean isValidated(){
        Boolean validated = false;
        System.debug(sarf.Permission_Sets__c + '   comments: ' + sarf.access_comments__c);
        if(sarf.employee_type__c == 'Temporary' && sarf.expiration_date__c == NULL){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'A temporary employee must have an expiration date');
            ApexPages.addMessage(myMsg);
        }
        else if(sarf.permission_sets__c != '' && (sarf.access_comments__c == '' || sarf.access_comments__c == NULL)){
            
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'You must provide a value for access comments');
            ApexPages.addMessage(myMsg);
        }
        else{
            validated = true;
        }
        return validated;
    }    
    
    public boolean duplicateEmailPermitted(CMS_SARF__c dupSARF){
        System.debug(dupSARF.role__c + ' ' + dupSARF.sarf_user_id__c);
        boolean permitted = true;
        List<CMS_SARF__c> duplicates = new List<CMS_SARF__c>();
        duplicates.add(dupSARF);
        duplicates.add(sarf);
        for(CMS_SARF__c s: duplicates){
            //System.debug(s.first_name__c + ' ' + s.role__c + ' ' + s.email_address__c);
            System.debug(s.first_name__c + ' ' + s.email_address__c);
        }
        return permitted;
    }
    
    // SAVE initial SARF
    public PageReference saveInitialSARF(){
        isCurrentAMSRole = false;
        PageReference pageRef = ApexPages.currentPage();
        String str = ''; // default value for additional permission sets field
        //First check to see if a SARF with the same UserID exists
        List<CMS_SARF__c> sarfList = [SELECT name,  SARF_Name__c, first_name__c, last_name__c, email_address__c, sarf_user_id__c, is_current__c, sarf_history__c, profileTemp__c, permission_sets__c, user_type__c, 
                                      salesforce_user__c, role__c
                                      FROM CMS_SARF__c WHERE email_address__c = :sarf.email_address__c LIMIT 1];
                                      
        if(sarfList.size() == 0 || (sarfList.size() == 1 && duplicateEmailPermitted(sarfList.get(0)))){
            //if(isValidated()){
            // There is currently no SARF with the provided email address
            // generate SARF User Id
            SARF_unique_ID_Generator rc = new SARF_unique_ID_Generator(sarf); 
            rc.generateRandomNumber();
            rc.queryRandomNumbers();
            // assign access
            SARF_Access_Assignment newAssignment = new SARF_Access_Assignment(sarf);
            newAssignment.assignProfile();
            newAssignment.setProfileAndPS(newAssignment.getProfile());
            // validate existing user, and add user ID to SARF record
            if(sarf.user_type__c == 'Existing User'){
                List<User> existingUsers = [SELECT id, name, email, userType FROM User WHERE id = :sarf.user_id__c];
                System.debug(existingUsers);
                if(existingUsers != NULL && existingUsers.size() == 1){
                    User existingU = existingUsers.get(0);
                    System.debug(existingU);
                    if(String.isNotEmpty(existingU.UserType) && existingU.UserType.equals('CspLitePortal')) {
                        isCurrentAMSRole = true;
                    }
                    String validationMsg = amsRoleValidation(sarf);
                    if(String.isNotEmpty(validationMsg)) {
                        ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,validationMsg);
                        ApexPages.addMessage(myMsg);
                        return pageRef;                        
                    }
                }
                else if(existingUsers == NULL && existingUsers.size() == 0){
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'You have selected Existing User, but no User is found with the email address provided');
                    ApexPages.addMessage(myMsg);
                }else{
                    // Code to write here to account for a User with an email address that exists on multiple Users
                    System.debug(existingUsers);
                }
            }
            //Selected additional permission sets
            if(!rightvalues.isEmpty()){
                for(String s: rightvalues){
                    str += s + ';';
                }
            }
            sarf.permission_sets__c = str; // set additional access ps
            // Check to see if "approver" is included in any permission sets. If so, add SARF Manager as well
            if(sarf.permission_sets__c.contains('Approve') || sarf.Permission_Sets__c.contains('approver')){
                str += '\nSARF Manager';
                sarf.permission_sets__c = str;
            }
            sarf.is_rejected__c = false; // SARF is not rejected at this point
            
            if(myPermissionset != null && myPermissionset.endsWithIgnoreCase(SARF_OVERRIDE))
            { 
                //If current user has an override permission who is trying to approve
                //a SARF on behalf of an approving manager is not available at this time,
                //needs to look up an approving manager in the associated roles list. 
                approvingManager = getApprovingManagerBySelectedRole(sarf.Role__c); 
            }       
            
            //If current user doesn't have 'SARF Override' permission set should go here
            if(approvingManager == null) {
                approvingManager = getApprovingManagerBySelectedRole(sarf.Role__c);
            }
            
            if(approvingManager != null)
                sarf.Manager__c = approvingManager.Id;
            
            if(isValidated()){ // test code here
                insert sarf; // a trigger will fire to create the SARF name and version number
                isEdit = true; // SARF can still be edited at this point (until submitted for approval)
                pageRef = new PageReference('/'+sarf.Id);
            }
        }
        else{//else there is already a SARF with the provided email address
            
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'A SARF with this email address already exists - SARF User ID: ' + sarfList.get(0).sarf_user_id__c);
            ApexPages.addMessage(myMsg);
        }
        return pageRef;
    }
    
    // Standard SAVE -- Overrides built-in standard Save()
    public PageReference save(){
        //TEST CODE
        PageReference pageRef = ApexPages.currentPage();
        SARF_Access_Assignment newAssignment = new SARF_Access_Assignment(sarf);
        newAssignment.assignProfile();
        newAssignment.setProfileAndPS(newAssignment.getProfile());
        defaultPSList = newAssignment.getPS();
        System.debug(sarf.expiration_date__c);
        Date tempDate = sarf.expiration_date__c;
        System.debug('tempDate: ' + tempDate);
        userUpdated = false;
        sarf.is_rejected__c = false;
        String str = '';        
        if(!rightvalues.isEmpty()){
            for(String s: rightvalues){
                str += s + ';';
            }
        }
        sarf.permission_sets__c = str;
        if (str == ''){
            sarf.Access_Comments__c = '';
        }
        
        if(hasNewVersion() || (sarf.Version_Number__c == 1)) {
            String msg = amsRoleValidation(sarf);
            if(String.isNotEmpty(msg)) {
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, msg);
                ApexPages.addMessage(myMsg);
                return pageRef;
            }
        }
        
        if(myPermissionset != null && myPermissionset.endsWithIgnoreCase(SARF_OVERRIDE))
        { 
            //If current user has an override permission who is trying to approve
            //a SARF on behalf of an approving manager is not available at this time,
            //needs to look up an approving manager in the associated roles list. 
            approvingManager = getApprovingManagerBySelectedRole(sarf.Role__c); 
        }
        
        //If current user doesn't have 'SARF Override' permission set should go here
        if(approvingManager == null) {
            approvingManager = getApprovingManagerBySelectedRole(sarf.Role__c);
        }
        
        if(approvingManager != null)
            sarf.Manager__c = approvingManager.Id;
        
        update(sarf);        
        if(sarf.expiration_date__c == NULL && sarf.employee_type__c == 'Temporary'){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'A temporary employee must have an expiration date');
            ApexPages.addMessage(myMsg);
        }else if(sarf.Permission_Sets__c != '' && sarf.access_comments__c == ''){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'You must provide a value for access comments');
            ApexPages.addMessage(myMsg);
        }else{
            pageRef = new PageReference('/'+sarf.Id);
        }        
        return pageRef;
    }
    
    public boolean confirmNewUser(){
        return true;
    }
    
    // EDIT has two different scenarios---
    /* 1|"Edit" the SARF contents before it has been submitted for approval*/
    public PageReference editSARF(){
        if (sarf.SARF_Rejection_Comments__c != NULL){
            showRejOutputBlock = true;
        }
        
        //savedDate = sarf.expiration_date__c;
        isEdit = true;
        return Page.SARF_new;
    }
    
    /* 2|"Update SARF" creates a new record based on a clone of the current SARF*/
    public PageReference cloneSARF(){
        isCurrentAMSRole = false;
        
        System.debug(sarf.sarf_name__c);
        PageReference pageRef = ApexPages.currentPage();
        List<CMS_SARF__c> sarfList = [SELECT name, createdDate, SARF_Name__c, first_name__c, last_name__c, email_address__c, sarf_user_id__c, is_current__c, sarf_history__c, role__c, permission_sets_default__c, profileTemp__c, permission_sets__c
                                      FROM CMS_SARF__c
                                      WHERE version_number__c= :(sarf.version_number__c + 1) AND sarf_user_id__c = :sarf.sarf_user_id__c LIMIT 1];
        if(sarfList.size() == 0){
            isUpdate = true; // sets the state to clone (new record)
            isEdit = false;  // disables standard edit mode (existing record)
            showRejInputBlock = false; // do not allow rejection comments input
            showRejOutputBlock = false; // do not show rejection comments
            sarf.user_type__c = 'existing user';
            // Query original record to get permission sets
            CMS_SARF__c original = [SELECT name, createdDate, SARF_Name__c, first_name__c, last_name__c, email_address__c, is_current__c, role__c, sarf_history__c, profileTemp__c,permission_sets_default__c, permission_sets__c FROM CMS_SARF__c
                                    WHERE id= :sarf.id ORDER BY LastModifiedDate DESC LIMIT 1];
            // Set the permission sets on this SARF                       
            if(original != null){
                sarf.permission_sets__c = original.permission_sets__c;
            }
            
            
            //Set roles readonly to true for current AMS site.com users to prevent updating 
            //current sarf to salesforce user. 
            String currentSarfRole = sarf.Role__c;
            if(String.isNotEmpty(currentSarfRole) &&
               currentSarfRole.equalsIgnoreCase(AMS_SITE_DOT_COM))
                isCurrentAMSRole = true;
            
            isApproved = sarf.isApproved__c;
            
            pageRef = Page.SARF_new;
        }else{
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'An updated SARF has already been created!');
            ApexPages.addMessage(myMsg);
        }
        return pageRef;
    }
    
    // SAVE CLONE as a new SARF and reset the status fields
    public PageReference saveNew(){
        PageReference pageRef = ApexPages.currentPage();
        isEdit = false;
        showRejInputBlock = false;
        showRejOutputBlock = false;
        String str = '';
        
        sarf2 = sarf.clone();  // Create new SARF as clone
        sarf2.isPendingApproval__c = false;
        sarf2.isApproved__c = false;
        sarf2.is_rejected__c = false;
        sarf2.is_current__c = false;
        sarf2.date_submitted__c = NULL;
        sarf2.date_approved__c = NULL;
        sarf2.current_time_tracker__c = NULL;
        sarf2.user_updated__c = FALSE;
        //sarf2.ownerId = sarf.User_ID__c; // set owner of SARF to User on SARF
        SARF_Access_Assignment newAssignment = new SARF_Access_Assignment(sarf2);
        newAssignment.assignProfile();
        newAssignment.setProfileAndPS(newAssignment.getProfile());
        defaultPSList = newAssignment.getPS();
        
        if(sarf2.expiration_date__c == NULL && sarf2.employee_type__c == 'Temporary'){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'A temporary employee must have an expiration date');
            ApexPages.addMessage(myMsg);
        }
        else{
            if(!rightvalues.isEmpty()){
                for(String s: rightvalues){
                    str += s + ';';
                }
            }
            sarf2.permission_sets__c = str;
            // Check to see if "approver" is included in any additional permission sets. If so, add SARF Manager as well
            if(sarf2.permission_sets__c.contains('Approve') || sarf2.Permission_Sets__c.contains('approver')){
                str += '\nSARF Manager';
                if(!sarf2.Permission_Sets__c.contains('SARF Manager'))
                    sarf2.permission_sets__c = str;
            }
            
            if(myPermissionset != null && myPermissionset.endsWithIgnoreCase(SARF_OVERRIDE))
            { 
                //If current user has an override permission who is trying to approve
                //a SARF on behalf of an approving manager is not available at this time,
                //needs to look up an approving manager in the associated roles list. 
                approvingManager = getApprovingManagerBySelectedRole(sarf2.Role__c); 
            }
            
            //If current user doesn't have 'SARF Override' permission set should go here
            if(approvingManager == null) {
                approvingManager = getApprovingManagerBySelectedRole(sarf.Role__c);
            }
            
            if(approvingManager != null)
                sarf2.Manager__c = approvingManager.Id;
            
            String msg = amsRoleValidation(sarf2);
            if(String.isNotEmpty(msg)) {
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, msg);
                ApexPages.addMessage(myMsg);  
                return pageRef;
            }
            
            System.debug('Updated SARF ps when empty: ' + str);
            System.debug('access comments: ' + sarf2.access_comments__c);
            boolean test = false;
            if(sarf2.Permission_Sets__c != '' && sarf2.access_comments__c == ''){
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'You must provide a value for access comments');
                ApexPages.addMessage(myMsg);
                test = true;
            }
            if(test == false){
                if(sarf2.permission_sets__c == '' && sarf2.access_comments__c != ''){
                    sarf2.access_comments__c = '';
                }
                insert sarf2; // Insert new clone of SARF
                pageRef = new PageReference('/'+sarf2.Id); // Redirect to the new cloned record view page 
            }
        }
        return pageRef;
    }
    
    // REQUEST APPROVAL sets the pending approval status, date submitted, and current time tracker
    public PageReference requestApproval(){
        // if SARF has not already been submitted by user
        if(sarf.isPendingApproval__c == false && sarf.isApproved__c == false){
            sarf.is_rejected__c = false;
            if(!quickApprove){
                sarf.isPendingApproval__c = true;
            }
            sarf.Date_Submitted__c = DateTime.now();
            //sarf.current_time_tracker__c = DateTime.now();
            sarf.SARF_Rejection_Comments__c = NULL;
            sarf.ownerId = UserInfo.getUserId();

            if(!String.isEmpty(sarf.Manager__c) && sarf.isPendingApproval__c && !sarf.Non_state_gov_email__c) {
                SARF_EmailHandler emailHandler = new SARF_EmailHandler(sarf, getCurrentUrl(sarf));
                emailHandler.sendEmail();
            }
            
            update(sarf); // update record
        }
        // else (should never reach here because the button is hidden once it has been submitted, but just in case someone changes the button settings)
        else{
            if(sarf.isPendingApproval__c == true){
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'This SARF has already been submitted for approval.');
                ApexPages.addMessage(myMsg);
            }else{
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'This SARF has already been approved.');
                ApexPages.addMessage(myMsg);
            } 
        }
        isEdit = false; // SARF can no longer can be edited, any edit/save at this point will be for a clone (new version of the SARF)
        showRejInputBlock = false;
        showRejOutputBlock = false;
        return new PageReference('/'+sarf.Id);
    }
    
    // APPROVE is clicked
    public PageReference approve(){
        //Users who can approve SARF: Anyone with SARF Override, Approving Manager, anyone with Approver PS for the given Role
        PageReference pageRef = apexPages.currentPage();
        Boolean isCurrentUser = false; // is the current logged in User the person on the SARF?
        Boolean userHasApprovalPS = false; // does the current logged in User have the correct approver ps for the role on the SARF?
        Boolean isApprovingManager = false;
        String aRole = sarf.role__c;
        String matchingApproverPS = (aRole + ' Approver').replaceAll(' ', '_');        
        if(matchingApproverPS.contains('.'))
            matchingApproverPS = matchingApproverPS.replace('.', '_');
        
        List<PermissionSetAssignment> newPermissionSetAccess = new List<PermissionSetAssignment>(); //list for new permission sets

        // Current permission sets of User who clicks Approve
        List<PermissionSetAssignment> myAssignments = [SELECT Id, PermissionSet.Name, PermissionSet.Id, AssigneeId
                                                       FROM PermissionSetAssignment
                                                       WHERE AssigneeId = :UserInfo.getUserId()];
        // If current user has permission sets (should always be true)
        if(myAssignments != NULL && myAssignments.size() > 0){
            // Check to see if the logged in User has approver permission set for the role
            for (PermissionSetAssignment psa:  myAssignments){
                if(psa.PermissionSet.name.equalsIgnoreCase(matchingApproverPS)){
                    userhasApprovalPS = true;
                    System.debug('User has approver ps: ' + userhasApprovalPs);
                }
            }
        }
        
        //Check if current user is Approving Manager (sarf.Manager__c should already be set to the correct 'Aproving FTE Manager')
        if(UserInfo.getUserId().equals(sarf.manager__c)){
            isApprovingManager = true;
        }
        
        // Check if currnet User is the same as User on SARF
        if(UserInfo.getUserId().equals(sarf.User_ID__c)) {
               isCurrentUser = true;
        }
        
        // If the user has the appropriate approver permission set for the role on sarf
        if((userHasApprovalPS || isApprovingManager || myPermissionSet == SARF_OVERRIDE) && isCurrentUser == false){
            
        // If SARF is not already approved
        if(sarf.isApproved__c == false){               
            sarf.isApproved__c = true;
            sarf.isPendingApproval__c = false;
            sarf.current_Time_Tracker__c = DateTime.now();
            sarf.date_approved__c = DateTime.now();
            sarf.is_Current__c = true;
            
            // If this is after version 1 for this user, query the previous SARF and reset/update fields on that record
            if(sarf.version_number__c >1){
                //Add try/catch block to avoid an exception is thrown when there is no row resturns
                try {
                    CMS_SARF__c previous = [SELECT name, createdDate, SARF_Name__c, first_name__c, last_name__c, phone_number__c, time_zone__c, employee_type__c, 
                                            expiration_date__c, title__c, office__c, manager__c, email_address__c, is_current__c, sarf_history__c, role__c, 
                                            permission_sets_default__c, profileTemp__c, permission_sets__c 
                                            FROM CMS_SARF__c 
                                            WHERE sarf_user_id__c = :sarf.sarf_user_id__c AND version_number__c = :sarf.version_number__c-1 LIMIT 1];
                    if(previous != null){
                        //Gather information from previous record to pull into the history field
                        SARF_History history = new SARF_History(previous, sarf);
                        history.createHistory();
                        sarf.SARF_history__c = history.getHistory();
                        previous.is_Current__c = false;
                        previous.current_time_tracker__c = NULL;
                        previous.Is_Deactivated__c = false; // TEST CODE
                        previous.SARF_End_Date__c = Datetime.now();
                        update previous;
                    }
                } catch(Exception e) {
                    System.debug(LoggingLevel.ERROR, e.getMessage());
                }
                
            }
            update(sarf); // update record
        }
        }else{
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'You do not have authorization to approve this SARF.');
            ApexPages.addMessage(myMsg);
        }
        return PageRef;
    }
    
    // FTE Project Managers can see the button for this function, and it bypasses the secondary approval process
    public PageReference submitAndApprove(){
        PageReference pageRef = apexPages.currentPage();
        if (sarf.Role__c == NULL || sarf.role__c == ''){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'You must select a Role before approving the SARF');
            ApexPages.addMessage(myMsg);
        }else{
            quickApprove = true;
            
            if(sarf.user_type__c == 'Existing User'){ // if User already exists, direct to page where Mgr confirms access update
                sarf.user_updated__c = false;
            }
            requestApproval();
            approve();
        }
        return pageRef;
    }
    
    // VALIDATE updates the current time tracker and is used for audit purposes
    public PageReference validate(){
        PageReference pageRef = apexPages.currentPage();
        sarf.current_Time_Tracker__c = DateTime.now();
        update(sarf);
        return pageRef;        
    }
    
    // DEACTIVATE User
    public PageReference deactivateUser(){
        PageReference pageRef = ApexPages.CurrentPage();       
        List<PermissionSetAssignment> newPermissionSetAccess = new List<PermissionSetAssignment>(); //list for new permission sets
        // check to see if current logged in user has user_manager permission set
        List<PermissionSetAssignment> myAssignments = [SELECT Id, PermissionSet.Name, PermissionSet.Id, AssigneeId
                                                       FROM PermissionSetAssignment
                                                       WHERE AssigneeId = :UserInfo.getUserId()];
        Boolean isUserManager = false;
        Boolean isApprovingManager = false;
        Boolean userCanDeactivate = false;
        Boolean isCurrentUser = false;
        String aRole = sarf.role__c;
        String matchingApproverPS = (aRole + ' Approver').replaceAll(' ', '_');          
        if(matchingApproverPS.contains('.'))
            matchingApproverPS = matchingApproverPS.replace('.', '_');
        
        if(myAssignments != NULL && myAssignments.size() > 0){
            // Check to see if the logged in User has approver permission set for the role
            for (PermissionSetAssignment psa:  myAssignments){
                if(psa.PermissionSet.name.equalsIgnoreCase(matchingApproverPS)){
                    userCanDeactivate = true;
                }
            }
        }
        
        //Check if current user is Approving Manager (sarf.Manager__c should already be set to the correct 'Aproving FTE Manager')
        if(UserInfo.getUserId().equals(sarf.manager__c)){
            isApprovingManager = true;
        }
        
        // Check if currnet User is the same as User on SARF
        if(UserInfo.getUserId().equals(sarf.User_ID__c)) {
            isCurrentUser = true;
        }
        
        if((userCanDeactivate || isApprovingManager || myPermissionset.equals(SARF_OVERRIDE)) && !isCurrentUser){
            
            // Check to see if the logged in User has User_Manager permission set
            for (PermissionSetAssignment psa:  myAssignments){
                if(psa.PermissionSet.Id == '0PSa00000008QAUGA2'){
                    isUserManager = true;
                }
            }
            // If not, create new PermissionSetAssignment for this user to include the user_manager permission set with id 0PSa00000008QAUGA2
            if(isUserManager == false){                               
                PermissionSetAssignment newPSA = new PermissionSetAssignment(); //PermissionSetAssignment sobject
                newPSA.PermissionSetId = '0PSa00000008QAUGA2'; //set the permission set Id
                newPSA.AssigneeId = UserInfo.getUserId(); //set the User Id
                newPermissionSetAccess.add(newPSA); //add the record to our list
                // insert permissionsetassignment
                if(!newPermissionSetAccess.isEmpty()){
                    insert newPermissionSetAccess;
                }
            }
            
            User u = [Select name, id, isActive FROM User WHERE id = :sarf.user_ID__c LIMIT 1];
            if (u != NULL){
                u.isActive = false;
                update(u);
                System.debug(u.name + ', ' + u.isActive);
            }        
            // Remove the User_Manager permission set from the logged in user
            delete newPermissionSetAccess;
            pageRef = Page.SARF_Confirm_Deactivation;
        }
        else{
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'You are not authorized to deactivate this User.');
            ApexPages.addMessage(myMsg);
        }
        //}
        return pageRef;
    }
    
    // UPDATE SARF to show deactivated
    public PageReference confirmDeactivation(){
        sarf.is_deactivated__c = true;
        sarf.ownerId = UserInfo.getUserId();
        update(sarf);
        return Page.SARF_Default_List_View; 
    }
    
    // Return to SARF detail page, do not deactivate User
    public PageReference cancelDeactivation(){
        PageReference pageRef = new PageReference('/'+sarf.Id);
        return pageRef;       
    }
    
   
    
    //---------------------------------------------------------------------------------------------------------------------------------------------------------/
    //  SARF Rejection Comments                                                                                                                                /
    //---------------------------------------------------------------------------------------------------------------------------------------------------------/
    
    // REJECT is selected by FTE manager and will set the SARF back to edit mode and set pending status to false
    public PageReference reject(){
        PageReference pageRef = apexPages.currentPage();
        sarf.is_rejected__c = true;
        sarf.isPendingApproval__c = false; // no longer pending, has been rejected
        isEdit = true;                     // set form to edit mode
        showRejInputBlock = true;          // show input text box for comments
        showRejOutputBlock = false;        // hide output text
        return pageRef;
    }
    
    // SAVE REJECTION COMMENTS and return to standard detail page view
    public PageReference addRejectionComments(){
        showRejInputBlock = false; // hide input text area
        showRejOutputBlock = true; // display output text
        update(sarf);
        return apexPages.currentPage();
    }
    // CANCEL Rejection comments and return to record detail page
    public PageReference cancelRejection(){
        PageReference pageRef = new PageReference('/'+sarf.Id);
        return pageRef;
    }
    //---------------------------------------------------------------------------------------------------------------------------------------------------------/
    //  SARF Re-Rendering: Additional Access Component                                                                                                         /
    //---------------------------------------------------------------------------------------------------------------------------------------------------------/
    
    public void showAccess(){
        accessCommentsReq = true;
        showMorePS = true;
        
        leftselected = new List<String>();
        rightselected = new List<String>();
        String tempPs;
        
        leftvalues.addAll(originalValues);
        
        //Eliminate any Permission Sets from the additional access that are associated with the
        //selected default role
        SARF_Access_Assignment tempSarfAA = new SARF_Access_Assignment(sarf);
        tempSarfAA.assignProfile();
        
        List<String> associatedPSList = tempSarfAA.getPS();
        
        if(associatedPSList != null) {
            for(String associatedPs : associatedPSList) {
                tempPs = null;
                
                if(tempPsMap.containsKey(associatedPs)) {
                    tempPs = tempPsMap.get(associatedPs);
                }
                else
                    tempPs = associatedPs;
                //Remove any additional access that exists in the list
                if(leftvalues.contains(tempPs)) 
                    leftvalues.remove(tempPs);
            }
        }//end of if associatedPSList
        
        if(leftvalues.contains(sarf.Role__c))  {
            leftvalues.remove(sarf.Role__c);
        }   
        
    }
    
    public void hideAccess(){
        accessCommentsReq = false;
        
        //rightSelected = new List<String>();//test, erase if breaks
        rightvalues = new Set<string>(); // hide if breaks
        sarf.Access_Comments__c = '';
        sarf.permission_sets__c = ''; // clear additional permission sets if user clicks cancel
        showMorePS = false;
    }
    
    //---------------------------------------------------------------------------------------------------------------------------------------------------------/
    //  Contact/User creation & updates                                                                                                                        /
    //---------------------------------------------------------------------------------------------------------------------------------------------------------/
    
    // For Existing Users, apply updated information to User object
    public PageReference applyUpdatedAccess(){
        System.debug('ApplyUpdatedAcces reached');
        PageReference pageRef = apexPages.currentPage();
        if(sarf.user_type__c == 'Existing User'){
            // Identify the User
            User userToUpdate = [SELECT id, name, isActive from User WHERE id = :sarf.user_id__c];
            // Create assignments based on role
            System.debug('User to update: ' + userToUpdate.id + ', ' + userToUpdate.name);
            SARF_User_Update updateU = new SARF_User_Update(sarf, userToUpdate);
            updateU.setPersonalInfo(); // updates user's personal information and sets their status to active
            System.debug('User should now be active: ' + userToUpdate.IsActive);
            updateU.setRole();
            updateU.setProfile();
            updateU.deleteCurrentPS();
            updateU.setPS();
            updateU.updateUser();  
            pageRef = Page.SARF_Confirm_User_Update;            
        }    
        return pageRef; 
    }
    
    // Create User and assign access
    public PageReference createUser(){
        PageReference pageRef = apexPages.currentPage();
        SARF_User_Creator uc = new SARF_User_Creator(sarf);
        uc.insertUserWithRole();
        userCreatedPushed = true;
        pageRef = Page.SARF_Confirm_User;
        return pageRef;
    }
    
    //This will update SARF with user id just created from createPortalUser
    public static void confirmPortalUser(String sarfId) {
        CMS_SARF__c portalUserSarf = 
            [SELECT id, user_type__c, role__c, first_name__c, last_name__c, email_address__c,
             user_id__c, user_updated__c, contact_created__c, is_deactivated__c
            FROM CMS_SARF__c
            WHERE id = :sarfId];
        
        if(portalUserSarf.user_type__c == 'New User' && portalUserSarf.role__c == 'American Spaces Site.com'){
            // Add user id to sarf record
            List<User> thisUser = [SELECT id, firstName, lastName, Email FROM User
                                   WHERE firstName = :portalUserSarf.first_name__c and lastName = :portalUserSarf.last_name__c and email = :portalUserSarf.email_address__c LIMIT 1];
            portalUserSarf.user_id__c = thisUser.get(0).id;
            //sarf.ownerId = thisUser.get(0).id; // owner of SARF needs to be the User of SARF for email alert purposes
            portalUserSarf.user_updated__c = true;
            portalUserSarf.contact_created__c = TRUE;
            portalUserSarf.user_created__c = TRUE;
            portalUserSarf.user_type__c = 'Existing User';                
        }
        
        update portalUserSarf;
    }
    
    // Update SARF details after user has been created OR updated
    public PageReference confirmUser(){
        //if user type is New User
        if(sarf != null && String.isNotEmpty(sarf.Role__c)) {
            if(sarf.user_type__c == 'New User' && sarf.role__c != 'American Spaces Site.com'){
                // Add user id to sarf record
                List<User> thisUser = [SELECT id, firstName, lastName, Email FROM User WHERE firstName = :sarf.first_name__c and lastName = :sarf.last_name__c and email = :sarf.email_address__c LIMIT 1];
                sarf.user_created__c = true;
                sarf.user_id__c = thisUser.get(0).id;
                //sarf.ownerId = thisUser.get(0).id; // owner of SARF needs to be the User of SARF for email alert purposes
                System.debug(sarf.user_id__c);
                sarf.user_type__c = 'Existing User';
                sarf.user_updated__c = true; // since User was just implemented, User data is current
            }else if(sarf.user_type__c == 'Existing User' && sarf.role__c != 'American Spaces Site.com'){
                sarf.user_Updated__c = true;
                sarf.is_deactivated__c = false; // when user updates have been applied and confirmed, user is no longer deactivated
                //sarf.ownerId = sarf.User_ID__c; // owner of SARF needs to be the User of SARF for email alert purposes
            }
            
            /*
             * This block is moved to confirmPortalUser method
             * 
            else if(sarf.user_type__c == 'New User' && sarf.role__c == 'American Spaces Site.com'){
                // Add user id to sarf record
                List<User> thisUser = [SELECT id, firstName, lastName, Email FROM User WHERE firstName = :sarf.first_name__c and lastName = :sarf.last_name__c and email = :sarf.email_address__c LIMIT 1];
                sarf.user_id__c = thisUser.get(0).id;
                //sarf.ownerId = thisUser.get(0).id; // owner of SARF needs to be the User of SARF for email alert purposes
                sarf.user_updated__c = true;
                sarf.contact_created__c = TRUE;
                sarf.user_created__c = TRUE;
                sarf.user_type__c = 'Existing User';                
            }
            */
            else if (sarf.user_type__c == 'Existing User' && sarf.role__c == 'American Spaces Site.com'){
                //Need to finish this
                sarf.user_Updated__c = true;
                sarf.is_deactivated__c = false; // when user updates have been applied and confirmed, user is no longer deactivated
            }
            
            if(!(sarf.user_type__c == 'New User' && sarf.role__c == 'American Spaces Site.com'))
                update sarf;            
        }

        return Page.SARF_Default_List_View;
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
            userSelected = false;//
        }
        return null;
    }
    
    public void disableTestUsers(){
        for (List<User> users: [Select name, id, isActive, title FROM User WHERE isActive = :true AND title = :'TEST_USER']){
            for (User u: users){
                u.isActive = false;
            }
            update users;
        }
    } 
    
    //---------------------------------------------------------------------------------------------------------------------------------------------------------/
    //  Build a roles list based on current approving manager.                                                                                                                                /
    //---------------------------------------------------------------------------------------------------------------------------------------------------------/    
    public List<SelectOption> getRolesList() {
        approvingManager = null;
        Schema.DescribeFieldResult fieldResult;
        List<Schema.PicklistEntry> pleList;
        List<SelectOption> roleOptions = new List<SelectOption>();
        roleOptions.add(new SelectOption('','--None--')); //Default option
        
        //Get current user id
        String userId = UserInfo.getUserId();         
        //If current user has a permission set 'CMS SARF Overrride', 
        //this user should see all roles
        if(myPermissionset != null && myPermissionset.endsWithIgnoreCase(SARF_OVERRIDE))
        {
            fieldResult = CMS_SARF__c.Role__c.getDescribe();
            pleList = fieldResult.getPicklistValues();  
            for(Schema.PicklistEntry ple : pleList) {
                roleOptions.add(new SelectOption(ple.getValue(), ple.getValue()));
            }
        }//end of SARF_Override
        else {
            //Using current userId to lookup an approving manager.
            //Parse the roles' values from Aprroving_Manager__c picklist 
            //and build the roles list.
            fieldResult = CMS_SARF__c.Approving_Manager__c.getDescribe();
            pleList = fieldResult.getPicklistValues();
            
            //Loop thru the approving managers and lookup for the one contains current user id
            for(Schema.PicklistEntry ple : pleList) {
                String pleValue = ple.getValue();
                List<String> tokens = pleValue.split(';');
                String roleValue = tokens.get(0);
                //Check if current value matches current user id,
                //parse a role and add to options list
                if(pleValue.contains(userId)) {
                    roleOptions.add(new SelectOption(roleValue, roleValue));
                }
                
                //Additional assignments are assigned on the behalf of original
                //approving managers who are not available.
                if(!myExtraApprovingAssignments.isEmpty()) {
                    for(PermissionSetAssignment psa : myExtraApprovingAssignments) {
                        String myPsaName = psa.PermissionSet.Name;
                        myPsaName = parseApproverPs(myPsaName);
                        if(roleValue.equalsIgnoreCase(myPsaName)) {
                            roleOptions.add(new SelectOption(roleValue, roleValue));
                        }
                        //if myPsaName doesn't match with the role value,
                        //need to look up in the temporary map
                        else {
                            if(tempPsMap.containsKey(myPsaName)) {
                                String myTempPsaName = tempPsMap.get(myPsaName);
                                if(roleValue.equalsIgnoreCase(myTempPsaName)) {
                                    roleOptions.add(new SelectOption(roleValue, roleValue));
                                }
                            }
                        }
                    }
                }
            }  
        }//end of SARF_Manager and other roles

        return roleOptions;
    }
    
    public User getUser(String id) {
        if(String.isNotEmpty(id)) {
            List<User> users = [SELECT Id, Email FROM User WHERE id = :id];
            if(users != null && users.size() > 0) {
                return users.get(0);
            }
        }
        return null;
    }
    
    /**
    * Loop thru Approving_Manager__c picklist to find user id,
    * return an approving manager if current user id matches with 
    * user id in the list
    **/ 
    /*public User getApprovingManager(String userId) {
        approvingManager = null;
        Schema.DescribeFieldResult fieldResult = CMS_SARF__c.Approving_Manager__c.getDescribe();
        List<Schema.PicklistEntry> pleList = fieldResult.getPicklistValues();
        for(Schema.PicklistEntry ple : pleList) {
            String pleValue = ple.getValue();
            if(pleValue.contains(userId)) {
                User user = getUser(userId);
                if(user != null) {
                    approvingManager = user;
                }
            }
        } 
        return approvingManager;
    }
    */
    /**
    * User with Override permission set should see all role.  This user
    * can approve any SARF in a case that current approving manager is not
    * available.
    * Loop thru Approving_Manager__c picklist to find a matching role
    * and retrieve a user id.
    **/ 
    public User getApprovingManagerBySelectedRole(String role) {
        approvingManager = null;
        if(String.isNotEmpty(role)) {
            Schema.DescribeFieldResult fieldResult = CMS_SARF__c.Approving_Manager__c.getDescribe();
            List<Schema.PicklistEntry> pleList = fieldResult.getPicklistValues();
            for(Schema.PicklistEntry ple : pleList) {
                String pleValue = ple.getValue();
                if(pleValue.contains(role)) {
                    List<String> tokens = pleValue.split(';');
                    String selectedAppMan = tokens.get(2);
                    approvingManager = getUser(selectedAppMan);
                }
            }
        }
        return approvingManager;
    }
    
    /**
     * 
     * If current user with American Spaces site.com role is trying to change
     * to a different role or vice versa, will receive an error message.
     * 
     **/ 
    private String amsRoleValidation(CMS_SARF__c currentSarf) {
        String msg = '';
        
        if(currentSarf != null) {
            if(isApproved && 
               (currentSarf.Version_Number__c == 1 || currentSarf.Version_Number__c > 1)
               || currentSarf.User_Type__c.equals('Existing User')) {
                   //If current user is in a AMS Site.com role, should not update to different role.
                   if(isCurrentAMSRole && !currentSarf.Role__c.equalsIgnoreCase(AMS_SITE_DOT_COM)) {
                       msg = 'You must create a new SARF to create a SalesForce User';
                   }
                   //If current user is in a different role and updates to AMS Site.com
                   else if(!isCurrentAMSRole && currentSarf.Role__c.equalsIgnoreCase(AMS_SITE_DOT_COM)) {
                       msg = 'You must create a new SARF to create a Portal User';
                   }
               }     
        }
        
        return msg;
    }
    
    /**
     * 
     * Parse approving permission set name and eliminate 'Approver' to
     * match with role that is mapped with original approving manager
     * 
     **/ 
    private String parseApproverPs(String permissionSetName) {
        if(String.isNotEmpty(permissionSetName)) {
            if(permissionSetName.indexOf('Approver') != -1) {
                Integer endIndex = permissionSetName.indexOf('Approver') - 1; //including the underscore
                String psName = permissionSetName.substring(0, endIndex);
                psName = psName.replaceAll('_', ' ');
                return psName;
            }
        }
        
        return null;
    }
    
    private PermissionSet getPermissionSetByName(String permissionSetName) {
        try {
            return [SELECT id, label FROM PermissionSet WHERE name = :permissionSetName LIMIT 1];
        } catch(Exception e) {
            System.debug(LoggingLevel.ERROR, e.getMessage());
        }
        return null;
    }
    
    public String getCurrentUrl(CMS_SARF__c sarf) {
        String hostVal  = URL.getSalesforceBaseUrl().getHost();
        //String urlVal = Apexpages.currentPage().getUrl();
        String aUrl = 'https://' + hostVal+'/'+sarf.Id;

        return aUrl;
    }
    
    public String getProfileId() {
        if(String.isBlank(profileId)) {
            try {
                profileId = [SELECT id, name FROM Profile where name = 'Overage Authenticated Website User' LIMIT 1].id;
            } catch(Exception e) {
                System.debug(LoggingLevel.ERROR, e.getMessage());
            }  
        }
        
        return profileId;
    }
}
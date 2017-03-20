public with sharing class SARF_Starter_Controller {
    
    String fname;
    String lname;
    String emailAddress;
    String phoneNum;
    String title;
    String bureauDept;
    String role;
    String errorMessage;
    
    // Empty constructor
    public SARF_Starter_Controller(){}
    
    // Constructor that takes form values
    public SARF_Starter_Controller(String firstName, String lastName, String email, String phone, String jobtitle, String bureau, String aRole){
        fname = firstName;
        lname = lastName;
        emailAddress = email;
        phoneNum = phone;
        title = jobtitle;
        bureauDept = bureau;
        errorMessage = 'All fields are required!';
        role = aRole;
    }
    
    // Check if form is valid (all fields must be filled out and email address must be valid)
    public boolean formValidated(){
        boolean v = true;
        if(fName == NULL || fName == ''){
            v = false;
        }else if(lName == NULL || lName == ''){
            v = false;
        }else if(emailAddress == NULL || emailAddress == ''){
            v = false;
        }else if(!emailValid()){
            v = false;
            errorMessage = 'You must provide a valid email address!';
        }
        else if(phoneNum == NULL || phoneNum == ''){
            v = false;
        }else if(title == NULL || title == ''){
            v = false;
        }
        else if(bureauDept == NULL || bureauDept == ''){
            v = false;
        }
        return v;
    }
    
    // Check to see if email address is valid
    public boolean emailValid(){
        boolean valid = true;
        if(!Pattern.matches('^[a-zA-Z0-9._|\\\\%#~`=?&/$^*!}{+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,4}$', emailAddress)){
            valid = false;
        }
        return valid;
    }
    
    // Display appropriate error message on form
    public PageReference displayError(){
        ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, errorMessage);
        ApexPages.addMessage(myMsg);
        return null;
    }
    
    
    // Return whether a SARF exists based on email address
    public boolean noSarfFound(){
    List<CMS_SARF__c> sarfs = [SELECT id, name, email_address__c from CMS_SARF__c where email_address__c = :emailAddress LIMIT 1];
        if (sarfs.size() >0 && sarfs != NULL){
            errorMessage = 'A form has already been submitted with this email address.';
            return false;
        }
        return true;
    }
    
    // Passed from controller after SUBMIT button is clicked, create and insert a SARF
    public void createSARF(){
            CMS_SARF__c sarf = new CMS_SARF__c();
            sarf.user_Type__c = 'New User';
            sarf.first_Name__c = fName;       
            sarf.last_Name__c = lName;
            sarf.email_Address__c = emailAddress;
            sarf.phone_number__c = phoneNum;
            sarf.title__c = title;
            sarf.office__c = bureauDept;
            sarf.Role__c = role;
            sarf.date_submitted__c = Datetime.now();
            sarf.externallycreated__c = true;
        	//sarf.isPendingApproval__c = true;
            // generate SARF User ID
            SARF_Unique_ID_Generator gen = new SARF_Unique_ID_Generator(sarf);
            gen.generateRandomNumber();
            gen.queryRandomNumbers();
        	
        	SARF_Controller sarfController = new SARF_Controller();
            if(role != ''){
                SARF_Access_Assignment newAssignment = new SARF_Access_Assignment(sarf);
                newAssignment.assignProfile();
                newAssignment.setProfileAndPS(newAssignment.getProfile());
                
                User approvingManager = sarfController.getApprovingManagerBySelectedRole(role);
                if(approvingManager != null)
                    sarf.Manager__c = approvingManager.Id;
            }
            insert sarf;
        
            if(sarf.Email_Address__c.contains('state.gov')) {
                //Needs to retrieve base URL from global variable.  This url will be updated accordingly in different environments
                String baseUrl;
                try {
                    baseUrl = [SELECT value__c FROM Global_Variable__c WHERE name = 'Salesforce Base URL' LIMIT 1].value__c;
                } catch(Exception e) {
                    System.debug(LoggingLevel.ERROR, e.getMessage());
                }

                SARF_EmailHandler emailHandler = new SARF_EmailHandler(sarf, baseUrl+'/'+sarf.Id);
                emailHandler.sendEmail();
            }

    }
}
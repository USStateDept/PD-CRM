public class SARF_User_Creator {
    
    CMS_SARF__C sarf;      // SARF record
    List<String> defPS;    // Default PS for assigned Role & Profile
    List<String> extraPS;  // Additional PS specified on SARF
    Contact c;			   // Contact for Customer Portal user
    
    // Constructor
    public SARF_User_Creator(CMS_SARF__c sa){
        sarf = sa;
        defPS = new List<String>();
        extraPS = new List<String>();
    }
    
    // Create & return List<String> of all default PS, with correct API formatting
    public List<String> getPSList(){
        String formattedPS = sarf.Permission_Sets_Default__c;
        String[] splitList = formattedPS.split('\n',0);
        for (String s: splitList){
            s = s.replaceAll(' ', '_'); // change all spaces to underscores
            s = s.replaceAll('-', '_'); // change all dashes to underscores
            defPS.add(s);
        }
        return defPS;
    }
    
    // Create & return List<String> of all additional PS, with correct API formatting
    public List<String> getExtra(){
        extraPS = new List<String>();
        if(sarf.Permission_Sets__c != NULL){
            String formattedXPS = sarf.Permission_Sets__c;
            String[] splitList = formattedXPS.split(';',0);
            for (String s: splitList){
                s = s.replaceAll(' ', '_');
                s = s.replaceAll('-', '_');
                s = s.replace('.', '_');
                extraPS.add(s);
            }
        }
        return extraPS;
    }
    
    // Method to create new User
    public void insertUserWithRole(){
        if(sarf.user_type__c == 'New User'){
            if (confirmNewUser() == TRUE){                
                // Role
                UserRole r = [SELECT Id FROM UserRole WHERE Name= :sarf.role__c];                
                // Profile
                Profile p;
                String prof = sarf.ProfileTemp__c;
                if(prof.equalsIgnoreCase('System Administrator (mock)')){
                    p = [SELECT Id FROM Profile WHERE id= :'00ea0000000jOTVAA2'];  
                }else if(prof.equalsIgnoreCase('System Administrator')){
                    p = [SELECT Id FROM Profile WHERE id= :'00e30000001HCeZAAW'];  
                }else{
                    p = [SELECT Id FROM Profile WHERE Name= :sarf.profileTemp__c];
                }                
                // Create new user with a non-null user role ID 
                User u = new User();
                SARF_Unique_ID_Generator rc = new SARF_Unique_ID_Generator(sarf);
                String[] splitList = sarf.email_address__c.split('@',0);
                String tempUN = splitList[0];  // first half
                String tempUN2 = splitList[1]; // second half
                if(tempUN != NULL){
                    tempUN = rc.queryUsername(tempUN, tempUn2);
                }
                u.username = tempUn + '@' + tempUN2;
                u.Email = sarf.email_address__c;
                u.Lastname = sarf.last_name__c;
                u.Firstname = sarf.first_name__c;
                
                //Need to create a method that checks for unique alias and modifies if necessary
                String temp = ''; // temp will get a standard value and then pass it to the alias generator for final unique alias creation
                if(sarf.last_name__c.length() > 4){
                    temp = sarf.last_name__c.substring(0,4) + sarf.first_name__c.substring(0,1);
                }else{
                    temp = sarf.last_name__c + sarf.first_name__c.substring(0,1);
                }
                temp = rc.queryAlias(temp); // generate unique alias and set to temp
                u.Alias = temp; // set alias to temp
                u.CommunityNickname = temp; // set to same as alias
                u.profileid = p.Id; // use id from profile retrieved at beginning of method
                u.userroleid = r.Id; // use id from role retrieved at beginnning of method
                u.timezonesidkey='GMT'; // set to standard default for all Users
                u.LocaleSidKey = 'en_US'; // set to standard default English US for all Users
                u.LanguageLocaleKey = 'en_US'; // again set to English US
                u.EmailEncodingKey = 'ISO-8859-1';
                u.UserPermissionsMobileUser = true; // make the User a mobile User by default
                u.isActive = TRUE; // ensure User is active
                u.title = sarf.title__c;
                //u.companyname = 'TestUser'; // delete this when push to QA
                insert u; // INSERT User into SF org
                System.resetPassword(u.Id, true);
                
                //Permission set assignment to user
                List<PermissionSetAssignment> newPermissionSetAccess = new List<PermissionSetAssignment>(); //list for new permission sets
                
                // LOOP TO GET ALL PS
                // Default Perm Sets for specified Role & Profile
                for (String s: getPSList()){
                    Id psaId; //Id of the permission set we want Users to be assigned
                    PermissionSet psSelected = [SELECT Id FROM PermissionSet WHERE Name = :s LIMIT 1]; //query for the permission set Id
                    if (psSelected != NULL){
                        psaId = psSelected.Id; //assign the premission set Id
                        PermissionSetAssignment newPSA = new PermissionSetAssignment(); //PermissionSetAssignment sobject
                        newPSA.PermissionSetId = psaId; //set the permission set Id
                        newPSA.AssigneeId = u.Id; //set the User Id
                        newPermissionSetAccess.add(newPSA); //add the record to our list
                    }
                }
                //Additional Perm Sets indicated on SARF
                if(getExtra() !=NULL && getExtra().size() > 0){
                    System.debug('Additional ps on SARF, entering method to assign approver status!!!!');
                    // Logged in User is approver or not
                    Boolean isApprover = false;
                    for (String s: getExtra()){
                        // Check if any permission set includes "approver" ignoring case
                        if(s.contains('Approver') || s.contains('approver')){
                            isApprover = true; // Logged in User needs to have the SARF Manager Permission Set if 'true'
                            System.debug('User is approver: ' + isApprover);
                        }
                        Id psaId; //Id of the permission set we want Users to be assigned
                        PermissionSet psSelected = [SELECT Id FROM PermissionSet WHERE Name = :s LIMIT 1]; //query for the permission set Id
                        if (psSelected != NULL){
                            psaId = psSelected.Id; //assign the premission set Id
                            PermissionSetAssignment newPSA = new PermissionSetAssignment(); //PermissionSetAssignment sobject
                            newPSA.PermissionSetId = psaId; //set the permission set Id
                            newPSA.AssigneeId = u.Id; //set the User Id
                            newPermissionSetAccess.add(newPSA); //add the record to our list
                        }
                    }   
                                       
                }
                
                // if PermissionSetAssignments exist, insert them
                if(!newPermissionSetAccess.isEmpty()){
                    insert newPermissionSetAccess; //insert
                }
            } 
        } 
    }
    
    public boolean confirmNewUser(){
        return true;
    }
}
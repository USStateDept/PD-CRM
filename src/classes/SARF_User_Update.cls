public class SARF_User_Update {
    
    CMS_SARF__C sarf;		// SARF for the User to update
    User thisUser;			// User to update
    List<String> defPS;		// default perm sets
    List<String> extraPS;	// extra perm sets
    
    public SARF_User_Update(CMS_SARF__c aSARF, User aUser){
        sarf = aSARF;					
        thisUser = aUser;				
        defPS = new List<String>();		
        extraPS = new List<String>();
    }
    
    public void setActive(){
        // check to see if current logged in user has user_manager permission set
        List<PermissionSetAssignment> myAssignments = [SELECT Id, PermissionSet.Name, PermissionSet.Id, AssigneeId
                                                       FROM PermissionSetAssignment
                                                       WHERE AssigneeId = :UserInfo.getUserId()];
        boolean isUserManager = false;
        List<PermissionSetAssignment> newPermissionSetAccess = new List<PermissionSetAssignment>(); //list for new permission sets
        if(myAssignments != NULL && myAssignments.size() > 0){
            for (PermissionSetAssignment psa:  myAssignments){
                if(psa.PermissionSet.Id == '0PSa00000008QAUGA2'){
                    isUserManager = true;
                }
            }
            if(isUserManager == false){
            // If not, create new PermissionSetAssignment for this user to include the user_manager permission set with id 0PSa00000008QAUGA2            	
            	PermissionSetAssignment newPSA = new PermissionSetAssignment(); //PermissionSetAssignment sobject
                newPSA.PermissionSetId = '0PSa00000008QAUGA2'; //set the permission set Id
                newPSA.AssigneeId = UserInfo.getUserId(); //set the User Id
                newPermissionSetAccess.add(newPSA); //add the record to our list
                // insert permissionsetassignment
                if(!newPermissionSetAccess.isEmpty()){
        			insert newPermissionSetAccess;
        		}
            }
        }
    	thisUser.IsActive = TRUE;
        update(thisUser);
        // Remove the User_Manager permission set from the logged in user
        delete newPermissionSetAccess;
        System.debug('user active state? ' + thisuser.isactive);
    }
    
    // Update personal info (non-access related info)
    public void setPersonalInfo(){
        if(sarf.is_deactivated__c == true || thisUser.isActive == false){
            setActive();
        }
        thisUser.firstName = sarf.first_name__c;
        thisUser.lastName = sarf.last_Name__c;
        thisUser.email = sarf.email_address__c;
        thisUser.phone = sarf.phone_number__c;
        thisUser.title = sarf.title__c;
        //thisUser.IsActive = TRUE;
    }
    
    // Update Role
    public void setRole(){
        if(sarf.role__c != 'American Spaces Site.com'){ // Portal Users cannot have a Role
        	UserRole r = [SELECT Id FROM UserRole WHERE Name= :sarf.role__c];
        	thisUser.userroleid = r.Id;
        }
    }
    
    // Update Profile
    public void setProfile(){
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
        thisUser.profileid = p.Id;
    }
    
    // Generate formatted standard Permission Set names from SARF (with API underscores)
    public List<String> getPSList(){
        String formattedPS = sarf.Permission_Sets_Default__c;
        String[] splitList = formattedPS.split('\n',0);
        for (String s: splitList){
            s = s.replaceAll(' ', '_');
            s = s.replaceAll('-', '_');
            defPS.add(s);
        }
        return defPS;
    }

	// Generate formatted additional Permission Set names from SARF (with API underscores)   
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
    
    // Delete current PS not associated with user's profile
    public void deleteCurrentPS(){ 
        // GET current PS of User that are NOT tied to a Profile (standalone only)
        // Current Permission Set Assignments for User (ALL, including standalone and profile-owned)
        List<PermissionSetAssignment> currentUserPSA = [SELECT Id, PermissionSet.Name, AssigneeId FROM PermissionSetAssignment WHERE AssigneeId = :thisUser.Id];
        List<String> temp = new List<String>(); // current ps names for user
        List<PermissionSet> ps = new List<PermissionSet>();
        for (PermissionSetAssignment p: currentUserPSA){
            temp.add(p.PermissionSet.Name);
            ps.add(p.PermissionSet);
        }
        List<PermissionSet> standalonePermSets = new List<PermissionSet>();
        List<String> standalonePSNames = new List<String>();
        Integer x = 0;
        
        while(x < ps.size()){
            String psname = ps.get(x).name;
            List<PermissionSet> permSets = [select Id,Name from PermissionSet WHERE name = :psname AND IsOwnedByProfile = false LIMIT 1];
            if(permSets != NULL && permSets.size() > 0){
            	standalonePermSets.add(permSets.get(0));
            }else{
                System.debug('NOT standalone: ' + psname);
            }
            x++;
        }

        if(standalonePermSets != NULL && standalonePermSets.size() > 0){
            System.debug('Standalone Permission Sets:');
            for(PermissionSet perm: standalonePermSets){
                PermissionSetAssignment p = [SELECT Id, AssigneeId, PermissionSetId FROM PermissionSetAssignment WHERE AssigneeId = :thisUser.ID AND PermissionSetId = :perm.ID];
                System.debug(perm + '\n' + p + '\n\n');
                delete p;
            }
        }        
    }
    
    // Set new permission sets to User
    public void setPS(){
    	// Permission set assignments
    	List<PermissionSetAssignment> newPermissionSetAccess = new List<PermissionSetAssignment>(); //list for new permission sets
        //LOOP TO GET ALL PS
        if(defPS != NULL && getPSList().size() > 0){
        	for (String s: defPS){
                System.debug(s);
                if(s.equalsIgnoreCase('CONX_Support_User')){
                    s = 'CONX General Queue';
                }
        		Id psaId; //Id of the permission set we want Users to be assigned
            	PermissionSet psSelected = [SELECT Id, name FROM PermissionSet WHERE Name = :s]; //query for the permission set Id
                if (psSelected != NULL ){                		
                	psaId = psSelected.Id; //assign the premission set Id
                	PermissionSetAssignment newPSA = new PermissionSetAssignment(); //PermissionSetAssignment sobject
                	newPSA.PermissionSetId = psaId; //set the permission set Id
                	newPSA.AssigneeId = thisUser.Id; //set the User Id
                	newPermissionSetAccess.add(newPSA);
                } 	
        	}
        }
        if(getExtra() !=NULL && getExtra().size() > 0){
        	for (String s: getExtra()){
                Id psaId; //Id of the permission set we want Users to be assigned
                PermissionSet psSelected = [SELECT Id FROM PermissionSet WHERE Name = :s]; //query for the permission set Id
                if (psSelected != NULL){
                    psaId = psSelected.Id; //assign the premission set Id
                    PermissionSetAssignment newPSA = new PermissionSetAssignment(); //PermissionSetAssignment sobject
                    newPSA.PermissionSetId = psaId; //set the permission set Id
                	newPSA.AssigneeId = thisUser.Id; //set the User Id
                    newPermissionSetAccess.add(newPSA); //add the record to our list
                }
            }
   		}
        if(!newPermissionSetAccess.isEmpty()){
        	insert newPermissionSetAccess;
        }
    }

    // Update User object with all information
    public void updateUser(){
        // check to see if current logged in user has user_manager permission set
        List<PermissionSetAssignment> myAssignments = [SELECT Id, PermissionSet.Name, PermissionSet.Id, AssigneeId
                                                       FROM PermissionSetAssignment
                                                       WHERE AssigneeId = :UserInfo.getUserId()];
        boolean isUserManager = false;
        List<PermissionSetAssignment> newPermissionSetAccess = new List<PermissionSetAssignment>(); //list for new permission sets
        if(myAssignments != NULL && myAssignments.size() > 0){
            for (PermissionSetAssignment psa:  myAssignments){
                if(psa.PermissionSet.Id == '0PSa00000008QAUGA2'){
                    isUserManager = true;
                }
            }
            if(isUserManager == false){
            // If not, create new PermissionSetAssignment for this user to include the user_manager permission set with id 0PSa00000008QAUGA2            	
            	PermissionSetAssignment newPSA = new PermissionSetAssignment(); //PermissionSetAssignment sobject
                newPSA.PermissionSetId = '0PSa00000008QAUGA2'; //set the permission set Id
                newPSA.AssigneeId = UserInfo.getUserId(); //set the User Id
                newPermissionSetAccess.add(newPSA); //add the record to our list
                // insert permissionsetassignment
                if(!newPermissionSetAccess.isEmpty()){
        			insert newPermissionSetAccess;
        		}
            }
        }
        // update the User on the SARF with the SARF info
        update thisUser;
        // Remove the User_Manager permission set from the logged in user
        delete newPermissionSetAccess;
    }
}
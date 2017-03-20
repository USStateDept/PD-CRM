public with sharing class CMS_Risk_Controller{
    
  public ApexPages.StandardController std{get; set;}
  public CMS_Risk__c risk{get; set;}
  public String myPermissionset{get; set;}
   
  // Risk Controller constructor    
  public CMS_Risk_Controller(ApexPages.StandardController stdCtrl){
    std = stdCtrl;
    risk = (CMS_Risk__c) std.getRecord();   
    myPermissionset = GLOBAL_Library.getPermissionset(UserInfo.getName(), 'CMS_Risk__c');
  }
     
  // Opens the custom VF page to edit Comments box (limited to Risk Owner)
  public PageReference openRMEdit(){
      PageReference pageRef = ApexPages.currentPage(); // set pageRef to current page
      if((String)risk.OwnerId == (String)UserInfo.getUserId()){ // if user is Risk owner
           pageRef = Page.CMS_Risk_RM_Edit; // set pageRef to Comments page
      }
      else{ // else stay on current page and display error message to user with permission restrictions
      	   ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'You are not the owner of this Risk and may not edit the comments.');
	  	   ApexPages.addMessage(myMsg); 
      }
    return pageRef;
  }
     
    
  // Opens the custom VF page to edit Risk Analysis fields (limited to CMS Risk Manager permission set)
  public PageReference openRAEdit(){
      PageReference pageRef = ApexPages.currentPage(); // set pageRef to current page
      // Check to see if user has CMS Risk Manager permission set
      List<PermissionSetAssignment> assignments = [SELECT Id, Assignee.Name, PermissionSet.Name
                                            FROM PermissionSetAssignment
                                            WHERE PermissionSet.Name = 'CMS_Risk_Manager' AND Assignee.Name = :userInfo.getName()];
      if(assignments != null && assignments.size() > 0){ // if user has CMS Risk Manager permissions
      		pageRef = Page.CMS_Risk_RA_Edit; // set pageRef to Risk Analysis page
      }else{ // else stay on current page and display error message to user with permission restrictions
      	 	ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Manager permissions are required to edit the Risk Analysis section.');
         	ApexPages.addMessage(myMsg); 
      }
    return pageRef;
  }
  

  // Opens the custom VF page to edit Issue Analysis fields (limited to CMS Risk Manager permission set)
  public PageReference openIAEdit(){
      PageReference pageRef = ApexPages.currentPage(); // set pageRef to current page
      // Check to see if user has CMS Risk Manager permission set
      List<PermissionSetAssignment> assignments = [SELECT Id, Assignee.Name, PermissionSet.Name
                                            FROM PermissionSetAssignment
                                            WHERE PermissionSet.Name = 'CMS_Risk_Manager' AND Assignee.Name = :userInfo.getName()];
      if(assignments != null && assignments.size() > 0){ // if user has CMS Risk Manager permissions
      		pageRef = Page.CMS_Risk_IA_Edit; // set pageRef to Issue Analysis page
      }else{ // else stay on current page and display error message to user with permission restrictions
      		ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Manager permissions are required to edit the Issue Analysis section.');
	 		ApexPages.addMessage(myMsg);
      }
      return pageRef;
  }
  
    
  // Sets the Risk Status picklist and Date triggered field when user clicks 'Trigger Risk' button 
  public PageReference setTriggered(){
      PageReference pageRef = ApexPages.currentPage();
      boolean hasPermission = false;
      ApexPages.Message msgPermissions = new ApexPages.Message(ApexPages.Severity.ERROR,'To trigger the Risk, you must be a manager or the owner of the Risk.');
      ApexPages.Message msgTriggered = new ApexPages.Message(ApexPages.Severity.ERROR,'This Risk has already been triggered!');
      
      // Check to see if user has CMS Risk Manager permission set
      List<PermissionSetAssignment> assignments = [SELECT Id, Assignee.Name, PermissionSet.Name
                                            FROM PermissionSetAssignment
                                            WHERE PermissionSet.Name = 'CMS_Risk_Manager' AND Assignee.Name = :userInfo.getName()];
      if(assignments != null && assignments.size() > 0){ // if user has CMS Risk Manager permissions
      		hasPermission = true;
      }
      //Check to see if user is owner
      if((String)risk.OwnerId == (String)UserInfo.getUserId()){
          hasPermission = true;
      }
      // IF user has permission to trigger risk
      if (hasPermission == TRUE){
          if(risk.RARisk_Status__c != 'TRIGGERED'){ //if not already triggered, set the fields to update status and date
      		risk.RARisk_Status__c = 'TRIGGERED';
      		risk.IADateTime_Triggered__c = DateTime.now();
      		update(risk); // update record
          }else { // if already triggered
              ApexPages.addMessage(msgTriggered); // display error message already triggered
          }
  	  }
      // ELSE if user does not have permission to trigger risk
      else{ 
          if(risk.RARisk_Status__c != 'TRIGGERED'){ // if Risk is not already triggered
              ApexPages.addMessage(msgPermissions); // display error message, incorrect permissions
          }
          else{ // if already triggered
              ApexPages.addMessage(msgTriggered); // display error message already triggered
          }
      }
      return pageRef;
  }
}
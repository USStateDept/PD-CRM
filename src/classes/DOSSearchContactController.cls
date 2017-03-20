public class DOSSearchContactController {
    // the soql without the order and limit
  private String soql {get;set;}
  // the collection of contacts to display
  public List<Contact> contacts {get;set;}
  
  public String firstName {get;set;}
  public String lastName {get;set;}
  public String email {get;set;}
  public ID selContactId {get;set;}
  
  public List<conWrapper> cons{get;set;}
  
  
  public class conWrapper{
    public Boolean selected{get;set;}
    public Contact con{get;set;}
  }
  
  // the current sort direction. defaults to asc
  public String sortDir {
    get  { if (sortDir == null) {  sortDir = 'asc'; } return sortDir;  }
    set;
  }

  // the current field to sort by. defaults to last name
  public String sortField {
    get  { if (sortField == null) {sortField = 'lastName'; } return sortField;  }
    set;
  }

  // format the soql for display on the visualforce page
  public String debugSoql {
    get { return soql + ' order by ' + sortField + ' ' + sortDir + ' limit 20'; }
    set;
  }

  // init the controller and display some sample data when the page loads
  public DOSSearchContactController() {
    //init code goes here
    
  }

  // toggles the sorting of query from asc<-->desc
  public void toggleSort() {
    // simply toggle the direction
    sortDir = sortDir.equals('asc') ? 'desc' : 'asc';
    // run the query again
    runQuery();
  }
  
 
  // runs the actual query
  public void runQuery() {

    try {
      cons.clear();     
      contacts = Database.query(soql + ' order by ' + sortField + ' ' + sortDir + ' limit 20');  
         
    } catch (Exception e) {
      ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Ooops!'));
    }

  }

  // runs the search with parameters passed from Vf
  public PageReference runSearch() {    

    soql = 'select Id, firstname, lastname, account.name, Post_Name__c, email from contact where email != null';
    if (firstName != '' && firstName != null)
      soql += ' and firstname LIKE \''+String.escapeSingleQuotes(firstName)+'%\'';
    if (lastName != '' && lastName != null)
      soql += ' and lastname LIKE \''+String.escapeSingleQuotes(lastName)+'%\'';
    if (email != '' && email != null)
      soql += ' and email = \''+String.escapeSingleQuotes(email)+'\'';  
    

    // run the query again
    runQuery();

    return null;
  }
  
  //creates the sharing record for selected contacts
  public PageReference shareContact(){
        
        
    Boolean isShared = false;
    String msg='';
    String accountId = null;
    try{
            String userId = UserInfo.getUserId();
            //String userRoleId = UserInfo.getUserRoleId();
            //System.debug('userRoleId '+ userRoleId);
            
            String userRole = [Select Id, Name from UserRole where Id = : UserInfo.getUserRoleId()].Name;
            System.debug('userRoleName '+ userRole);
            List<Account> accList = [Select Id from Account where name =: userRole]; 
            
            if(accList.size() == 1)
                accountId = accList[0].Id;
            System.debug('accountId: '+ accountId);
                   
            if(accountId != null)
            { 
                List<AccountContactRelation> acrList = new List<AccountContactRelation>();  
                    //for(conWrapper cw : cons){
                        if(selContactId != null){
                            isShared = false;
                            String contactId = selContactId;           
                            ContactShare conShare = new ContactShare();
                            
                            //Set the ID of the record being shared
                            conShare.ContactId = contactId;
                            //Set the ID of the user or group being granted access
                            conShare.UserOrGroupId = userId;
                            //Set the access level
                            conShare.ContactAccessLevel = 'Edit';
                            //Set the RowCause
                            conShare.RowCause = 'Manual';
                            
                            //Insert the sharing record and capture the save result
                            Database.SaveResult sr = Database.insert(conShare,false);
                            
                            //Process the results
                            if(sr.isSuccess()){
                                //addAccountContactRelation(accountId, contactId);
                                AccountContactRelation objACR = new AccountContactRelation();
                                objACR.AccountId = accountId;
                                                objACR.ContactId = contactId;
                                                objACR.IsActive = true;
                                                objACR.StartDate = date.today();
                                acrList.add(objACR);
                                isShared = true;
                            }
                            else                
                            {
                                Database.Error err = sr.getErrors()[0];
                                if(err.getStatusCode() == StatusCode.FIELD_FILTER_VALIDATION_EXCEPTION &&
                                    err.getMessage().contains('AccessLevel')){
                                    // Indicates success.
                                    isShared = true;
                                
                                }
                                else{
                                    //Indicates failure
                                    msg = err.getMessage();
                                    system.debug('Error Message: '+ msg);                     
                                    isShared = false;
                                }           
                            }
                        }   
                   // }
                  
                          //Check whether all the selected records got shared or not.
                          if(isShared){
                                        insert acrList;
                                msg = 'Selected contact(s) are shared with your Mission successfully';         
                          }
                          else{
                             if(selContactId == null)
                                    msg = 'Sorry! No contacts are available to share. Search for Contacts, select one and then share it.'; 
                             else       
                                 msg = 'Selected contact is not shared with your Mission. Please check with your administrator'; 
                            }
            }
            else
                msg = 'No Mission exists with user role or multiple missions exist. There must be one Mission record only, please verify your data in Accounts tab.';
        }//end of try block
        
        catch(Exception e){
                msg = e.getMessage();
        }
        ApexPages.Message currentMsg = new ApexPages.Message(ApexPages.severity.INFO, msg);
        ApexPages.addMessage(currentMsg);
        if(selContactId != null)
            return new PageReference('/'+selContactId);
        else
            return null;    
  }
  
  /*public void addAccountContactRelation(String accId, String conId){
        
                AccountContactRelation objACR = new AccountContactRelation();
                
                List<AccountContactRelation> acrList = [Select Id from AccountContactRelation where AccountId =: accId and ContactId =: conId and EndDate = null and isActive = true];
                
                if(acrList.size() == 0){
                
                        objACR.AccountId = accId;
                        objACR.ContactId = conId;
                        objACR.IsActive = true;
                        objACR.StartDate = date.today();
                        
                        insert objACR;
                }               
                
  } */  
  public PageReference getSelected()
    {
        System.debug('Entered contact selection block');
        selContactId = ApexPages.currentPage().getParameters().get('conid');
        return null;
    } 
}
@isTest
public class TestUpdateValidation {
    
    static testMethod void testNotesValidation() {
         Profile p = [select id FROM Profile WHERE name = 'PD CRM' LIMIT 1];
         User u = new User(alias = 'standt', email = 'updateval@testorg.com',
                            emailencodingkey = 'UTF-8', lastname = 'Testing', 
                           languagelocalekey = 'en_US', localesidkey = 'en_US', profileid = p.Id, 
                           timezonesidkey = 'America/Los_Angeles', username = 'updateval@testorg.com');
        
          System.runAs(u) {
              Account a = new Account(Name = 'Merch 1');
              insert a;
              Contact c = new Contact(accountId = a.id, firstname = 'Lebron', lastName = 'James', 
                                      email = 'theking@nba.com');
              insert c;
             
              Note  ac = new Note(parentId = c.id, title = 'Note', body = '123 123123 sasf');
              insert ac;
              
              ac.body = '23232';
              update ac;
          
          }
    }
    

}
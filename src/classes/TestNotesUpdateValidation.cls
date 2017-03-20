@isTest
public class TestNotesUpdateValidation {
    
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
              Blob b = Blob.valueOf('12345qwerty');
              attachment at = new Attachment(parentId = c.id, name = 'Attachment', body = b);
              insert at;
              b = Blob.valueOf('123123asdfs');
              at.body = b;
              try {
					              update at;                  
              } catch (DMLException ex) {
                  System.assert(ex.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'));
              }

          
          }
    }
    

}
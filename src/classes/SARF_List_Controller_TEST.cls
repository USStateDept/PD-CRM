@isTest
public class SARF_List_Controller_TEST {
    
    static testMethod void testClearFilter(){  
        
        Test.startTest();
        SARF_List_Controller lc = new SARF_List_Controller();
        lc.clearFilter();
        Test.stopTest();   
        
        System.assertEquals(lc.searchFN, '');
        System.assertEquals(lc.searchLN, '');
        System.assertEquals(lc.searchSarfUserID, '');
        System.assertEquals(lc.noSarfsFound, '');
        System.assertEquals(lc.filter, false);
    }
    
    
    static testMethod void testDoSearch(){ 
        
        Test.startTest();
        SARF_List_Controller lc = new SARF_List_Controller();
        List<CMS_SARF__c> sarfList = createSarfList();
        lc.sarfs = sarfList;
        
        // Without SARF User ID        
        lc.searchFN = 'FNameExample';
        lc.searchLN = 'LNameExample';
        lc.searchSARFUserID = '';
        lc.doSearch();        
        
        lc.searchFN = 'FName1';
        lc.searchLN = 'LName1';
        lc.searchSARFUserID = '';
        lc.doSearch(); 
        
        lc.searchFN = 'FName2';
        lc.searchLN = '';
        lc.searchSARFUserID = '';
        lc.doSearch();
        
        lc.searchFN = '';
        lc.searchLN = 'LName3';
        lc.searchSARFUserID = '';
        lc.doSearch();
        
        // With SARF User ID        
        lc.searchFN = 'FNameExample';
        lc.searchLN = 'LNameExample';
        lc.searchSARFUserID = '324357';
        lc.doSearch();    
               
        lc.searchFN = 'FName2';
        lc.searchLN = 'LName2';
        lc.searchSARFUserID = '222222';
        lc.doSearch(); 
        
        lc.searchFN = '';
        lc.searchLN = '';
        lc.searchSARFUserID = '333333';
        lc.doSearch();
        
        lc.searchFN = 'FName3';
        lc.searchLN = '';
        lc.searchSARFUserID = '333333';
        lc.doSearch();
        
        lc.searchFN = '';
        lc.searchLN = 'LName1';
        lc.searchSARFUserID = '111111';
        lc.doSearch();       
        Test.stopTest();
    }
    
    // HELPER METHODS TO CREATE DATA
    static List<CMS_SARF__c> createSARFList(){ 
        
        CMS_SARF__c sarf1 = createSARF('FName1', 'LName1', 'email1@sarf.test', '111111');
        CMS_SARF__c sarf2 = createSARF('FName2', 'LName2', 'email2@sarf.test', '222222');
        CMS_SARF__c sarf3 = createSARF('FName3', 'LName3', 'email3@sarf.test', '333333');        
        List<CMS_SARF__c> testSarfs = new List<CMS_SARF__c>();
        testSarfs.add(sarf1);
        testSarfs.add(sarf2);
        testSarfs.add(sarf3);
        
        return testSarfs;
    }
    
    static CMS_SARF__c createSARF(String firstName, String lastName, String email, String sarfUserID){  
        
        CMS_SARF__c sarf = new CMS_SARF__c();
        sarf.First_Name__c = firstName;
        sarf.Last_Name__c = lastName;
        sarf.Email_Address__c = email;
        sarf.SARF_User_ID__c = sarfUserID;
        insert sarf;
        
        return sarf;
    }    
}
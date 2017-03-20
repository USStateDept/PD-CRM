@isTest
public class Contract_Risk_Notifications_Test {

    //Test: boolean checkNewOwner(Contract_Risk__c[] n, Contract_Risk__c[] o)
    static testMethod void testCheckNewOwner(){
       
        List<Contract_Risk__c> newList = new List<Contract_Risk__c>(); // create record for 'new trigger'
        List<Contract_Risk__c> oldList = new List<Contract_Risk__c>(); // create record for 'old trigger'
        Contract_Risk__c riskA = new Contract_Risk__c(); // create a Risk
        Contract_Risk__c riskB = new Contract_Risk__c(); // create a Risk
        
        
        
        // Test FALSE -- add same ownerID info to both old and new triggers -- owner should not change
        riskA.OwnerId = '0Pa19000000Ck6DCAS'; // set ownerID
        riskB.OwnerId = '0Pa19000000Ck6DCAS'; // set ownerID
        newList.add(riskA); // add Risk to new trigger
        oldList.add(riskB); // add Risk to old trigger
        boolean testFalse = Contract_Risk_Notifications.checkNewOwner(newList, oldList);
        System.assertEquals(false, testFalse);
        
        // Test TRUE -- change owner id for new trigger -- owner should change
        newList = new List<Contract_Risk__c>(); // clear record for 'new trigger'
        oldList = new List<Contract_Risk__c>(); // clear record for 'old trigger'
        newList.add(riskA); // add riskA to new trigger
        riskB.OwnerID = '0Pa19000000Ck6DCTY'; // change ownerID for riskB
        oldList.add(riskB); // add riskB to old trigger
        boolean testTrue = Contract_Risk_Notifications.checkNewOwner(newList, oldList);
        System.assertEquals(true, testTrue);
        Contract_Risk__c riskC = new Contract_Risk__c();
        insert(riskC);
        update(riskC);
        delete(riskC);
    }
    
    //Test: boolean checkTriggered(Contract_Risk__c[] n, Contract_Risk__c[] o)
    static testMethod void testCheckTriggered(){
        List<Contract_Risk__c> newList = new List<Contract_Risk__c>(); // create record for 'new trigger'
        List<Contract_Risk__c> oldList = new List<Contract_Risk__c>(); // create record for 'old trigger'
        Contract_Risk__c riskA = new Contract_Risk__c(); // create a Risk
        Contract_Risk__c riskB = new Contract_Risk__c(); // create a Risk
        
        // Test FALSE -- both old and new are 'TRIGGERED'
        riskA.RARisk_Status__c = 'TRIGGERED';
        riskB.RARisk_Status__c = 'TRIGGERED';
        newList.add(riskA); // add Risk to new trigger
        oldList.add(riskB); // add Risk to old trigger
        boolean testFalse = Contract_Risk_Notifications.checkTriggered(newList, oldList);
        System.assertEquals(false, testFalse);
        
        // Test FALSE -- both old and new are 'TRIGGERED'
        newList = new List<Contract_Risk__c>(); // clear record for 'new trigger'
        oldList = new List<Contract_Risk__c>(); // clear record for 'old trigger'
        riskA.RARisk_Status__c = 'MONITORING';
        riskB.RARisk_Status__c = 'MITIGATED';
        newList.add(riskA); // add Risk to new trigger
        oldList.add(riskB); // add Risk to old trigger
        testFalse = Contract_Risk_Notifications.checkTriggered(newList, oldList);
        System.assertEquals(false, testFalse);
        
        // Test FALSE -- old is 'TRIGGERED' and new is 'MONITORING'
        newList = new List<Contract_Risk__c>(); // clear record for 'new trigger'
        oldList = new List<Contract_Risk__c>(); // clear record for 'old trigger'
        riskA.RARisk_Status__c = 'MONITORING';
        riskB.RARisk_Status__c = 'TRIGGERED';
        newList.add(riskA); // add Risk to new trigger
        oldList.add(riskB); // add Risk to old trigger
        testFalse = Contract_Risk_Notifications.checkTriggered(newList, oldList);
        System.assertEquals(false, testFalse);
        
        // Test TRUE (new trigger 'Triggered' and old trigger !'Triggered') -- isTriggered should be true
        newList = new List<Contract_Risk__c>(); // clear record for 'new trigger'
        oldList = new List<Contract_Risk__c>(); // clear record for 'old trigger'
        riskA.RARisk_Status__c = 'TRIGGERED';
        riskB.RARisk_Status__c = 'MONITORING';
        newList.add(riskA); // add Risk to new trigger
        oldList.add(riskB); // add Risk to old trigger
        boolean testTrue = Contract_Risk_Notifications.checkTriggered(newList, oldList);
        System.assertEquals(true, testTrue);
    }
}
@isTest
public class Contract_Risk_Field_Reset_Test {

    //Test: String resetRiskType(Contract_Risk__c[] n, Contract_Risk__c[] o)
    static testMethod void resetRiskType(){
        
        List<Contract_Risk__c> newList = new List<Contract_Risk__c>(); // create record for 'new trigger'
        List<Contract_Risk__c> oldList = new List<Contract_Risk__c>(); // create record for 'old trigger'
        Contract_Risk__c riskA = new Contract_Risk__c(); // create a Risk
        Contract_Risk__c riskB = new Contract_Risk__c(); // create a Risk
       
        //Test Project Reset -- User changed Risk to Program, Project should reset to null
        riskA.Type_of_Risk__c = 'Program'; // set risk type
        riskB.Type_of_Risk__c = 'Project'; // set risk type
        newList.add(riskA); // add Risk to new trigger
        oldList.add(riskB); // add Risk to old trigger
        String testTypeReset = Contract_Risk_Field_Reset.resetRiskType(newList, oldList);
        System.assertEquals('ProjectReset', testTypeReset);
        
        //Test Program Reset -- User changed Risk to Project, Program should reset to null
        newList = new List<Contract_Risk__c>(); // clear record for 'new trigger'
        oldList = new List<Contract_Risk__c>(); // clear record for 'old trigger'
        riskA.Type_of_Risk__c = 'Project'; // set risk type
        riskB.Type_of_Risk__c = 'Program'; // set risk type
        newList.add(riskA); // add Risk to new trigger
        oldList.add(riskB); // add Risk to old trigger
        testTypeReset = Contract_Risk_Field_Reset.resetRiskType(newList, oldList);
        System.assertEquals('ProgramReset', testTypeReset);
        
        //Test Risk Type Reset -- User changed Risk to Project, Program and Project should reset to null
        newList = new List<Contract_Risk__c>(); // clear record for 'new trigger'
        oldList = new List<Contract_Risk__c>(); // clear record for 'old trigger'
        riskA.Type_of_Risk__c = ''; // set risk type to null
        riskB.Type_of_Risk__c = 'Program'; // set risk type
        newList.add(riskA); // add Risk to new trigger
        oldList.add(riskB); // add Risk to old trigger
        testTypeReset = Contract_Risk_Field_Reset.resetRiskType(newList, oldList);
        System.assertEquals('TypeReset', testTypeReset);    
    }
}
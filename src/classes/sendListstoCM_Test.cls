@isTest
private class sendListstoCM_Test
{

	static testMethod void testController() {

		List<Contact> cList = [select id from Contact];
		sendListstoCM ctrl  = new sendListstoCM(new ApexPages.StandardSetController(cList));
		ctrl.setState('setState');
		ctrl.getState();
	}
    
    static testMethod void createList() {
        List<Interest__c> theList = new List<Interest__c>();
        ApexPages.StandardSetController sc = new ApexPages.StandardSetController(theList);
        sendListstoCM crtl = new sendListstoCM(sc);
        crtl.createList();
    }
}
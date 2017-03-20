@isTest
private class TestUpdateSpouse {
	
	@isTest static void test_method_one() {
		//List <Contact> lstCon = new List <Contact>();
		Contact con1 = new Contact();
		con1.FirstName = 'Test1';
		con1.LastName = 'Test1';
		//lstCon.add(con1);
		insert con1;

		Contact con2 = new Contact();
		con2.FirstName = 'Test2';
		con2.LastName = 'Test2';
		//lstCon.add(con2);

		//insert lstCon;
		insert con2;

		con1.Spouse__c = con2.Id;
		update con1;

	}
	
	@isTest static void test_method_two() {
//		List <Contact> lstCon = new List <Contact>();
		Contact con1 = new Contact();
		con1.FirstName = 'Test1';
		con1.LastName = 'Test1';
//		lstCon.add(con1);
		insert con1;

		Contact con2 = new Contact();
		con2.FirstName = 'Test2';
		con2.LastName = 'Test2';
//		lstCon.add(con2);
		insert con2;

		Contact con3 = new Contact();
		con3.FirstName = 'Test3';
		con3.LastName = 'Test3';
		//lstCon.add(con3);
		insert con3;

//		insert lstCon;

		con1.Spouse__c = con2.Id;
		update con1;

		con1.Spouse__c = con3.Id;
		update con1;

	}
	
}
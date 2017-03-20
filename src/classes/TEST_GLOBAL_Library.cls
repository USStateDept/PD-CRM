@isTest
public class TEST_GLOBAL_Library
{
	static testMethod void jitScrub()
	{
		Test.startTest();
		
		System.assertEquals( 'test', GLOBAL_Library.jitScrub( '<span test="test">test</span>' ));
		System.assertEquals( 'test', GLOBAL_Library.jitScrub( '<span>test</span>' ));
	}
	
	static testMethod void getContentType()
	{
		Test.startTest();
		
		File_Extension__c testExntesion = new File_Extension__c();
		testExntesion.Name = 'test Content';
		testExntesion.Value__c = 'content/test';
		insert testExntesion;
		
		System.assertEquals( 'content/test', GLOBAL_Library.getContentType( 'test Content' ));
		System.assertEquals( 'test Content2', GLOBAL_Library.getContentType( 'test Content2' ));
	}
	
	
	static testMethod void sendEmail()
	{
		Test.startTest();
		
		String emailAddress = 'test@state.gov.test';
		String emailType = 'test';
		String emailSubject = 'test email';
		String emailBody = 'test body';
		
		GLOBAL_Library.sendEmail( emailAddress, emailType, emailSubject, emailBody );
	}
	
	
	static testMethod void getPicklistValues()
	{
		Test.startTest();
		
		Set<String> testList = new Set<String>{ 'Contacted', 'Open', 'Qualified', 'Unqualified' };
		
		List<SelectOption> testOptions = GLOBAL_Library.getPicklistValues( new Lead(), 'Status' );
		
		for (SelectOption option : testOptions )
		{
			System.assert( testList.contains( option.getValue() ));
		}
	}
	
	
	static testMethod void getPermissionset()
	{
		Test.startTest();
		
		//System.assertEquals( 'User Manager', GLOBAL_Library.getPermissionset( 'Integrator Functional', 'Case' ));
	}
	
	
	static testMethod void createObj()
	{
		Test.startTest();
		
		Case testObj = (Case) GLOBAL_Library.createObj( 'Case', null );
		
		System.assertEquals( 'Test value', testObj.SuppliedName );
		
		Map<String, String> testMap = new Map<String, String>();
		testMap.put( 'SuppliedName', 'test' );
		
		Case testObj2 = (Case) GLOBAL_Library.createObj( 'Case', testMap );
		
		System.assertEquals( 'test', testObj2.SuppliedName );
	}
	
	
	static testMethod void getFieldsSOQL()
	{
		Test.startTest();
		
		String soqlStr = GLOBAL_Library.getFieldsSOQL( 'Case' );
		
		System.assert( soqlStr.contains( 'SuppliedName' ));
	}
}
public class AmericanSpacesUserImport 
{
	private Document userData;
	
	public AmericanSpacesUserImport()
	{
		userData = [SELECT Body, Description FROM Document WHERE name = 'American Spaces User Data' ];
	}
	
	public void processUsers()
	{
		String[] lines = userData.Body.toString().split('\n', -1);
		Map<String, Id> postContactList = new Map<String, Id>();
		
		List<American_Spaces_Mission_Contact__c> asmcs = new List<American_Spaces_Mission_Contact__c>();

		for (Integer i = Integer.valueof( userData.Description ); i < lines.size(); i++)
		{
			String[] inputs = lines[i].split(',', -1);

			if (inputs.size() == 1)
			{
				break;
			}
			
			
			String region     = replaceComma( inputs[0] );
			String country    = replaceComma( inputs[1] );			
			String post       = replaceComma( inputs[2] );
			String lastName   = replaceComma( inputs[3] );
			String firstName  = replaceComma( inputs[4] );
			String emailOne   = replaceComma( inputs[5] );
			
			try
			{
				Id postID = [SELECT id FROM American_Spaces_Post_Contacts__c WHERE Country__c = :country and Region__c = :region and Name = :post limit 1].id;
				postContactList.put( region + country + post, postID );
				
				American_Spaces_Mission_Contact__c asmc = new American_Spaces_Mission_Contact__c();
				asmc.Managing_Post_City__c = postID;
				asmc.First_Name__c = firstName;
				asmc.Last_Name__c = lastName;
				asmc.Email_1__c = emailOne;
				asmcs.add( asmc );
			}
			catch( Exception e )
			{
				System.debug( 'Following does not exist in the database -' );
				System.debug( 'Region -' + region + ', Country - ' + country + ', post - ' + post );
			}

			if (i == Integer.valueof( userData.Description ) + 90)
			{
				userData.Description = String.valueOf( i + 1 );
				break;
			}
			else if (i == lines.size() - 2)
			{
				userData.Description = String.valueOf( i + 1 );
				break;
			}
		}
		
		insert( asmcs );
		update userData;
	}


	public String replaceComma( String str )
	{
		return str.replaceAll( 'COMMA', ',' ).trim(); 
	}
	
	
	public static testMethod void testAmericanSpacesUserImport()
    {             
        Test.startTest();
        
        American_Spaces_Post_Contacts__c testRecord = new American_Spaces_Post_Contacts__c();
        testRecord.Country__c = 'Equatorial Guinea';
        testRecord.Region__c = 'AF';
        testRecord.Name = 'Malabo';
        insert testRecord;
        
        String testCSV = '';
        testCSV += 'AF,Equatorial Guinea,Malabo,White,Ashley M,WhiteAM3@state.gov,\n';
        testCSV += 'AF,Equatorial Guinea,Malabo,White,Shaleen M ,WhiteSM3@state.gov,\n';
        testCSV += 'AF,Equatorial Guinea,Malabo,Yacoob,Melissa J.,yacoobmj@state.gov,\n';
        testCSV += 'AF,Equatorial Guinea,Malabo,Yasko,Nataliia,YaskoNV@state.gov,\n';
        testCSV += 'AF2,Equatorial Guinea,Malabo,Zakula,Nadica,ZakulaN@state.gov,\n';

		ID folderID = [SELECT id FROM Folder WHERE name = 'Shared Documents'].id;

        Document testDoc = new Document();
        testDoc.Name = 'American Spaces User Data';
        testDoc.Body = Blob.valueOf( testCSV );
        testDoc.Description = '1';
        testDoc.FolderId = folderID;
        insert testDoc;
        
        AmericanSpacesUserImport asui = new AmericanSpacesUserImport();
        asui.processUsers();
    }
}
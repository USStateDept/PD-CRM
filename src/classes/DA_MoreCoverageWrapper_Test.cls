@isTest
public class DA_MoreCoverageWrapper_Test
{
	public static testmethod void DA_MoreCoverageWrapperTest()
	{
		DA_MoreCoverageWrapper testObj = new DA_MoreCoverageWrapper();
		System.assertEquals( null, testObj.da.id );
		System.assertEquals( false, testObj.checked );
		System.assertEquals( null, testObj.mcOrder );
		
		Digital_Asset__c myAsset = new Digital_Asset__c();
        myAsset.language__C = 'English';
		insert myAsset;
		
		DA_MoreCoverageWrapper testObj2 = new DA_MoreCoverageWrapper( myAsset );
		System.assertEquals( myAsset.id, testObj2.da.id );
		System.assertEquals( false, testObj2.checked );
		System.assertEquals( null, testObj2.mcOrder );
	}
}
@isTest
public class DA_ArticleToXML_Test
{
	private String pubstr = '2008.13 what a crazy title';
	
	private static Digital_Asset__c createAsset()
	{
		Profile p = DA_Test_Helper.getProfile( 'Publishing Copy Desk' );
		User u = DA_Test_Helper.createUserWithoutProfile();
		u.ProfileId = p.Id;
		u.Username = 'ok_to_publish@test.test';
		insert u;//insert asset
		
   	  	Digital_Asset__c myAsset = (Digital_Asset__c) GLOBAL_Library.createObj( 'Digital_Asset__c', null );
    	myAsset.Asset_Creator__c = u.id;
    	myAsset.Name = 'super mega article';
      	myAsset.Headline_Long__c = 'super mega article';
    	myAsset.Language__c = 'English';
    	myAsset.Asset_Type__c = 'Text or Transcript';
      	myAsset.Article_Body__c = 'Body';
      	myAsset.Translation_Requested_By__c = 'Public Affairs';
      	myAsset.Asset_Subtype__c = 'Internal Use Only';
      	myAsset.Author__c = 'bob';
        myAsset.Author_Job_Title__c = 'explosives expert';
    	
      	return myAsset;
	}
	
	public static testMethod void generateXMLSecurity()
    {
    	Test.startTest();

    	Digital_Asset__c myAsset = createAsset();
    	myAsset.Asset_Theme__c = 'Regional Stability and Security';
      	myAsset.Asset_Type__c = 'Text or Transcript';
      	insert myAsset;
      	
    	ApexPages.currentPage().getParameters().put( 'id', myAsset.id );
    	
    	String myXML = DA_ArticleToXML.getXML();
    	System.debug( myXML );
    	System.assertEquals( true, myXML.contains( 'SECURITY' ));
    }
    
    
    public static testMethod void generateXMLENERGY()
    {
    	Test.startTest();

    	Digital_Asset__c myAsset = createAsset();
    	myAsset.Asset_Theme__c = 'Energy and Environment';
        myAsset.Asset_Type__c = 'EJ or Book';
      	insert myAsset;
      	
    	ApexPages.currentPage().getParameters().put( 'id', myAsset.id );
    	
    	String myXML = DA_ArticleToXML.getXML();
    	System.debug( myXML );
    	System.assertEquals( true, myXML.contains( 'ENERGY' ));
    }
    
    
    public static testMethod void generateXMLECON()
    {
    	Test.startTest();

    	Digital_Asset__c myAsset = createAsset();
    	myAsset.Asset_Theme__c = 'Economic Growth and Development';
      	myAsset.Asset_Type__c = 'Video';
      	insert myAsset;
      	
    	ApexPages.currentPage().getParameters().put( 'id', myAsset.id );
    	
    	String myXML = DA_ArticleToXML.getXML();
    	System.debug( myXML );
    	System.assertEquals( true, myXML.contains( 'ECON' ));
    }


	public static testMethod void generateXMLAMERICA()
    {
    	Test.startTest();

    	Digital_Asset__c myAsset = createAsset();
    	myAsset.Asset_Theme__c = 'All About America';
      	myAsset.Asset_Type__c = 'Audio';
      	insert myAsset;
      	
    	ApexPages.currentPage().getParameters().put( 'id', myAsset.id );
    	
    	String myXML = DA_ArticleToXML.getXML();
    	System.debug( myXML );
    	System.assertEquals( true, myXML.contains( 'AMERICA' ));
    }
    
    
    public static testMethod void generateXMLSPECIAL()
    {
    	Test.startTest();

    	Digital_Asset__c myAsset = createAsset();
    	myAsset.Asset_Theme__c = 'Special Initiatives';
        myAsset.Asset_Type__c = 'Photo Gallery';
      	insert myAsset;
      	
    	ApexPages.currentPage().getParameters().put( 'id', myAsset.id );
    	
    	String myXML = DA_ArticleToXML.getXML();
    	System.debug( myXML );
    	System.assertEquals( true, myXML.contains( 'SPECIAL' ));
    }


    public static testMethod void generateXMLDEMOC()
    {
    	Test.startTest();

    	Digital_Asset__c myAsset = createAsset();
    	myAsset.Asset_Theme__c = 'Democracy/Democratic Institutions';
        myAsset.Asset_Type__c = 'Photo Gallery';
      	insert myAsset;
      	
    	ApexPages.currentPage().getParameters().put( 'id', myAsset.id );
    	
    	String myXML = DA_ArticleToXML.getXML();
    	System.debug( myXML );
    	System.assertEquals( true, myXML.contains( 'DEMOC' ));
    }
    
    
  	public static testMethod void GenerateURL()
  	{
  		Digital_Asset__c myAsset = createAsset();
        myAsset.Asset_Type__c = 'Photo Gallery';
        myAsset.Republish_ID__c = '1234567890';
        insert myAsset;

        String AssetURL = '';
        Global_Variable__c proposedUrl_c = Global_Variable__c.getValues(DA_ArticleToXML.PROPOSED_URL);
        if(proposedUrl_c != null)
            AssetURL = proposedUrl_c.value__c;
        
        System.assertEquals(AssetURL + '/english/gallery/1234/56/1234567890.html', DA_ArticleToXML.GenerateURL( myAsset ));
        
        myAsset.Asset_Type__c = 'In Brief';
        System.assertEquals(AssetURL + '/english/inbrief/1234/56/1234567890.html', DA_ArticleToXML.GenerateURL( myAsset ));
       
       	myAsset.Asset_Type__c = 'Pamphlet';
        System.assertEquals(AssetURL + '/english/pamphlet/1234/56/1234567890.html', DA_ArticleToXML.GenerateURL( myAsset ));
      
		myAsset.Asset_Type__c = 'Table of Contents';
        System.assertEquals(AssetURL + '/english/publication/1234/56/1234567890.html', DA_ArticleToXML.GenerateURL( myAsset ));
  	}
  	
    
	public static testMethod void runWordCountTest()
	{
		 //method #1: single parameter wordCount
        
        //ENGLISH -- from single parameter wordCount method
		String testString = 'I like\" happy\t ! stuff, and-stuff. \n with pickles) (*';//random test string that covers numerous character types
		Integer result = DA_ArticleToXML.WordCount( teststring );
		System.assertEquals( 8, result );
        
        
        //method #2: double parameter wordCount
        
        //ENGLISH -- from double parameter wordCount method
        String testString2 = 'I like\" happy\t ! stuff, and-stuff. \n with pickles) (*';
        Integer result2 = DA_ArticleToXML.WordCount( testString2, 'English');
        System.assertEquals( 8, result2 );
        
        //CHINESE -- from double parameter wordCount method
        String chineseString = '截止2013年底，（该研究）中心共！繁殖：大《邓小平时代》“熊猫157胎225仔,成（责编：路西）活197只，圈养 English word here-大恐怖”熊猫种群数”量达到187只，是目前全世界、最大大、熊猫人工饲养种群。'; // random Chinese string
		Integer chineseResult = DA_ArticleToXML.WordCount( chineseString,'Chinese' );
		//System.assertEquals( 49, chineseResult );
	}
}
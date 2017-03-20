public with sharing class DA_Tab 
{
  //vf and controller inspired by Jeff Douglas' blog
  public static final String ASSET_DT_GT_DISPLAY_VAL = 'Greater Than';
  public static final String ASSET_DT_LT_DISPLAY_VAL = 'Less Than';
  public static final String ASSET_SORT_DIR_DEFAULT = 'ASC';
  public static final String ASSET_SORT_FIELD_DEFAULT = 'Name';
  public static final String ASSET_DT_OPERATOR_DEFAULT = '<';
  public static final String ASSET_SOQL_LIMIT_DEFAULT = ' limit 100';
  public String isMC;
  public List<DA_MoreCoverageWrapper> mcList {get;set;}
  public List<DA_MoreCoverageWrapper> selectedMC {
        get {
            if (selectedMC == null) selectedMC = new List<DA_MoreCoverageWrapper>();
            return selectedMC;
        }
        set;
    }  
  
  

	public boolean displayPopup {get; set;}     
	
	public void closePopup() {        
	    displayPopup = false;
	    mcList = null;
	    selectedMC = null;  
	}     
	public void showPopup() {        
	    displayPopup = true;    
	}
	
	
  
  public String assetdatetimeoperator {get;set;}
  
  // the soql without the order and limit
  private String soql {get;set;}
  // the collection of assets to display
  public List<Digital_Asset__c> assets {get;set;}
 
  // the current sort direction. defaults to asc
  public String sortDir {
    get  { if (sortDir == null) {  sortDir = ASSET_SORT_DIR_DEFAULT; } return sortDir;  }
    set;
  }
 
  // the current field to sort by. defaults to last name
  public String sortField {
    get  { if (sortField == null) {sortField = ASSET_SORT_FIELD_DEFAULT; } return sortField;  }
    set;
  }
 
  // format the soql for display on the visualforce page
  public String debugSoql {
    get { return soql + ' order by ' + sortField + ' ' + sortDir + ASSET_SOQL_LIMIT_DEFAULT ; }
    set;
  }
 
  // init the controller and display some sample data when the page loads
  public DA_Tab(ApexPages.StandardController stdController) {
    soql = 'select Id, Name, Language__c, Search_Keywords__c, Status__c, Author__c, Asset_Type__c, Asset_Theme__c, Asset_Date_Time__c, Published_URL_Formula__c from Digital_Asset__c';
    assetdatetimeoperator = ASSET_DT_OPERATOR_DEFAULT;
    isMC = 'false';
    selectedMC = null;
    mcList = null; 
    assets = null;
    //runQuery();
  }
 
  // toggles the sorting of query from asc<-->desc
  public void toggleSort() {
    // simply toggle the direction
    sortDir = sortDir.equals('ASC') ? 'DESC' : 'ASC';
    // run the query again
    runQuery();
  }
 
  // runs the actual query
  public void runQuery() {
 
    try {
      assets = Database.query(soql + ' order by ' + sortField + ' ' + sortDir + ASSET_SOQL_LIMIT_DEFAULT);
      
      if(isMC == 'true')
      {
      	
      	if (mcList == null) {
            mcList = new List<DA_MoreCoverageWrapper>();
        } else {
            mcList.clear();
        }

        for(Digital_Asset__c da : assets) {
            DA_MoreCoverageWrapper mcWrapper = new DA_MoreCoverageWrapper(da);
            mcList.add(mcWrapper);
        }
      	
      }
      
      
      
    } catch (Exception e) {
      ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
    }
 
  }
 
  // runs the search with parameters passed via Javascript
  public PageReference runSearch() {
 	Datetime dt;
    String headline = Apexpages.currentPage().getParameters().get('headline');
    String language = Apexpages.currentPage().getParameters().get('language');
    String author = Apexpages.currentPage().getParameters().get('author');
    String status = Apexpages.currentPage().getParameters().get('status');
    String assettype = Apexpages.currentPage().getParameters().get('assettype');
    String assettheme = Apexpages.currentPage().getParameters().get('assettheme');
    String searchkeywords = Apexpages.currentPage().getParameters().get('searchkeywords');
    String assetdatetime = Apexpages.currentPage().getParameters().get('assetdatetime');
    isMC = Apexpages.currentPage().getParameters().get('isMC');
    if(isMC == null || isMC == '')
    	isMC = 'false';
 
    soql = 'select Id, Name, Language__c, Search_Keywords__c, Status__c, Author__c, Asset_Type__c, Asset_Theme__c, Asset_Date_Time__c,Published_URL_Formula__c from Digital_Asset__c where Name != null';
    if (!headline.equals(''))
      soql += ' and Name LIKE \'%'+String.escapeSingleQuotes(headline)+'%\'';
    if (!author.equals(''))
      soql += ' and Author__c LIKE \'%'+String.escapeSingleQuotes(author)+'%\'';
    if (!assettype.equals(''))
      soql += ' and Asset_Type__c = \''+assettype+'\'';
    if (!assettheme.equals(''))
      soql += ' and Asset_Theme__c = \''+assettheme+'\'';
    if (!searchkeywords.equals(''))
      soql += ' and Search_Keywords__c LIKE \'%'+String.escapeSingleQuotes(searchkeywords)+'%\'';
    if (!status.equals(''))
      soql += ' and Status__c = \''+status+'\'';  
    if (!language.equals(''))
      soql += ' and Language__c = \''+language+'\'';
    if (!assetdatetime.equals(''))
    {
      dt = DateTime.parse(assetdatetime);
      soql += ' and Asset_Date_Time__c'+ assetdatetimeoperator + dt.format('yyyy-MM-dd\'T\'hh:mm:ss\'Z\'');
    }
    // run the query again
    runQuery();
 
    return null;
  }
 
  // use apex describe to build the picklist values: languages, status, asset_type, asset_theme
  public List<String> languages {
    get {
      if (languages == null) {
 
        languages = new List<String>();
        Schema.DescribeFieldResult field = Digital_Asset__c.Language__c.getDescribe();
 
        for (Schema.PicklistEntry f : field.getPicklistValues())
          languages.add(f.getLabel());
 
      }
      return languages;          
    }
    set;
  }
  
  public List<String> status {
    get {
      if (status == null) {
 
        status = new List<String>();
        Schema.DescribeFieldResult field = Digital_Asset__c.Status__c.getDescribe();
 
        for (Schema.PicklistEntry f : field.getPicklistValues())
          status.add(f.getLabel());
 
      }
      return status;          
    }
    set;
  }
  
  public List<String> assettype {
    get {
      if (assettype == null) {
 
        assettype = new List<String>();
        Schema.DescribeFieldResult field = Digital_Asset__c.Asset_Type__c.getDescribe();
 
        for (Schema.PicklistEntry f : field.getPicklistValues())
          assettype.add(f.getLabel());
 
      }
      return assettype;          
    }
    set;
  }
  
  public List<String> assettheme {
    get {
      if (assettheme == null) {
 
        assettheme = new List<String>();
        Schema.DescribeFieldResult field = Digital_Asset__c.Asset_Theme__c.getDescribe();
 
        for (Schema.PicklistEntry f : field.getPicklistValues())
          assettheme.add(f.getLabel());
 
      }
      return assettheme;          
    }
    set;
  }
  
  public List<SelectOption> assetdatetimeoperators
  {
  	get 
  	{
  		List<selectOption> assetdatetimeoperators = new List<selectOption>(); 
	    assetdatetimeoperators.add(new SelectOption('>', ASSET_DT_GT_DISPLAY_VAL)); 
	    assetdatetimeoperators.add(new SelectOption('<', ASSET_DT_LT_DISPLAY_VAL));
	     	
  		return assetdatetimeoperators;
  	}
  	set;
  
  } 
  

}
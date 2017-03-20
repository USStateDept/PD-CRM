public class CMS_AdminController
{
	private ApexPages.StandardController std;
	public String functionalRole{ get; set; }
	public String projectNumber{ get; set; }
	public Id propertyID{ get; set; }
	
	public CMS_AdminController()
	{
		functionalRole = '';
		projectNumber = '';
	}


    public List<CMS_Admin_Property__c> getFunctionalRoles()
    {
    	return [SELECT Id, Type__c, Value__c FROM CMS_Admin_Property__c WHERE Type__c = 'Functional Roles'];
    }
    
    
    public List<CMS_Admin_Property__c> getProjectNumbers()
    {
    	return [SELECT Id, Type__c, Value__c FROM CMS_Admin_Property__c WHERE Type__c = 'Project Number'];
    }
    
    
    public PageReference addFunctionalRole()
    {
    	CMS_Admin_Property__c adminProperty = new CMS_Admin_Property__c();
    	adminProperty.Value__c = functionalRole;
    	adminProperty.Type__c = 'Functional Roles';
    	
    	insert adminProperty;
    	
    	functionalRole = '';

    	return null;
    }
    
    public PageReference addProjectNumber()
    {
    	CMS_Admin_Property__c adminProperty = new CMS_Admin_Property__c();
    	adminProperty.Value__c = projectNumber;
    	adminProperty.Type__c = 'Project Number';
    	
    	insert adminProperty;
    	
    	projectNumber = '';

    	return null;
    }
    
    
    public PageReference deleteAction()
	{
		CMS_Admin_Property__c adminProperty = [select id FROM CMS_Admin_Property__c WHERE id = :propertyID];
		delete adminProperty;
		
		return null;
	}
	
	
	public static testMethod void testCMS_AdminController()
    {
    	Test.startTest();
    	
    	CMS_AdminController ac = new CMS_AdminController();
    	ac.getFunctionalRoles();
    	ac.getProjectNumbers();
    	
    	ac.functionalRole = 'test';
    	ac.projectNumber = 'test';
    	
    	ac.addFunctionalRole();
    	ac.addProjectNumber();
    	
    	Id idInfo = [select id FROM CMS_Admin_Property__c WHERE Value__c = 'test' AND Type__c = 'Project Number'].id;
    	ac.propertyID = idInfo;
    	
    	ac.deleteAction();
    }
}
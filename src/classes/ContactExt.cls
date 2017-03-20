public with sharing class  ContactExt {
    private Contact cont;
    ApexPages.StandardController stdController;
    public ContactExt (ApexPages.StandardController stdController) {
        this.stdController = stdController;
	        this.cont = (Contact)stdController.getRecord();
        Profile P = [SELECT Id, name FROM Profile WHERE id = :System.UserInfo.getProfileId() LIMIT 1 ];
	 }
    
    public PageReference save() {
        PROFILE p = [SELECT id from Profile where Name = 'PD CRM' LIMIT 1];
        try {
            if (this.cont != null && this.cont.AccountId == null && System.userinfo.getProfileId() == p.id){
                    this.cont.AccountId = [SELECT id,Name from Account where Name='U.S. Mission Indonesia' LIMIT 1].id;
                    this.cont.Region__c  = 'EAP'; 
        	}
        } catch (QueryException qe){
            //this is okay
        }
        
        
        return this.stdController.save();
    }
    
    public PageReference redirectView() {
        Profile P = [SELECT Id, name FROM Profile WHERE id = :System.UserInfo.getProfileId() LIMIT 1 ];
         PageReference pg =  new PageReference('/apex/ContactView?nooverride=1');
 
        Map<String, String> m = pg.getParameters();
        m.putAll(ApexPages.currentPage().getParameters());
        if (p.Name != 'PD CRM'){
            pg = new PageReference('/' + m.get('id') + '?nooverride=1');
            m.remove('id');
        }
        pg.setRedirect(true);
        return pg;
    }
    public PageReference redirectEdit() {
        Profile P = [SELECT Id, name FROM Profile WHERE id = :System.UserInfo.getProfileId() LIMIT 1 ];
        String i = ApexPages.currentPage().getParameters().get('id');
		 PageReference pg;
        if (i != null && i.length() > 0){
       				 pg = new PageReference('/' + i + '/e');
           } else {
              pg = new PageReference('/'  + Contact.SObjectType.getDescribe().getKeyPrefix() +  '/e');
           }
        if (p.Name == 'PD CRM'){
            if (i == null || i.length() == 0){
                pg = new PageReference('/apex/ContactCreate');
            } else {
           		pg =  new PageReference('/apex/ContactEdit');
            }
        } 
            
        Map<String, String> m = pg.getParameters();
        m.putAll(ApexPages.currentPage().getParameters()); 
        m.put('nooverride', '1');
        pg.setRedirect(true);
        return pg;
        
    }
    
}
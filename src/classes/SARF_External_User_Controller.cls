public with sharing class SARF_External_User_Controller {
    
    public String firstName {get; set;}
    public String lastName {get; set;}
    public String email {get; set;}
    public String phone {get; set;}
    public String jobtitle {get; set;}
    public String bureau {get; set;}
    public String comments {get; set;}
    
    public SARF_External_User_Controller(){}
    
    public PageReference save(){
        PageReference pageRef = ApexPages.currentPage();
        System.debug('Entered save with values: ' + firstName + lastName + email + phone+ jobtitle + bureau);
        SARF_Starter_Controller sctrl = new SARF_Starter_Controller(firstName, lastName, email, phone, jobtitle, bureau, '');
        if(sctrl.formValidated() && sctrl.noSarfFound()){
            System.debug('form is validated');
            sctrl.createSARF();
            pageRef =  Page.SARF_Confirmation;
        }else{
            sctrl.displayError();
        }
        return pageRef;
    }
    
    public List<SelectOption> getDepartments() {
        List<SelectOption> deptOptions = new List<SelectOption>();
        deptOptions.add(new SelectOption('','--None--')); //Default option
        
        List<SelectOption> officesList = GLOBAL_Library.getPicklistValues(new CMS_SARF__c(), 'Office__c');
        deptOptions.addAll(officesList);
        
        return deptOptions;
    }
}
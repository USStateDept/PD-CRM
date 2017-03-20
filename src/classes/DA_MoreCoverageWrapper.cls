public with sharing class DA_MoreCoverageWrapper {
    public Boolean checked{ get; set; }
    public Integer mcOrder{get;set;}
    public Digital_Asset__c da { get; set;}
 
    public DA_MoreCoverageWrapper(){
        da = new Digital_Asset__c();
        checked = false;
        mcOrder = null;
    }
 
    public DA_MoreCoverageWrapper(Digital_Asset__c daSelected){
        da = daSelected;
        checked = false;
        mcOrder = null;
    }
 
}
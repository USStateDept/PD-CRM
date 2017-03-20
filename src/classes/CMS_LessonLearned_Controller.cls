public class CMS_LessonLearned_Controller {
    private ApexPages.StandardController std;
    public CMS_Lesson_Learned__c lessonLearned { get; set; }
    public String myPermissionset{ get; set; }
    public boolean editable{ get; set; }
    public boolean readOnly{ get; set; }
    
    public CMS_LessonLearned_Controller(ApexPages.StandardController stdCtrl) {
        std = stdCtrl;
        editable = false;
        readOnly = true;
        lessonLearned = (CMS_Lesson_Learned__c) stdCtrl.getRecord();
        
        if(lessonLearned.Id == null) {
            lessonLearned.Date_Identified__c = Date.today();
            lessonLearned.Situation__c = 'What occurred?';
            lessonLearned.Recommendation__c = 'How do you recommend we improve in the future?';  
        }
        
        myPermissionset = GLOBAL_Library.getPermissionset(UserInfo.getName(), 'CMS_Lesson_Learned__c');
         
        if(myPermissionset != null && (myPermissionset.equalsIgnoreCase('CMS Project Manager')
                                      || myPermissionset.equalsIgnoreCase('Contract Manager'))) {
        	editable = true;
			readOnly = false;
        }
        
    }
}
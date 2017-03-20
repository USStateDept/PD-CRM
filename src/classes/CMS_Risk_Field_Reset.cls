public class CMS_Risk_Field_Reset{
  
  //Reset conditional values to null if certain fields are completed/selected
  	
    //RISK TYPE - Project & Program
    public static String resetRiskType(CMS_Risk__c[] n, CMS_Risk__c[] o){
    	String reset = NULL;
        for (CMS_Risk__c x: n){//for each Risk in new trigger
           for (CMS_Risk__c y: o){ //iterate through old trigger
               if (x.id == y.id){ //if record id is in both new and old
       				 if (x.Type_of_Risk__c == 'Program' && y.Type_of_Risk__c == 'Project'){ //if new Risk is Program, changed from Project
            			x.CMS_Project__c = NULL; //set CMS Project field to NULL
       					reset = 'ProjectReset';
        			}else if(x.Type_of_Risk__c == 'Project' && y.Type_of_Risk__c == 'Program'){ //else if new Risk is Project, changed from Program
            			x.Program__c = NULL; //set Program picklist field to NULL
            			x.Program_Other__c = NULL; //set Program 'Other' text field to NULL
            			reset = 'ProgramReset';
        			}else{
            			reset = 'TypeReset';
        			}
               }
           }
        }
        return reset;
    }
}
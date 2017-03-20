public with sharing class sendListstoCM{

//    webservice static void sendListstoCM(){
//      new ListViewService().getContactsListViews(); 
//      
//        
//   }
//   
   private String state = 'no';
   public void setState(String n) {
        state = n;
    }
            
    public String getState() {
        return state;
    }

    public sendListstoCM(ApexPages.StandardSetController stdController) {
         
     }
    
    public void createList(){
        //new ListViewService().getContactsListViews();     
        ListViewBatch batch = new ListViewBatch();
		batch.sessionId = UserInfo.getSessionId();
      	database.executeBatch(batch); 
    }
    
}
public class SARF_History {
    
    // Previous SARF
    private CMS_SARF__c prev;
    private CMS_SARF__c curr;
    
    // Previous SARF history
   	private String prevHistory;
    
    // Appended history String to account for any changes made since previous SARF
    private String history;
    private DateTime timestamp;
    String strConvertedDate;
    
    public SARF_History(CMS_SARF__c previousSARF, CMS_SARF__c currentSARF){
        curr = currentSARF;
        prev = previousSARF;
        prevHistory = prev.SARF_History__c;
        history = ' ';
    }
    
    public void createHistory(){
        
        //Datetime GMTDate = Datetime.now();
		timestamp = datetime.now();
        strConvertedDate = 
  		timestamp.format('MM/dd/yyyy h:mm a', 
                 'America/New_York');
        
        //Identify changed field values
        //First name
        if(!curr.First_Name__c.equalsIgnoreCase(prev.First_Name__c)){
            history += ' First Name changed from ' + prev.First_Name__c + ' to ' + curr.First_Name__c + '\n';
        }
        //Last name
        if(!curr.Last_Name__c.equalsIgnoreCase(prev.Last_Name__c)){
            history += ' Last Name changed from ' + prev.Last_Name__c + ' to ' + curr.Last_Name__c + '\n';
        }
        //Email address
        if(!curr.Email_address__c.equalsIgnoreCase(prev.Email_address__c)){
            history += ' Email changed from ' + prev.Email_address__c + ' to ' + curr.Email_address__c + '\n';
        }
        //Phone number
        if(curr.phone_number__c != NULL){
			if(!curr.phone_number__c.equalsIgnoreCase(prev.phone_number__c)){
            	history += ' Phone Number changed from ' + prev.phone_number__c + ' to ' + curr.phone_number__c + '\n';
            }
    	}
        //Employee Type
        if(curr.employee_type__c != NULL){
        	if(!curr.employee_type__c.equalsIgnoreCase(prev.employee_type__c)){
        	    history += ' Employee Type changed from ' + prev.employee_type__c + ' to ' + curr.employee_type__c + '\n';
        	}
        }
        //Position title
        if(curr.title__c != NULL){
        	if(!curr.title__c.equalsIgnoreCase(prev.title__c)){
            	history += ' Position Title changed from ' + prev.title__c + ' to ' + curr.title__c + '\n';
        	}
        }
        //Office/Bureau
        if(curr.office__c != NULL){
        	if(!curr.office__c.equalsIgnoreCase(prev.office__c)){
            	history += ' Office/Bureau changed from ' + prev.office__c + ' to ' + curr.office__c + '\n';
        	}
        }
        //Expiration date
        DateTime currExpDate = curr.expiration_date__c;
        String convertedCurrDate = '';
        if(currExpDate != NULL){
            convertedCurrDate = (currExpDate + 1).format('MM/dd/yyyy');
        }
        DateTime prevExpDate = prev.expiration_date__c;
        String convertedPrevDate = '';
        if(prevExpDate != NULL){
            convertedPrevDate = (prevExpDate + 1).format('MM/dd/yyyy');
        }
        if(currExpDate != NULL){            
            if(!convertedCurrDate.equals(convertedPrevDate)){
            	history += 'Expiration date changed to ' + convertedCurrDate + '\n';
        	}
        }
        
        //Role
        if(curr.role__c != NULL){
        	if(!curr.Role__c.equalsIgnoreCase(prev.Role__c)){
            	history += ' Role changed from ' + prev.Role__c + ' to ' + curr.Role__c + '\n'; 
        	}
    	}
                
        //Additional Permission Sets
        if(curr.Permission_sets__c != NULL){
        	if (prev.Permission_Sets__c != Null && !curr.Permission_Sets__c.equalsIgnoreCase(prev.Permission_Sets__c)){
           		history += ' Additional access changed from ' + prev.Permission_Sets__c + ' to ' + curr.Permission_Sets__c + '\n';
            }else if(prev.Permission_Sets__c == NULL){
            	history += ' Additional access added: ' + curr.Permission_Sets__c + '\n';
        	}	
        }
        else if(curr.permission_Sets__c == NULL && prev.Permission_Sets__c != NULL){
            history += prev.Permission_Sets__c + ' removed from additional access' + '\n';
        }
    }
    
    // Return complete History as a formatted String, to append new changes to top of history output box
    public String getHistory(){
        System.debug('HISTORY: ' + history);
        String historyDisplay = '';
        //String historyDisplay = strConvertedDate;
        if(prevHistory != NULL){
            if(history != ' ' && history == NULL && history != ''){
                history = 'The SARF was updated without making any changes.\n';
            }
          historyDisplay = strConvertedDate + '\n' + history + '\n' + prevHistory + '\n';
        }else{
            if(history == NULL || history.equals('') || history.equals('')){
                history = 'The SARF was updated without making any changes.\n';
            }
            historyDisplay = strConvertedDate + '\n' + history + '\n';
        }
        System.debug(historyDisplay);
        return historyDisplay; 
    }
}
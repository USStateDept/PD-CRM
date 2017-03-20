public class BriefingSheetController {
    public List<ContactFeed> cfList {get; set;}
    public List<ContactNote> notes {get; set;}
    public List<CampaignMember> membersList {get; set;}
    public List<ContactActivity> activitiesList {get; set;}
    
    private Contact cont;
    public ContactNote selectedNote {get; set;}
    public ContactActivity selectedActivity {get; set;}
    
    public String selectedNoteId {get; set;}
    public String selectedActivityId {get; set;}
    public Boolean isNoteExist {get; set;}
    public Boolean isAddressExist {get; set;}
    public Boolean showNoteContent {get; set;}
    public Boolean showActivityComment {get; set;}
    
    private ApexPages.StandardController stdController;
    
    public BriefingSheetController (ApexPages.StandardController stdController) {
        this.stdController = stdController;
        this.cont = (Contact)stdController.getRecord();

        if(String.isNotEmpty(this.cont.MailingStreet) && String.isNotEmpty(this.cont.MailingCity)
           && (String.isNotEmpty(this.cont.MailingState) || String.isNotEmpty(this.cont.MailingPostalCode))) {
            isAddressExist = true;
        }
        
        //Retrieve notes
        cfList = [SELECT Id, Title, ContentFileName, ContentData, ContentType, ParentId, CreatedDate 
                  FROM ContactFeed 
                  WHERE ParentId = :cont.Id 
                  Order By LastModifiedDate DESC];

        if(cfList != null && cfList.size() > 0) {
            notes = new List<ContactNote>();
            isNoteExist = false;
            Integer feedSize = cfList.size();
			
            Integer noteCount = 1;
            for(Integer i=0; i<feedSize; i++) {
                ContactFeed cf = cfList.get(i);
                if(cf.ContentType != null && cf.ContentType.equals('text/snote')
                  && noteCount < 3) {
                    ContactNote note = setContactNote(cf);
                    String content = note.contentData;
                    content = content.substringBetween('<p>','</p>');
                    
                    if(content.length() > 50) {
                        content = content.substring(0, 49);
                        content += '...';
                    }
                    note.contentData = content;
                    notes.add(note);
                    noteCount++;
                }
            }
            
            if(notes.size() > 0) {
                isNoteExist = true;
            }
        }

        //Retrieve Campaign Members
        membersList = [SELECT id, Name, Campaign.Name,Campaign.StartDate, Campaign.Type, Type, Status
                       FROM CampaignMember
                      WHERE ContactId = :cont.Id
                      Order By LastModifiedDate DESC];
        
        //Retrieve Activity Histories
         List<Task> tasksList = [SELECT Id, Subject, TaskSubtype, Description, What.Type, Owner.Name, ActivityDate
                               FROM Task
                               WHERE whoId = :cont.Id
                     			Order By ActivityDate DESC];

         if(tasksList != null && tasksList.size() > 0) {
             activitiesList = new List<ContactActivity>();
             Integer tasksSize = tasksList.size();
             if(tasksSize > 2) {
                 tasksSize = 2;
             }
             
             for(Integer i=0; i<tasksSize; i++) {
                 Task task = tasksList.get(i);
				 ContactActivity ca = setContactActivity(task);
                 activitiesList.add(ca);
             }
         }                      
     }
    
    /******************* ACTIONS ********************/
    
    //Retrieve note by Id
    //Note id is assigned to selectedNoteId
    public PageReference getNoteById() {
        List<ContactFeed> feedList = [SELECT Id, Title, ContentFileName, ContentData, ContentType, ParentId, CreatedDate 
                                      FROM ContactFeed 
                                      WHERE Id = :selectedNoteId];

        if(feedList != null && feedList.size() > 0) {
            ContactFeed cf = feedList.get(0);
            selectedNote = setContactNote(cf);
            selectedNote.noteId = cf.Id;
            selectedNote.contentFileName = getContentName(cf.ContentFileName);
            
            if(cf.ContentData != null) {
                String content = (cf.ContentData).toString();
                selectedNote.contentData = content;
            }
        }
        
		showNoteContent = true;
        return null;
    }

	//Retrieve an activity history by Id
	//Activity Id is assigned to selectedActivityId
    public PageReference getActivityById() {
        List<Task> tasks = 
            [SELECT Id, Subject, TaskSubtype, Description, What.Type, Owner.Name, ActivityDate
             FROM Task
             WHERE Id = :selectedActivityId
             LIMIT 1];
        
        if(tasks !=  null && tasks.size() > 0) {
            Task activity = tasks.get(0);
            selectedActivity = setContactActivity(activity);
        }
        
        showActivityComment = true;
        return null;
    }
    
    public PageReference closeNoteModal() {
        showNoteContent = false;
        return ApexPages.currentPage();
    }
    
    public PageReference closeActivityModal() {
        showActivityComment = false;
        return ApexPages.currentPage();
    }
    
    //Close the briefing sheet
    public PageReference closeWindow() {
        PageReference pageRef = new PageReference('/' + this.cont.Id);
        return pageRef;
    }
    /************************************************/
    
    public String getContentName(String contentFileName) {
        String contentName;
        if(String.isNotEmpty(contentFileName)) {
            contentName = contentFileName.substring(0, contentFileName.indexOf('.snote'));
        }
        return contentName;
    }
    
    public ContactActivity setContactActivity(Task task) {
        ContactActivity ca = new ContactActivity();
        ca.activityId = task.Id;
        ca.subject = task.TaskSubtype;
        ca.activityDate = task.ActivityDate;
        ca.owner = task.Owner.Name;
        
        //only retrieve the email body
        String description = task.Description;
        String subject = task.TaskSubtype;
        if(subject.equalsIgnoreCase('Email')) {
            ca.Description = description.substring(description.indexOf('Body') + 5);
        }
        else {
            ca.description = description;
        }  
        
        return ca;
    }
    
    public ContactNote setContactNote(ContactFeed contactFeed) {
        ContactNote note = new ContactNote();
        note.noteId = String.valueOf(contactFeed.Id);
        
        String fileName = contactFeed.ContentFileName;
        note.contentFileName = getContentName(fileName);
        note.createdDate = contactFeed.CreatedDate;
        note.parentId = contactFeed.ParentId;

        if(contactFeed.ContentData != null)
        	note.contentData = contactFeed.ContentData.toString();
        return note;
    }
}
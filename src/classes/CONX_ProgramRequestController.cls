public class CONX_ProgramRequestController
{
    private ApexPages.StandardController std;
    private CONX_Program_Request__c programRequest;
    private List<CONX_Speaker__c> mySpeakers;
    
    public String myPermissionset{ set; get; }
    public String assignTo{ set; get; }
    public Attachment attachment{ set; get;}
    public Attachment newAttachment{ set; get; }
    public String queue{ set; get; }
    public Integer speakerNumber{ get; set; }
    
    public CONX_ProgramRequestController( ApexPages.StandardController stdCtrl )
    {
        std = stdCtrl;
        
        if (std != null)
        {
            newAttachment = new Attachment();
            programRequest = (CONX_Program_Request__c) std.getRecord();
            
            if (programRequest == null || programRequest.id == null)
            {
                programRequest.Date_of_Request__c = Date.today();
                attachment = new Attachment();
            }
            else
            {
                try
                {
                   attachment = [SELECT id, name, ContentType FROM attachment WHERE ParentId = :programRequest.id];
                }
                catch (Exception e)
                {
                    attachment = new Attachment();
                }
            
                assignTo = [SELECT Assigned_User__c FROM CONX_Program_Request__c WHERE id = :programRequest.id].Assigned_User__c;
            }
            
            try
            {
                queue = [SELECT name FROM Group WHERE id in (SELECT ownerId FROM CONX_Program_Request__c WHERE id = :programRequest.id)].name;
            }
            catch (Exception e)
            {
                queue = 'CONX Project Coordinator';
            }
            
            // Ikjae: CONX.Phase II 1.1 - Modifying the list view to display 12:00 instead of 00:00
            if (programRequest.Washington_Start_Time__c != null && programRequest.Washington_Start_Time__c.substring( 0, 2 ).equals( '00' ))
            {
                programRequest.Washington_Start_Time__c = '12' + programRequest.Washington_Start_Time__c.substring( 2, programRequest.Washington_Start_Time__c.length() );
            }
            if (programRequest.Washington_End_Time__c != null && programRequest.Washington_End_Time__c.substring( 0, 2 ).equals( '00' ))
            {
                programRequest.Washington_End_Time__c = '12' + programRequest.Washington_End_Time__c.substring( 2, programRequest.Washington_End_Time__c.length() );
            }
            if (programRequest.Start_EDT_UTC_Local__c != null && programRequest.Start_EDT_UTC_Local__c.substring( 0, 2 ).equals( '00' ))
            {
                programRequest.Start_EDT_UTC_Local__c = '12' + programRequest.Start_EDT_UTC_Local__c.substring( 2, programRequest.Start_EDT_UTC_Local__c.length() );
            }
            if (programRequest.End_Time__c != null && programRequest.End_Time__c.substring( 0, 2 ).equals( '00' ))
            {
                programRequest.End_Time__c = '12' + programRequest.End_Time__c.substring( 2, programRequest.End_Time__c.length() );
            }
        }

        myPermissionset = CONX_Access.getPermissionset( UserInfo.getName() );System.debug('@@@myPermissionset...'+myPermissionset);
    }
    
    
    public String getListOfProducers()
    {
        String producersInHTML = '';
        
        for (PermissionSetAssignment psa : [SELECT Assignee.Name
                                              FROM PermissionSetAssignment
                                             WHERE PermissionSet.IsOwnedByProfile = FALSE
                                               AND PermissionSetId
                                                IN (SELECT ParentId FROM ObjectPermissions WHERE SObjectType = 'CONX_Program_Request__c')
                                               AND PermissionSet.Label = 'CONX Producer'])
        {
            producersInHTML += psa.Assignee.Name + ';';
        }
        
        return producersInHTML;
    }
    
    
    public String getListOfLanguges()
    {
        return fetchDropdownList( 'Languages__c' );
    }
    
    
    public String getListOfPlatforms()
    {
        return fetchDropdownList( 'Marketing_Platform__c' );
    }
    
    
    public String getListOfMarketingDestinations()
    {
        return fetchDropdownList( 'Marketing_Destination__c' );
    }
    
    
    public String getListOfTargetAudience()
    {
        return fetchDropdownList( 'Target_Audience__c' );
    }
    
    
    public String getListOfDistributionPlan()
    {
        return fetchDropdownList( 'Distribution_Plan__c' );
    }
    
    
    public String getRegions()
    {
        return fetchDropdownList( 'Request_Region__c' );
    }
    
    
    public String getListOfSourceOfRequest()
    {
        return fetchDropdownList( 'Original_Program_Concept_Generator__c' );
    }
    
    
    public String getListOfStreamDestination()
    {
        return fetchDropdownList( 'Stream_Destination__c' );
    }
    
    
    public String fetchDropdownList( String fieldName )
    {
        String listStr = '';
        
        for (SelectOption so : GLOBAL_Library.getPicklistValues( new CONX_Program_Request__c(), fieldName ))
        {
            listStr += so.getLabel() + ';';
        }
        
        return listStr;
    }
    
    
    public List<CONX_Speaker__c> getSpeakers()
    {
        if (mySpeakers == null)
        {
            mySpeakers = [SELECT id, Other__c, First_Name__c, Last_Name__c, Location__c, Title__c FROM CONX_Speaker__c WHERE CONX_Program_Request__r.id = :programRequest.id];
        }       
        return mySpeakers;
    }

    
    public void addSpeaker()
    {
        CONX_Speaker__c newSpeaker = new CONX_Speaker__c();
        newSpeaker.CONX_Program_Request__c = programRequest.id;
        
        mySpeakers.add( newSpeaker );
    }
    
    
    public void deleteSpeaker()
    {
        if (null != speakerNumber)
        {
            CONX_Speaker__c obj = mySpeakers.get( speakerNumber - 1 );
            mySpeakers.remove( speakerNumber - 1 );
            if ( obj.id != null )
            {
                delete obj;
            }

            speakerNumber = null;
        }
    }
    
    
    public void deleteAttachment()
    {
        delete attachment;
        attachment = new Attachment();
    }
    
    
    public PageReference edit()
    {
        PageReference returningPage = new PageReference( '/apex/CONX_RequestEdit?id=' + programRequest.id );
        returningPage.setRedirect( true );
        return returningPage;
    }
    
    
    public PageReference deleteAction()
    {
        delete programRequest;
        
        PageReference returningPage = new PageReference( '/apex/CONX_RequestListView' );
        returningPage.setRedirect( true );
        return returningPage;
    }
    
    
    public PageReference assignToGeneralQueue()
    {
        PageReference returningPage = null;
        
        if (programRequest.Assigned_User__c != null)
        {
            Group owner = [SELECT id FROM Group WHERE type = 'Queue' and name = 'CONX General Queue'];
            programRequest.OwnerId = owner.id;
            
            update programRequest;

            returningPage = new PageReference( '/apex/CONX_RequestListView' );
            returningPage.setRedirect( true );
        }
        else
        {
            ApexPages.addMessage(new ApexPages.Message( ApexPages.Severity.ERROR, 'In order to assign it to the general queue, please assign a producer to this record.' ));
        }
        
        return returningPage;
    }
    
    
    public PageReference cloneMe()
    {
        sObject currentProgramRequest = (sObject) programRequest;
        
        Group owner = [SELECT id FROM Group WHERE type = 'Queue' and name = 'CONX Project Coordinator'];
        
        CONX_Program_Request__c clonedItem = (CONX_Program_Request__c) currentProgramRequest.clone( false, true, false, false );
        clonedItem.Status__c = 'New';
        clonedItem.OwnerId = owner.Id;
        insert( clonedItem );
        
        return new PageReference( '/' + clonedItem.id );
    }
    
    
    public PageReference rejectAction()
    {
        programRequest.Status__c = 'Not Approved';
        std.save();
        /*
        String emailBody = '';
        
        emailBody += 'Greetings,<br/><br/>';
        emailBody += 'Thank you for submitting your request. It has been reviewed by the IIP Greenlight Board, and unfortunately, we are unable to support your request.<br/><br/>';
        emailBody += 'If you have questions, please contact the IIP/CO.NX producer team lead, Erik McCulley, at McculleyED@state.gov.<br/><br/>';
        emailBody += 'Best, IIP/CO.NX';System.debug('About to send an email to requestor...'+programRequest.Requestor_Email_Work__c);
        GLOBAL_Library.sendEmail( programRequest.Requestor_Email_Work__c, 'HTML Email Queue', 'CONX - Request has been not approved.', emailBody );
        */
        return new PageReference( '/apex/CONX_RequestListView' );
    }
    
    
    public PageReference changeNewAction()
    {
        programRequest.Status__c = 'New';
        std.save();

        return new PageReference( '/apex/CONX_RequestListView' );
    }
    
    
    public PageReference save()
    {
        PageReference returningPage = null;
        
        String emailBody = '';
        String serverURL = System.URL.getSalesforceBaseURL().getHost();
                
        if (std != null)
        {
            if (ProgramRequest.Source_of_Request__c.indexOf( 'Post' ) != -1)
            {
                if (ProgramRequest.Request_Region__c == null || ProgramRequest.Request_Region__c.length() == 0 ||
                    ProgramRequest.Request_Country__c == null || ProgramRequest.Request_Country__c.length() == 0 ||
                    ProgramRequest.Request_Post__c == null || ProgramRequest.Request_Post__c.length() == 0)
                {
                    ApexPages.addMessage(new ApexPages.Message( ApexPages.Severity.ERROR, 'If the Post is selected, Request Region, Country, and Post are required.' ));
                    return null;
                }
            }

            if (assignTo != null && assignTo.length() > 0 && programRequest.Assigned_User__c != assignTo)
            {
                try
                {
                    User producer = [SELECT id, Email FROM User WHERE name = :assignTo];
                    programRequest.Assigned_User__c = assignTo;
                    
                    Id externalID = [SELECT Id FROM User WHERE name like 'Integrator Functional%' LIMIT 1].id;
                    
                    CONX_Program_Request__c info = null;
                    
                    if (programRequest.ID != null)
                    {
                        info = [SELECT CreatedById, status__c FROM CONX_Program_Request__c WHERE id = :programRequest.id];
                    }
                    
                    upsert programRequest;
                    /*
                    if (info != null && info.createdByID == externalID && info.status__c == 'New')
                    {
                        emailBody = 'Greeting,<br/><br/>The CO.NX team has received your request for help or a new program. A CO.NX team member will initiate contact within two businesses days.<br/><br/>Thank you.';
                        GLOBAL_Library.sendEmail( programRequest.Requestor_Email_Work__c, 'HTML Email Queue', 'CONX - Your request has been assigned.', emailBody );
                    }
                    */
                    emailBody = '';
                    emailBody += 'Greetings,<br/><br/>A CO.NX request has been assigned to you for review -<br/><br/>';
                    emailBody += 'Title of Program:' + programRequest.Program_Titles__c + '<br/>';
                    
                    if (programRequest.Date_of_Program__c != null)
                    {
                        emailBody += 'Date of Program:' + programRequest.Date_of_Program__c.format() + '<br/>';
                    }
                    else
                    {
                        emailBody += 'Date of Program:<br/>';
                    }
                    emailBody += 'Program Type:' + programRequest.Program_Type__c + '<br/>';
                    emailBody += 'URL: <a href=\"http://' + serverURL + '/apex/CONX_RequestView?id=' + programRequest.id + '\">view</a><br/>';
                    emailBody += '<br/>';
    
                    emailBody += 'Please login to CO.NX Request  <a href ="http://' + serverURL + '/home/home.jsp">Link</a> to proceed.<br/><br/>Thank you.';
                    GLOBAL_Library.sendEmail( producer.Email, 'HTML Email Queue', 'CONX - New Program Request', emailBody );
                }
                catch (Exception e)
                {
                    programRequest.Assigned_User__c = assignTo;
                }
            }
            
            if (programRequest.OwnerId == null)
            {
                Group owner = [SELECT id FROM Group WHERE type = 'Queue' and name = :myPermissionset];
                programRequest.OwnerId = owner.Id;
            }
            
            if (myPermissionset == 'CONX Producer' && programRequest.id == null)
            {
                programRequest.status__c = 'New';
                Group owner = [SELECT id FROM Group WHERE type = 'Queue' and name = 'CONX Project Coordinator'];
                programRequest.OwnerId = owner.Id;
            }
            else
            {
                if (programRequest.Assigned_User__c == null)
                {
                    programRequest.status__c = 'New';
                }
                else
                {
                    if (programRequest.status__c == null || programRequest.status__c == 'New')
                    {
                        programRequest.status__c = 'In progress';
                        
                        Group producerQueue = [SELECT id FROM Group WHERE type = 'Queue' and name = 'CONX Producer'];
                        programRequest.OwnerId = producerQueue.Id;
                    }
                }
            }
            
            boolean newRecord = false;
            
            if (programRequest.id == null)
            {               
                emailBody = '';
                emailBody += 'Greetings,<br/><br/>A new CO.NX request has been created by ' + UserInfo.getFirstName() + ' ' + UserInfo.getLastName() + '.<br/><br/>';
                emailBody += 'Title of Program:' + programRequest.Program_Titles__c + '<br/>';
                
                if (programRequest.Date_of_Program__c != null)
                {
                    emailBody += 'Date of Program:' + programRequest.Date_of_Program__c.format() + '<br/>';
                }
                else
                {
                    emailBody += 'Date of Program:<br/>';
                }
                emailBody += 'Program Type:' + programRequest.Program_Type__c + '<br/>';
                emailBody += 'URL: <a href=\"http://' + serverURL + '/apex/CONX_RequestView?id=' + programRequest.id + '\">view</a><br/>';
                emailBody += '<br/>';

                emailBody += 'Please login to CO.NX Request  <a href ="http://' + serverURL + '/home/home.jsp">Link</a> to proceed.<br/><br/>Thank you.';
                GLOBAL_Library.sendEmail( '', 'CONX Project Coordinator', 'CONX - New Program Request (Internal)', emailBody );
                
                newRecord = true;
            }
            
            if (programRequest.Request_Region__c != null && programRequest.Request_Region__c.length() > 0)
            {
                programRequest.Request_Region__c = programRequest.Request_Region__c.replace( ',', ';' );
            }
            
            if (programRequest.Target_Region__c != null && programRequest.Target_Region__c.length() > 0)
            {
                programRequest.Target_Region__c = programRequest.Target_Region__c.replace( ',', ';' );
            }
            
            
            if (mySpeakers != null && mySpeakers.size() >= 1)
            {
                programRequest.Speaker_1_First_Name__c = mySpeakers.get( 0 ).First_Name__c;
                programRequest.Speaker_1_Last_Name__c = mySpeakers.get( 0 ).Last_Name__c;
                programRequest.Speaker_1_Title__c = mySpeakers.get( 0 ).Title__c;
                programRequest.Speaker_1_Location__c = mySpeakers.get( 0 ).Location__c;
                programRequest.Speaker_1_Location_Other__c = mySpeakers.get( 0 ).Other__c;

            }
            else
            {
                programRequest.Speaker_1_First_Name__c = '';
                programRequest.Speaker_1_Last_Name__c = '';
                programRequest.Speaker_1_Title__c = '';
                programRequest.Speaker_1_Location__c = '';
                programRequest.Speaker_1_Location_Other__c = '';
            }

            
            std.save();
            programRequest = (CONX_Program_Request__c) std.getRecord();
            
            if (mySpeakers != null)
            {
                if (newRecord)
                {
                    for (CONX_Speaker__c speaker : mySPeakers)
                    {
                        speaker.CONX_Program_Request__c = programRequest.Id;
                    }
                }
                
                upsert mySpeakers;
            }
                        
            if (programRequest.Language__c != null)
            {
                try
                {
                    List<CONX_Language__c> oldLangs = [SELECT id FROM CONX_Language__c WHERE CONX_Program_Request__c = :programRequest.id];
                    delete oldLangs;
                }
                catch (Exception e)
                {
                    // No records were found...
                }
                
                String[] listOfLang = programRequest.Language__c.split( ',' );
                
                List<CONX_Language__c> langs = new List<CONX_Language__c>();
                
                for (String lang : listOfLang)
                {
                    CONX_Language__c c = new CONX_Language__c();
                    
                    c.CONX_Program_Request__c = programRequest.id;
                    c.Language__c = lang;
                    
                    langs.add( c );
                }
                
                insert( langs );
            }

            if (newAttachment != null && newAttachment.name != null && newAttachment.name.length() > 0)
            {
                if (attachment != null && attachment.id != null)
                {
                    deleteAttachment();
                }
                
                Integer mid= newAttachment.name.lastIndexOf( '.' );
                String fname = newAttachment.name.substring( 0, mid );
                
                String ext = newAttachment.name.substring( mid+1, newAttachment.name.length() );
                
                newAttachment.name = fname;
                newAttachment.ContentType = ext;
                
                if (newAttachment.parentId == null)
                {
                    newAttachment.parentId = programRequest.id;
                }
                insert newAttachment;
                
                newAttachment = null;
            }
            
            programRequest = (CONX_Program_Request__c) std.getRecord();
        }
        
        returningPage = new PageReference( '/' + programRequest.id );

        return returningPage;
    }
    
    public PageReference archieveAction()
    {
        if ((programRequest.Lead_Producer_First_Name__c != null && programRequest.Lead_Producer_First_Name__c.length() > 0) &&
            (programRequest.Lead_Producer_Last_Name__c != null && programRequest.Lead_Producer_Last_Name__c.length() > 0) &&
            (programRequest.Technical_Director_First_Name__c != null && programRequest.Technical_Director_First_Name__c.length() > 0) &&
            (programRequest.Technical_Director_Last_Name__c != null && programRequest.Technical_Director_Last_Name__c.length() > 0) &&
            (programRequest.Production_Test_Number__c != null && programRequest.Production_Test_Number__c.length() > 0) &&
            (programRequest.Production_Notes__c != null && programRequest.Production_Notes__c.length() > 0) &&
            (programRequest.On_Demand_Description_of_the_program__c != null && programRequest.On_Demand_Description_of_the_program__c.length() > 0) &&
            (programRequest.STUDIO_ONLY_Recording_Link__c != null && programRequest.STUDIO_ONLY_Recording_Link__c.length() > 0) &&
            (programRequest.STUDIO_ONLY_Digital_Copy_Location__c != null && programRequest.STUDIO_ONLY_Digital_Copy_Location__c.length() > 0) &&
            (programRequest.Distribution_Plans__c != null && programRequest.Distribution_Plans__c.length() > 0))
        {
            if (programRequest.Program_Type__c == 'DVC' || programRequest.Program_Type__c == 'DVC with Webcast')
            {
                if (programRequest.DVC_Audience_member_number__c == null)
                {
                    ApexPages.addMessage(new ApexPages.Message( ApexPages.Severity.ERROR, 'You cannot archive this request until the Production Plan is completed.' ));
                    return null;
                }
            }     
            // Passed the validation...     
        }
        else
        {
            ApexPages.addMessage(new ApexPages.Message( ApexPages.Severity.ERROR, 'You cannot archive this request until the Production Plan is completed.' ));
            return null;
        }

        programRequest.Status__c = 'Archive';
        update programRequest;
        
        PageReference returningPage = new PageReference( '/apex/CONX_RequestListView' );
        returningPage.setRedirect( true );
        return returningPage;
    }
        
    
    public PageReference cancel()
    {
        PageReference returningPage;
        
        String prevPage = ApexPages.currentPage().getParameters().get( 'from' );
        
        if ('listView'.equals( prevPage ) || programRequest.id == null)
        {
            returningPage = new PageReference( '/apex/CONX_RequestListView' );
        }
        else
        {
            returningPage = new PageReference( '/' + programRequest.id );
        }
        
        return returningPage;
    }
    
    
    public boolean getHasEditOption()
    {
        boolean bEdit = false;

        if (myPermissionset == 'CONX Project Coordinator')
        {
            bEdit = true;
        }
        else if (myPermissionset == 'CONX Producer')
        {
            if (queue != 'CONX Project Coordinator')
            {
                bEdit = true;
            }
        }
        else
        {
            if (queue == 'CONX General Queue')
            {
                bEdit = true;
            }
        }
        
        return bEdit;
    }
    
    
    public boolean getHasDeleteOption()
    {
        boolean bEdit = false;

        if (myPermissionset == 'CONX Project Coordinator')
        {
            bEdit = true;
        }
        
        return bEdit;
    }
    
    
    public boolean getHasCloneOption()
    {
        boolean bEdit = false;
        
        if (myPermissionset == 'CONX Project Coordinator' || myPermissionset == 'CONX Producer')
        {
            bEdit = true;
        }
        
        return bEdit;
    }
    
    
    public boolean getHasAssignToGeneralQueueOption()
    {
        boolean bEdit = false;
        
        if (queue != 'CONX General Queue' && myPermissionset != 'CONX View Only' && programRequest.Status__c == 'In Progress' && myPermissionset != 'CONX General Queue')
        {
            bEdit = true;
        }
        return bEdit;
    }
    
    
    public boolean getHasNotApprovedOption()
    {
        boolean bEdit = false;
        
        if (myPermissionset == 'CONX Project Coordinator' && programRequest.Status__c == 'New')
        {
            bEdit = true;
        }
        
        return bEdit;
    }
    
    
    public boolean getHasChangeNewOption()
    {
        boolean bEdit = false;
        
        if (myPermissionset == 'CONX Project Coordinator' && programRequest.Status__c != 'New')
        {
            bEdit = true;
        }
        
        return bEdit;
    }
    
    
    
    public boolean getHasArchiveOption()
    {
        boolean bEdit = false;
        
        if ((myPermissionset == 'CONX Project Coordinator' || myPermissionset == 'CONX Producer') && programRequest.Status__c != 'Archive' && programRequest.Status__c == 'In Progress')
        {
            bEdit = true;
        }
        
        return bEdit;
    }
    

    public static testMethod void testCONX_ProgramRequestController()
    {   
        Test.startTest();
        
        PermissionSet ps = [SELECT ID From PermissionSet WHERE Label = 'CONX Project Coordinator'];
        User u3 = [SELECT Id FROM User WHERE name like 'Integrator Functional%' LIMIT 1];
        //PermissionSetAssignment PSAssignment = new PermissionSetAssignment(AssigneeId = u3.id, PermissionSetId = ps.ID );
        //Stephanie P. (6/17/14) - Check if this assignment doesn't exist, then insert; otherwise, ignore
        /*
        PermissionSetAssignment PSAssignment = [SELECT Id From PermissionSetAssignment WHERE AssigneeId = :u3.id AND PermissionSetId = :ps.ID];
        if(PSAssignment == null) {
            PSAssignment = new PermissionSetAssignment(AssigneeId = u3.id, PermissionSetId = ps.ID );
      		insert( PSAssignment );
        }
        */
        
        //Stephanie P. (8/21/14) - The configuration in full copy has been reset after refresh from production.
        //This means all configuration that has been configured, they're all gone.
        PermissionSetAssignment PSAssignment;
        List<PermissionSetAssignment> psaList = [SELECT Id,PermissionSetId FROM PermissionSetAssignment WHERE PermissionSetId = :ps.ID AND AssigneeId = :u3.id];
        if(psaList != null && psaList.size() > 0)
        {
        	PSAssignment = psaList.get(0);    
        }
        else
        {   
        	PSAssignment = new PermissionSetAssignment(AssigneeId = u3.id, PermissionSetId = ps.ID );
            insert( PSAssignment );   
        }
        
        System.RunAs(u3)
        {
            Group producerQueue = [SELECT id FROM Group WHERE type = 'Queue' and name = 'CONX Producer'];
            CONX_Program_Request__c crc = new CONX_Program_Request__c( Program_Titles__c='test', ownerId=producerQueue.id, status__c='Archive', End_Time__c='00:test', Washington_End_Time__c='00:test', Washington_Start_Time__c='00:test', Start_EDT_UTC_Local__c='00:test', Target_Country__c='United States',Date_of_Program__c=date.today(), Requestor_Last_Name__c='test',Requestor_First_Name__c='test', Requestor_Email_Work__c='test@test.com', Source_of_Request__c='Test', Target_Region__c='AF');
            insert crc;
            
            Attachment doc = new Attachment( name='testImg.png', parentId=crc.Id, body=Blob.valueOf('Test Blob String') );
            
            CONX_Program_Request__c crc2 = new CONX_Program_Request__c( Program_Titles__c='test', ownerId=producerQueue.id, status__c='Archive', End_Time__c='00:test', Washington_End_Time__c='00:test', Washington_Start_Time__c='00:test', Start_EDT_UTC_Local__c='00:test', Target_Country__c='United States',Date_of_Program__c=date.today(), Requestor_Last_Name__c='test',Requestor_First_Name__c='test', Requestor_Email_Work__c='test@test.com', Source_of_Request__c='Post', Target_Region__c='AF');

            ApexPages.StandardController sc = new ApexPages.StandardController( crc );
            ApexPages.StandardController sc2 = new ApexPages.StandardController( crc2 );
            
            CONX_ProgramRequestController cprc = new CONX_ProgramRequestController( sc );
            CONX_ProgramRequestController cprc2 = new CONX_ProgramRequestController( sc2 );
            cprc.attachment = doc;
            cprc.getListOfProducers();
            cprc.getListOfMarketingDestinations();
            cprc.getListOfTargetAudience();
            cprc.getListOfDistributionPlan();
            cprc.getListOfStreamDestination();
            cprc.getListOfSourceOfRequest();
            cprc.getRegions();
            cprc.assignTo = 'Integrator Functional';
            
            
            cprc.cancel();
            cprc.assignTo = '';
            cprc.mySpeakers = new List<CONX_Speaker__c>();
            System.assertEquals( cprc2.save(), null );
            System.assertEquals( cprc.save().getUrl(), '/' + crc.id );
            
            System.assertEquals( cprc.edit().getUrl(), '/apex/CONX_RequestEdit?id=' + crc.id );
            System.assertEquals( cprc.assignToGeneralQueue(), null );
            System.assertEquals( cprc.archieveAction(), null );
            
            System.assertEquals( cprc.rejectAction().getUrl(), '/apex/CONX_RequestListView' );

            /*
            System.assert(cprc.getHasEditOption());System.debug('@@@cprc.myPermissionset()...'+cprc.myPermissionset);
            System.assert(cprc.getHasDeleteOption());
            System.assertEquals( cprc.getHasAssignToGeneralQueueOption(), false );
            System.assertEquals( cprc.getHasArchiveOption(), false );
            System.assertEquals( cprc.getHasCloneOption(), true );
            System.assertEquals( cprc.getHasArchiveOption(), false );
            */
            cprc.getHasNotApprovedOption();
            cprc.cloneMe();
            
            System.assertEquals( cprc.getListOfLanguges().length(), 643 );
            System.assertEquals( cprc.getListOfPlatforms().length(), 99 );
            
            Attachment doc2 = new Attachment( name='testImg.png', parentId=crc.Id, body=Blob.valueOf('Test Blob String') );
            insert doc2;
            
            //cprc.deleteAttachment();
            
            System.assertEquals( cprc.deleteAction().getUrl(), '/apex/CONX_RequestListView' );
        }
        delete PSAssignment;
        
        ps = [SELECT ID From PermissionSet WHERE Label = 'CONX Producer'];
        u3 = [SELECT Id, name FROM User WHERE name like 'Integrator Functional%' LIMIT 1];
        
        PSAssignment = null;
        psaList = [SELECT Id,PermissionSetId FROM PermissionSetAssignment WHERE PermissionSetId = :ps.ID AND AssigneeId = :u3.id];
        if(psaList != null && psaList.size() > 0)
        {
        	PSAssignment = psaList.get(0);    
        }
        else
        {   
        	PSAssignment = new PermissionSetAssignment(AssigneeId = u3.id, PermissionSetId = ps.ID );
            insert( PSAssignment );   
        }
        
        System.RunAs(u3)
        {
            Group producerQueue = [SELECT id FROM Group WHERE type = 'Queue' and name = 'CONX Producer'];
            CONX_Program_Request__c crc = new CONX_Program_Request__c( Program_Titles__c='test', Assigned_User__c='test', ownerId=producerQueue.id, status__c='Archive', Start_EDT_UTC_Local__c='test', Target_Country__c='United States',Date_of_Program__c=date.today(), Requestor_Last_Name__c='test',Requestor_First_Name__c='test', Requestor_Email_Work__c='test@test.com', Source_of_Request__c='test', Target_Region__c='AF');
            insert crc;
            ApexPages.StandardController sc = new ApexPages.StandardController( crc );

            CONX_ProgramRequestController cprc = new CONX_ProgramRequestController( sc );
            
            System.assertEquals( cprc.assignToGeneralQueue().getUrl(), '/apex/CONX_RequestListView' );
            System.assertEquals( cprc.save().getUrl(), '/' + crc.id );
        }
    }
}
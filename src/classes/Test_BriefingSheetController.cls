@isTest
public class Test_BriefingSheetController {
    @testsetup static void setup() {
        
        
        Account a = new Account();
        a.Name = 'Mission United Kingdom';
        insert a;
        
        Contact c = new Contact();
        c.FirstName = 'Liam';
        c.LastName = 'Neeson';
        c.MailingStreet = 'Ballela';
        c.MailingCity = 'County Down';
        c.MailingPostalCode = 'BT32';
        c.MailingCountry = 'Northern Ireland';
        
        Date bdDate = Date.newInstance(1952, 6, 7);
        c.Birthdate = bdDate;
        
        c.MailingCountry = 'United Kingdom';
        c.Email = 'liam.neeson@mail.com';
        c.Spoken_Languages__c = 'English';
        c.AccountId = a.Id;
        insert c;
        
        ContentNote cn = new ContentNote();
        cn.Title = 'Note for Liam';
        String body = 'We need to set up a meeting to discuss about this item.';
        cn.Content = Blob.valueOf(body.escapeHtml4());
        insert cn;

        Note note = new Note();
        note.Body = 'We need to set up a meeting to discuss about this item.';
        note.Title = 'Note for Liam';
        note.ParentId = c.Id;
        insert note;
        
        FeedItem item = new FeedItem();
        item.ParentId = c.Id;
        item.Body = 'Feed item body.';
        item.Title = 'Feed Item for Liam';
        insert item;
        
        FeedItem item2 = new FeedItem();
        item2.ParentId = c.Id;
        item2.Body = 'Feed item 2 body.';
        item2.Title = 'Feed Item 2 for Liam';
        insert item2;
        
        Campaign campaign = new Campaign();
        campaign.Name = 'Liam Campaign';
        campaign.Description = 'This is a campaign for Liam';
        campaign.Type = 'Advertisement';
        campaign.Status = 'Sent';
        campaign.StartDate = Date.newInstance(2015, 03, 25);
        campaign.IsActive = true;
        insert campaign;
        
        CampaignMember member = new CampaignMember();
        member.ContactId = c.Id;
        member.Status = 'Sent';
        member.CampaignId = campaign.Id; 
        insert member;
        
        Task t = new Task();
        t.Description = 'Need to discuss about this campaign';
        t.Subject = 'Call';
        t.TaskSubtype = 'Call';
        t.WhatId = campaign.Id;
        t.WhoId = c.Id;
        t.ActivityDate = Date.newInstance(2015, 03, 25);
        t.Status = 'Completed';
        t.Priority = 'High';
        insert t;
        
        Task t2 = new Task();
        t2.Description = 'Additional To: phamdm1@america.gov; avorak=state.gov@example.com CC: BCC: Attachment: ' +
                        'Subject: Mission UK Body: Need to discuss about this campaign';
        t2.Subject = 'Email:Mission UK';
        t2.TaskSubtype = 'Email';
        t2.WhatId = a.Id;
        t2.WhoId = c.Id;
        t2.ActivityDate = Date.newInstance(2015, 03, 25);
        t2.Status = 'Completed';
        t2.Priority = 'High';
        insert t2;    
    }
    
    static testmethod void testBriefingSheetController() {
        Contact c = [SELECT Id, Name, MailingStreet, MailingCity, MailingState, MailingPostalCode
                     FROM Contact
                    WHERE Email = 'liam.neeson@mail.com'
                    AND Contact.Account.Name = 'Mission United Kingdom'
                    LIMIT 1];

        ApexPages.StandardController sc = new ApexPages.StandardController(c);
        BriefingSheetController briefingController = new BriefingSheetController(sc);
        List<ContactNote> notes = briefingController.notes;
        //System.assert(notes != null);
        
        List<CampaignMember> members = briefingController.membersList;
        System.assert(members != null);
    }
    
    static testmethod void testGetNoteById() {
        Contact c = [SELECT Id, Name, MailingStreet, MailingCity, MailingState, MailingPostalCode
                     FROM Contact
                     WHERE Email = 'liam.neeson@mail.com'
                     AND Contact.Account.Name = 'Mission United Kingdom'
                     LIMIT 1];
        
        ContentNote cn = [SELECT Id FROM ContentNote WHERE Title like '%Liam%' LIMIT 1];
        FeedItem item = [SELECT Id FROM FeedItem WHERE Title like 'Feed Item 2%' LIMIT 1];
        
        ApexPages.StandardController sc = new ApexPages.StandardController(c);
        BriefingSheetController briefingController = new BriefingSheetController(sc);
        
        briefingController.selectedNoteId = item.Id;
        briefingController.getNoteById();
    }
    
    static testmethod void testGetActivityById() {
        Contact c = [SELECT Id, Name,  MailingStreet, MailingCity, MailingState, MailingPostalCode 
                     FROM Contact
                     WHERE Email = 'liam.neeson@mail.com'
                     AND Contact.Account.Name = 'Mission United Kingdom'
                     LIMIT 1];
        
        Task t = [SELECT Id From Task WHERE WhoId = :c.Id LIMIT 1];

        ApexPages.StandardController sc = new ApexPages.StandardController(c);
        BriefingSheetController briefingController = new BriefingSheetController(sc);
        
        briefingController.selectedActivityId = t.Id;
        briefingController.getActivityById();
    }
    
    static testmethod void testGetContentName() {
        String contentFileName = 'Test note.snote';
        ApexPages.StandardController sc = new ApexPages.StandardController(new Contact());
        BriefingSheetController briefingController = new BriefingSheetController(sc);
        String contentName = briefingController.getContentName(contentFileName);
        
        System.assertEquals('Test note', contentName);
    }
    
    static testmethod void testSetContactActivity() {
        ApexPages.StandardController sc = new ApexPages.StandardController(new Contact());
        BriefingSheetController briefingController = new BriefingSheetController(sc);
        
        Task t = [SELECT Id, Subject, TaskSubtype, Description, What.Type, Owner.Name, ActivityDate
                  FROM Task
                  WHERE Subject = 'Email:Mission UK'];
        ContactActivity activity = briefingController.setContactActivity(t);
        System.assert(activity != null);
    }
    
    static testmethod void testSetContactNote() {
        ContactFeed cf = new ContactFeed();
        ApexPages.StandardController sc = new ApexPages.StandardController(new Contact());
        BriefingSheetController briefingController = new BriefingSheetController(sc);
        briefingController.setContactNote(cf);
    }
    
    static testmethod void testCloseNoteModal() {
        ApexPages.StandardController sc = new ApexPages.StandardController(new Contact());
        BriefingSheetController briefingController = new BriefingSheetController(sc);
        
        briefingController.closeNoteModal();
        System.assertEquals(false, briefingController.showNoteContent);
    }
    
    static testmethod void testCloseActivityModal() {
        ApexPages.StandardController sc = new ApexPages.StandardController(new Contact());
        BriefingSheetController briefingController = new BriefingSheetController(sc);
        
        briefingController.closeActivityModal();
        System.assertEquals(false, briefingController.showActivityComment);
    }
    
    static testmethod void testCloseWindow() {
        Contact c = [SELECT Id, Name, MailingStreet, MailingCity, MailingState, MailingPostalCode
                     FROM Contact
                     WHERE Email = 'liam.neeson@mail.com'
                     AND Contact.Account.Name = 'Mission United Kingdom'
                     LIMIT 1];
        
        ApexPages.StandardController sc = new ApexPages.StandardController(c);
        BriefingSheetController briefingController = new BriefingSheetController(sc);
        
        PageReference pageRef = briefingController.closeWindow();
        System.assertEquals('/' + c.Id, pageRef.getUrl());
    }
}
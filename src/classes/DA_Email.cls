public with sharing class DA_Email 
{
public String emailFrom {get; set;}
public String emailTo {get; set;}
public String emailBody {get; set;}
public String response {get; set;}
public String emailCC {get; set;}
public String emailSubject {get; set;}
public Digital_Asset__c da;
public User u;
public String userEmail;
public String reqType {get;set;}
Public String addComments {get;set;}
public Id dId;
public static final String EMAIL2_SUBJECT_QUEUE = 'HTML Email Queue';
public static final String EMAIL_TO_DEFAULT_VIDEO = 'iip-c-video@state.gov';
public static final String EMAIL_TO_DEFAULT_PHOTO = 'photoamgov@state.gov';
public static final String EMAIL_CC_DEFAULT_PHOTO = 'copydesk@state.gov';
public static final String EMAIL_DELIMITER = ',';
public static final String EMAIL_SENT_SUCCESS_MSG = 'Message Sent!';
public static final String EMAIL_TO_WARN_MSG = 'Please provide a value for the To field!';
public static final String EMAIL_BODY_ERROR_MSG = 'No data was found for the email body. Please contact a system admin.';
public static final String EMAIL_VIDEO_TYPE = 'Video';
public static final String EMAIL_PHOTO_TYPE = 'Photo';
public static final String EMAIL_GENERIC_TYPE = 'Generic';
public static final String EMAIL_VIDEO_SUBJ_PREFIX = 'New Video Published: ';
public static final String EMAIL_PHOTO_SUBJ_PREFIX = 'Request for a Photo URL: ';
public static final String EMAIL_GEN_SUBJ_PREFIX = 'New Published Asset: ';


public DA_Email(ApexPages.StandardController controller)
{
	dId = ApexPages.currentPage().getParameters().get('Id');
	reqType = ApexPages.currentPage().getParameters().get('reqType');
	u = [Select Id, Email from User where Id =: UserInfo.getUserId()];
	da = [Select Id, Name from Digital_Asset__c where Id =: dId ];
	userEmail = u.Email;
	emailSubject = determineSubject(reqType) + da.Name;
	emailBody = determineBody(reqType);
	emailTo = defaultTo(reqType);
	emailCC = defaultCC(reqType);
}

public static list<String> parseEmails(String emails)
{
	List<String> arrayEmails = new List<String>();
	System.Debug('DEBUG:: delimiter is: ' + EMAIL_DELIMITER);
	if(emails.indexOf(EMAIL_DELIMITER)>0)
	{
		arrayEmails = emails.split(EMAIL_DELIMITER);
	}
	else
	{
		arrayEmails.add(emails);
	}
	return arrayEmails;
}


public static string defaultTo(String reqType)
{
	String to ='';
	if(reqType == EMAIL_VIDEO_TYPE)
	{
		to = EMAIL_TO_DEFAULT_VIDEO;
	}
	
	if(reqType == EMAIL_PHOTO_TYPE)
	{
		to = EMAIL_TO_DEFAULT_PHOTO;
	}
	
	return to;
}


public static string defaultCC(String reqType)
{
	String cc ='';
	if(reqType == EMAIL_PHOTO_TYPE)
	{
		cc = EMAIL_CC_DEFAULT_PHOTO;
	}
	return cc;
}

public static string determineBody(String reqType)
{
	String body ='';
	if(reqType == EMAIL_VIDEO_TYPE)
	{
		body = DA_NotifyVideoTeam.getNotifyVideoMessage();
	}
	
	if(reqType == EMAIL_PHOTO_TYPE)
	{
		body = DA_NotifyPhotoTeam.getNotifyPhotoMessage();
	}
	
	if(reqType == EMAIL_GENERIC_TYPE)
	{
		body = DA_NotifyGeneric.getNotifyGenericMessage();
	}
	
	return body;
}

public Static String determineSubject(String reqType)
{
	String subject = '';
	if(reqType == EMAIL_VIDEO_TYPE)
	{
		subject = EMAIL_VIDEO_SUBJ_PREFIX;
	}
	if(reqType == EMAIL_PHOTO_TYPE)
	{
		subject = EMAIL_PHOTO_SUBJ_PREFIX;
	}	
	if(reqType == EMAIL_GENERIC_TYPE)
	{
		subject = EMAIL_GEN_SUBJ_PREFIX;
	}
	
	return subject;
}


public void verifyMessage()
{
	if(emailTo =='')
		ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING, EMAIL_TO_WARN_MSG));
	
	if(emailBody == '')
		ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,EMAIL_BODY_ERROR_MSG));
}
	
public PageReference sendEmail(){
	verifyMessage();
	
	if(ApexPages.hasMessages())
	{
		ApexPages.getMessages();
		return null;	
	}
	
	System.Debug('DEBUG:: email: ' + userEmail);
	Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
	
	System.Debug('DEBUG:: emailTo:' + emailTo);
    mail.setToAddresses(parseEmails(emailTo));
    mail.setReplyTo(userEmail);
    mail.setSenderDisplayName(UserInfo.getLastName()+', '+UserInfo.getFirstName());
    if(emailCC!='')
    {
    	System.Debug('DEBUG:: emailCC:' + emailCC);
    	mail.setCcAddresses(parseEmails(emailCC));
    }
    mail.setSubject(emailSubject);
    
    if(addComments!='' && addComments != null)
    	emailBody = emailBody + '<br><br>' + 'Additional Comments: <br>' + addComments;
    
    mail.setHTMLBody(emailBody);
    
    try
    {
    	Messaging.SendEmailResult[] resultMail = Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    	if(resultMail[0].isSuccess())		
			response = EMAIL_SENT_SUCCESS_MSG;
		else
		{
			response = resultMail[0].getErrors().get(0).getMessage();
		}
		}
		catch(System.EmailException ex)
		{
			//response = ex.getMessage();
			ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,ex.getMessage()));
		}	
	return null;
}


public PageReference sendEmail2()
{
	verifyMessage();
	
	if(ApexPages.hasMessages())
	{
		ApexPages.getMessages();
		return null;	
	}
	
	List<String> emailsToSend = new List<String>();
	List<String> emailsCCSend = new List<String>();
	List<String> emailsAllSend = new List<String>();
	
	emailsToSend = parseEmails(emailTo);
	System.Debug('DEBUG:: emailsTo: ' + emailsToSend);
	
	emailsAllSend.addall(emailsToSend);
	
	if(emailCC != '')
		emailsCCSend = parseEmails(emailCC);

	System.Debug('DEBUG:: emailsCC: ' + emailsCCSend);
	
	if(emailsCCSend.size()>0)
		emailsAllSend.addall(emailsCCSend);
	
	if(addComments!='' && addComments != null)
    	emailBody = emailBody + '<br><br>' + 'Additional Comments: <br>' + addComments;

	if(emailsAllSend.size()>0)
	{
		for(String email: emailsAllSend)
		{
			try
			{
				if(emailSubject != null && emailSubject != '' && emailSubject.length()>80)
						emailSubject = emailSubject.substring(0,76) + '...';
						
				GLOBAL_Library.sendEmail(email, EMAIL2_SUBJECT_QUEUE, emailSubject, emailBody);
			}
			catch(System.CalloutException e)
			{
				ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,e.getMessage()));
			}
		}
		
		if(ApexPages.hasMessages())
		{	
			ApexPages.getMessages();
			return null;
		}
		else
		{
			response = EMAIL_SENT_SUCCESS_MSG;
		}
	}
	
	
	return null;	
}





}
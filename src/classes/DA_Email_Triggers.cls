public with sharing class DA_Email_Triggers 
{
public static final String EMAIL_SUBJECT_QUEUE = 'HTML Email Queue';
public static final String CD_NOTIF_EMAIL_ADDR_DEFAULT = 'driscollm@state.gov';
public static final String CD_NOTIF_EMAIL_ADDR_CUST_SET = 'Copy_Desk_Notification_Email_Address';
public static final String CD_NOTIF_EMAIL_ENABLED_CUST_SET = 'Copy_Desk_Notification_Enabled';
public static final String CD_NOTIF_EMAIL_SUBJ_PREFIX = 'Asset Ready for Review: ';
public static final String CD_NOTIF_BODY_PREAMBLE = 'Dear Copy Desk, '+ '<BR/>'+ 'The following asset has been approved for final review and has been placed in the Copy Desk Queue.';
public static final String CD_NOTIF_BODY_HEADLINE = 'Asset Headline: ';
public static final String CD_NOTIF_BODY_LINK = 'Asset Link: ';
public static final String CD_NOTIF_BODY_AUTHOR = 'Author: ';
public static final String CD_NOTIF_BODY_EDITOR = 'Editor: ';
public static final String CD_NOTIF_BODY_SIGNATURE = 'Thank you,' + '<BR/>';
public static final String HTTP_CALLOUT_ERROR_PREFIX = 'An error occurred sending an email: ';
public static final String EXCEPTION_MSG = 'An exception occurred while sending the notification email.  Please contact your system admin and include a screenshot of the error text, if possible. ';
public static final String CUST_SETTING_EXCEPTION_MSG = 'An exception occurred while sending the notification email. The Salesforce environment could be missing a Custom Setting for the copy desk queue email.  Please contact your system admin and include a screenshot of the error text, if possible. ';

public static void sendNotificationEmail(Digital_Asset__c da, string editor)
{
  
  Global_Variable__c cd_email = Global_Variable__c.getValues(CD_NOTIF_EMAIL_ADDR_CUST_SET);
  Global_Variable__c cd_email_enabled = Global_Variable__c.getValues(CD_NOTIF_EMAIL_ENABLED_CUST_SET);
  String emailAddress = CD_NOTIF_EMAIL_ADDR_DEFAULT;

  try{
        //Stephanie P (5/21/14) - fixed Bug SR-PUB002
        //there is a scenario that cd_email is empty, check for null before accessing value__c
        if(cd_email != null && cd_email.value__c != null) {
      emailAddress = cd_email.value__c;
    
            System.Debug('DEBUG:: emailAddress: ' + cd_email.value__c);
            System.Debug('DEBUG:: emailenabled: ' + cd_email_enabled.value__c);
        }
    
    String body = bodyForCopyDeskNotification(da, editor);
    
        //Stephanie P (5/21/14) - fixed Bug SR-PUB002
        //there is a scenario that cd_email_enabled is empty, check for null before accessing value__c
    if(cd_email_enabled != null && 
           (cd_email_enabled.value__c != null && cd_email_enabled.value__c == 'true'))
    {
      try
      {
        System.Debug('DEBUG:: sending email with: ' + emailAddress + ' ' + EMAIL_SUBJECT_QUEUE + ' ' + CD_NOTIF_EMAIL_SUBJ_PREFIX + da.Name + ' ' + body);
        GLOBAL_LIBRARY.sendEmail(emailAddress, EMAIL_SUBJECT_QUEUE, subjForCopyDeskNotification(CD_NOTIF_EMAIL_SUBJ_PREFIX + da.Name), body);
      }
      catch(System.CalloutException e)
      {
        System.Debug('DEBUG:: error encountered sending email: ' + e.getMessage());
        //ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, HTTP_CALLOUT_ERROR_PREFIX + e.getMessage());
        //ApexPages.addMessages(myMsg);
      }
    }
  }
  catch(System.Exception e)
  {
     if(e.getMessage().contains('Attempt to de-reference a null object'))
    {
    da.AddError(CUST_SETTING_EXCEPTION_MSG + '\n \n ' + e.getMessage());
    }
    else
    {
    da.AddError(EXCEPTION_MSG + '\n \n' + e.getMessage());
    }
  }
  
}

public static string getURLforAsset(Id assetId)
{
  System.Debug('DEBUG:: assetId: ' + assetId);
  String retVal = '';
  retVal = URL.getSalesforceBaseUrl().toExternalForm()+'/'+assetId;
  
  return retVal;
}

public static string subjForCopyDeskNotification(String inputSubj)
{
  String retVal = inputSubj;
  if(retVal.length()>79)
    retVal = retVal.substring(0,75) + '...';
    
  return retVal;
}


public static string bodyForCopyDeskNotification(Digital_Asset__c da, string editor)
{
  System.debug('DEBUG:: da: ' + da);
  String retVal = '';
  retVal += CD_NOTIF_BODY_PREAMBLE + '<BR/><BR/>';
  retVal += CD_NOTIF_BODY_HEADLINE + da.Name + '<BR/>';
  retVal += CD_NOTIF_BODY_LINK + getURLforAsset(da.Id) + '<BR/>';
  retVal += CD_NOTIF_BODY_AUTHOR + da.Author__c + '<BR/>';
  retVal += CD_NOTIF_BODY_EDITOR + editor + '<BR/><BR/>';
  retVal += CD_NOTIF_BODY_SIGNATURE + UserInfo.getName();
  return retVal;
}

}
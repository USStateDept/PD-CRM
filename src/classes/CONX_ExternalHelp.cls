@RestResource (urlMapping='/CONX/helpRequest/*')
global with sharing class CONX_ExternalHelp
{
    @HttpPost
    global static string processHelpRequest( List<CONX_Help_Request__c> results )
    {
        List<String> errors = new List<String>();
        List<CONX_Help_Request__c> newHelps = new List<CONX_Help_Request__c>();
        String returnVal = '';
        
        Group queueInfo = [SELECT id FROM Group WHERE type = 'Queue' and name = 'CONX General Queue'];
      
        try
        { 
            for (CONX_Help_Request__c request : results)
            {
                CONX_Help_Request__c helpRequest = request;
                helpRequest.Status__c = 'New';
                helpRequest.OwnerId = queueInfo.id;
                
                if (helpRequest.body__c != null)
                {
                    helpRequest.body__c = helpRequest.body__c.replaceAll( '\n\r', '<br><br>' );
                }
                
                newHelps.add( helpRequest );
            }
            
            if (newHelps.size() != 0)
			{
				insert( newHelps );	
			}
        }
        catch (JSONException e)
        {
            errors.add( 'Error parsing out the JSON...' + e.getMessage() );
        }
        catch (DmlException e)
        {
            errors.add( 'Error insert the record in the database...' + e.getMessage() );
        }
        catch (Exception e)
        {
            errors.add( 'Error in the process...' + e.getMessage() );
        }
        
        if (errors.size() == 0)
        {
        	if (newHelps.size() != 0)
			{
				String emailBody = '';
				String serverURL = System.URL.getSalesforceBaseURL().getHost();

				for (CONX_Help_Request__c cpr : newHelps)
				{
					emailBody += 'Subject:' + cpr.Subject__c + '<br/>';
				    emailBody += 'Requestor First Name:' + cpr.Requestor_First_Name__c + '<br/>';
				    emailBody += 'Requestor Last Name:' + cpr.Requestor_Last_Name__c + '<br/>';
				    emailBody += 'Requestor Email:' + cpr.Requestor_Email__c + '<br/>';
				    emailBody += 'URL: <a href=\"http://' + serverURL + '/apex/CONX_HelpView?id=' + cpr.id + '\">view</a><br/>';
				    emailBody += '<br/>';
				}
				
				String subject = '';
				
				if (newHelps.size() > 1)
				{
					emailBody = 'Greetings,<br/><br/>New CO.NX help requests are awaiting review -<br/><br/>' + emailBody;
					subject = 'CONX - New Help Requests ' + DateTime.now().format();
				}
				else
				{
					emailBody = 'Greetings,<br/><br/>A new CO.NX help request is awaiting review -<br/><br/>' + emailBody;
					subject = 'CONX - New Help Request ' + DateTime.now().format();
				}
				
				emailBody += 'Please login to CO.NX Request  <a href ="http://' + serverURL + '/home/home.jsp">Link</a> to proceed.<br/><br/>Thank you.';
				

				GLOBAL_Library.sendEmail( '', 'CONX Project Coordinator', subject, emailBody );
				GLOBAL_Library.sendEmail( '', 'CONX Producer', subject, emailBody );
				GLOBAL_Library.sendEmail( '', 'CONX General Queue', subject, emailBody );
			}
        	
            returnVal = 'success';
        }
        else
        {
            for (String error : errors)
            {
                returnVal += error + ', ';
            }
            
            returnVal.substring( 0, returnVal.length() - 2 );
        }
         
        return returnVal;
    }
}
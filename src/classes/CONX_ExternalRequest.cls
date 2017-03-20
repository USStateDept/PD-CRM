@RestResource (urlMapping='/CONX/programRequest/*')
global with sharing class CONX_ExternalRequest
{
    @HttpPost
    global static string programRequestHandler( List<CONX_Program_Request__c> results )
    {
        List<String> errors = new List<String>();
        List<CONX_Program_Request__c> newPrograms = new List<CONX_Program_Request__c>();
        List<CONX_Speaker__c> speakers = new List<CONX_Speaker__c>();
        String returnVal = '';
        
        Group queueInfo = [SELECT id FROM Group WHERE type = 'Queue' and name = 'CONX Project Coordinator'];
        
        try
        {   
            for (CONX_Program_Request__c request : results)
            {
                CONX_Program_Request__c programRequest = request;
                programRequest.Status__c = 'New';
                programRequest.Date_of_Request__c = date.today();
                programRequest.OwnerId = queueInfo.id;
                
                // Cleaning up the Infocentral's code...
                if (programRequest.Source_of_Request__c == 'false')
                {
                    programRequest.Source_of_Request__c = 'Other';
                }
                else
                {
                    if (programRequest.Source_of_Request__c != null)
                    {
                        programRequest.Source_of_Request__c = programRequest.Source_of_Request__c.replaceAll( '\n', ',' );
                    }
                }
                
                if (programRequest.Request_Post__c == 'false')
                {
                    programRequest.Request_Post__c = '';
                }
                else
                {
                    if (programRequest.Request_Post__c != null)
                    {
                        programRequest.Request_Post__c = programRequest.Request_Post__c.replaceAll( '\n', ',' );
                    }
                }
                
                
                if (programRequest.Target_Post__c == 'false')
                {
                    programRequest.Target_Post__c = '';
                }
                else
                {
                    if (programRequest.Target_Post__c != null)
                    {
                        programRequest.Target_Post__c = programRequest.Target_Post__c.replaceAll( '\n', ',' );
                    }
                }
                
                if (programRequest.Target_Audiences__c == 'false')
                {
                    programRequest.Target_Audiences__c = '';
                }
                else
                {
                    if (programRequest.Target_Audiences__c != null)
                    {
                        programRequest.Target_Audiences__c = programRequest.Target_Audiences__c.replaceAll( '\n', ',' );
                    }
                }
                
                if (programRequest.Languages__c == 'false')
                {
                    programRequest.Languages__c = '';
                }
                else
                {
                    if (programRequest.Languages__c != null)
                    {
                        programRequest.Language__c = programRequest.Languages__c.replaceAll( '\n', ',' );
                    }
                }
                
                if (programRequest.Request_Region__c == 'Choose one')
                {
                    programRequest.Request_Region__c = '';
                }
                if (programRequest.Request_Country__c == 'Choose one')
                {
                    programRequest.Request_Country__c = '';
                }
                
                if (programRequest.Target_Region__c == 'Choose one')
                {
                    programRequest.Target_Region__c = '';
                }
                if (programRequest.Target_Country__c == 'Choose one')
                {
                    programRequest.Target_Country__c = '';
                }
                
                if (programRequest.Themes__c == 'Choose one')
                {
                    programRequest.Themes__c = '';
                }
                
                if (programRequest.Speaker_1_Location__c == 'Choose one')
                {
                    programRequest.Speaker_1_Location__c = '';
                }
                
                if (programRequest.Program_Goal_s__c != null)
                {
                    programRequest.Program_Goal_s__c = programRequest.Program_Goal_s__c.replaceAll( '\n\r', '<br><br>' );
                }
                
                if (programRequest.Program_Envision__c != null)
                {
                    programRequest.Program_Envision__c = programRequest.Program_Envision__c.replaceAll( '\n\r', '<br><br>' );
                }
                
                if (programRequest.Studio_Scale__c != null)
                {
                    programRequest.Studio_Scale__c = programRequest.Studio_Scale__c.replaceAll( '\n\r', '<br><br>' );
                }
                
                if (programRequest.Notes__c != null)
                {
                    programRequest.Notes__c = programRequest.Notes__c.replaceAll( '\n\r', '<br><br>' );
                }
                
                newPrograms.add( programRequest );
            }
            
            
            if (newPrograms.size() != 0)
            {
                String emailBody = '';
                String serverURL = System.URL.getSalesforceBaseURL().getHost();
                
                insert( newPrograms );  
                
                for (CONX_Program_Request__c cpr : newPrograms)
                {
                    if ((cpr.Speaker_1_First_Name__c != null && cpr.Speaker_1_First_Name__c.length() > 0) ||
                        (cpr.Speaker_1_Last_Name__c != null && cpr.Speaker_1_Last_Name__c.length() > 0) ||
                        (cpr.Speaker_1_Location__c != null && cpr.Speaker_1_Location__c.length() > 0) ||
                        (cpr.Speaker_1_Title__c != null && cpr.Speaker_1_Title__c.length() > 0) ||
                        (cpr.Speaker_1_Location_Other__c != null && cpr.Speaker_1_Location_Other__c.length() > 0))
                    {
                        CONX_Speaker__c speakerOne = new CONX_Speaker__c();
                        speakerOne.CONX_Program_Request__c = cpr.id;
                        speakerOne.First_Name__c = cpr.Speaker_1_First_Name__c;
                        speakerOne.Last_Name__c = cpr.Speaker_1_Last_Name__c;
                        speakerOne.Location__c = cpr.Speaker_1_Location__c;
                        speakerOne.Other__c = cpr.Speaker_1_Location_Other__c;
                        speakerOne.Title__c = cpr.Speaker_1_Title__c;
                        
                        speakers.add( speakerOne );
                    }
                    if ((cpr.Speaker_2_First_Name__c != null && cpr.Speaker_2_First_Name__c.length() > 0) ||
                        (cpr.Speaker_2_Last_Name__c != null && cpr.Speaker_2_Last_Name__c.length() > 0) ||
                        (cpr.Speaker_2_Location__c != null && cpr.Speaker_2_Location__c.length() > 0) ||
                        (cpr.Speaker_2_Title__c != null && cpr.Speaker_2_Title__c.length() > 0) ||
                        (cpr.Speaker_2_Location_Other__c != null && cpr.Speaker_2_Location_Other__c.length() > 0))
                    {
                        CONX_Speaker__c speakerTwo = new CONX_Speaker__c();
                        speakerTwo.CONX_Program_Request__c = cpr.id;
                        speakerTwo.First_Name__c = cpr.Speaker_2_First_Name__c;
                        speakerTwo.Last_Name__c = cpr.Speaker_2_Last_Name__c;
                        speakerTwo.Location__c = cpr.Speaker_2_Location__c;
                        speakerTwo.Other__c = cpr.Speaker_2_Location_Other__c;
                        speakerTwo.Title__c = cpr.Speaker_2_Title__c;
                        
                        speakers.add( speakerTwo );
                    }
                    if ((cpr.Speaker_3_First_Name__c != null && cpr.Speaker_3_First_Name__c.length() > 0) ||
                        (cpr.Speaker_3_Last_Name__c != null && cpr.Speaker_3_Last_Name__c.length() > 0) ||
                        (cpr.Speaker_3_Location__c != null && cpr.Speaker_3_Location__c.length() > 0) ||
                        (cpr.Speaker_3_Title__c != null && cpr.Speaker_3_Title__c.length() > 0) ||
                        (cpr.Speaker_3_Location_Other__c != null && cpr.Speaker_3_Location_Other__c.length() > 0))
                    {
                        CONX_Speaker__c speakerThree = new CONX_Speaker__c();
                        speakerThree.CONX_Program_Request__c = cpr.id;
                        speakerThree.First_Name__c = cpr.Speaker_3_First_Name__c;
                        speakerThree.Last_Name__c = cpr.Speaker_3_Last_Name__c;
                        speakerThree.Location__c = cpr.Speaker_3_Location__c;
                        speakerThree.Other__c = cpr.Speaker_3_Location_Other__c;
                        speakerThree.Title__c = cpr.Speaker_3_Title__c;
                        
                        speakers.add( speakerThree );
                    }
                    if ((cpr.Speaker_4_First_Name__c != null && cpr.Speaker_4_First_Name__c.length() > 0) ||
                        (cpr.Speaker_4_Last_Name__c != null && cpr.Speaker_4_Last_Name__c.length() > 0) ||
                        (cpr.Speaker_4_Location__c != null && cpr.Speaker_4_Location__c.length() > 0) ||
                        (cpr.Speaker_4_Title__c != null && cpr.Speaker_4_Title__c.length() > 0) ||
                        (cpr.Speaker_4_Location_Other__c != null && cpr.Speaker_4_Location_Other__c.length() > 0))
                    {
                        CONX_Speaker__c speakerFour = new CONX_Speaker__c();
                        speakerFour.CONX_Program_Request__c = cpr.id;
                        speakerFour.First_Name__c = cpr.Speaker_4_First_Name__c;
                        speakerFour.Last_Name__c = cpr.Speaker_4_Last_Name__c;
                        speakerFour.Location__c = cpr.Speaker_4_Location__c;
                        speakerFour.Other__c = cpr.Speaker_4_Location_Other__c;
                        speakerFour.Title__c = cpr.Speaker_4_Title__c;
                        
                        speakers.add( speakerFour );
                    }
                    if ((cpr.Speaker_5_First_Name__c != null && cpr.Speaker_5_First_Name__c.length() > 0) ||
                        (cpr.Speaker_5_Last_Name__c != null && cpr.Speaker_5_Last_Name__c.length() > 0) ||
                        (cpr.Speaker_5_Location__c != null && cpr.Speaker_5_Location__c.length() > 0) ||
                        (cpr.Speaker_5_Title__c != null && cpr.Speaker_5_Title__c.length() > 0) ||
                        (cpr.Speaker_5_Location_Other__c != null && cpr.Speaker_5_Location_Other__c.length() > 0))
                    {
                        CONX_Speaker__c speakerFive = new CONX_Speaker__c();
                        speakerFive.CONX_Program_Request__c = cpr.id;
                        speakerFive.First_Name__c = cpr.Speaker_5_First_Name__c;
                        speakerFive.Last_Name__c = cpr.Speaker_5_Last_Name__c;
                        speakerFive.Location__c = cpr.Speaker_5_Location__c;
                        speakerFive.Other__c = cpr.Speaker_5_Location_Other__c;
                        speakerFive.Title__c = cpr.Speaker_5_Title__c;
                        
                        speakers.add( speakerFive );
                    }
                    
                    emailBody += 'Title of Program:' + cpr.Program_Titles__c + '<br/>';
                    if (cpr.Date_of_Program__c != null)
                    {
                        emailBody += 'Date of Program:' + cpr.Date_of_Program__c.format() + '<br/>';
                    }
                    else
                    {
                        emailBody += 'Date of Program:<br/>';
                    }
                    emailBody += 'Program Type:' + cpr.Program_Type__c + '<br/>';
                    emailBody += 'URL: <a href=\"http://' + serverURL + '/apex/CONX_RequestView?id=' + cpr.id + '\">view</a><br/>';
                    emailBody += '<br/>';
                }
                
                insert speakers;
                
                String subject = '';
                
                if (newPrograms.size() > 1)
                {
                    emailBody = 'Greetings,<br/><br/>New CO.NX requests are awaiting review -<br/><br/>' + emailBody;
                    subject = 'CONX - New Program Requests ' + DateTime.now().format();
                }
                else
                {
                    emailBody = 'Greetings,<br/><br/>A new CO.NX request is awaiting review -<br/><br/>' + emailBody;
                    subject = 'CONX - New Program Request ' + DateTime.now().format();
                }
                
                emailBody += 'Please login to CO.NX Request  <a href ="http://' + serverURL + '/home/home.jsp">Link</a> to proceed.<br/><br/>Thank you.';
                

                GLOBAL_Library.sendEmail( '', 'CONX Project Coordinator', subject, emailBody );
                returnVal = 'success';
            }
        }
        catch (Exception e)
        {
            returnVal = 'Error in the process...' + e.getMessage();
        }

        return returnVal;
    }
}
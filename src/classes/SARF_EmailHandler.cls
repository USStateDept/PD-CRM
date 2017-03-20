public class SARF_EmailHandler {
    public EmailTemplate pendingTemplate;
    public CMS_SARF__c sarf {get;set;}
    public String url {get;set;}

    public SARF_EmailHandler(CMS_SARF__c sarf, String salesforceUrl) {
        this.sarf = sarf;
       	this.url = salesforceUrl;
    }
    
    public void sendEmail() {
        if(sarf != null) {
            List<String> toAddresses = new List<String>();
            List<String> ccAddresses = new List<String>();
            SARF_Controller controller = new SARF_Controller();
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            
            try{
                 pendingTemplate = [SELECT id, name, body, subject FROM EmailTemplate WHERE Name = 'SARF Pending User Form'];
            } catch(Exception e) {
                System.debug(LoggingLevel.ERROR, e.getMessage());
            }
            
            String replyTo = sarf.Email_Address__c;
            String office = '';
            Id sarfId = sarf.Id;
            Id managerId = sarf.Manager__c;
            
            //Retrieve manager email address
            if(managerId != null) {
                User manager = controller.getUser(managerId);
                if(manager != null) {
                    toAddresses.add(manager.Email);
                }
            }//end of if managerId is not null
            
            //Retrieve users' permission sets that end with 'Approver' (not from the current sarf):
            //Get sarf.role__c, then append ' Approver'.
            //Replace all spaces with '_' and query permission set assignment to retrieve assigneeId
            //Where permissionSet.Name = 'xxx_xxx_Approver'
            //
            
            if(String.isNotBlank(sarf.Role__c)) {
                String approverPs = sarf.Role__c + ' Approver';
                approverPs = approverPs.replaceAll(' ', '_');

                List<PermissionSetAssignment> assignments = [SELECT Id, PermissionSet.Name, PermissionSet.Id, AssigneeId
                                                             FROM PermissionSetAssignment
                                                             WHERE PermissionSet.Name = :approverPs];
                for(PermissionSetAssignment assignment : assignments) {
                    User approver = controller.getUser(assignment.AssigneeId);
                    ccAddresses.add(approver.Email);
                }
            }//end of if role is not blank
            
            //Retrieve an user's email address who has approver's permission set
            /*if(sarf.Permission_Sets__c != null) {
                List<String> psList = sarf.Permission_Sets__c.trim().split(';');
                for(String ps : psList) {
                    ps = ps.replaceAll(' ','_');
                    if(ps.endsWithIgnoreCase('Approver')) {
                        List<PermissionSetAssignment> psAssignments = [SELECT Id, PermissionSet.Name, PermissionSet.Id, AssigneeId
                        	FROM PermissionSetAssignment
                        	WHERE PermissionSet.Name = :ps];
                        for(PermissionSetAssignment assignment : psAssignments) {
                            if(!assignment.AssigneeId.equals(UserInfo.getUserId())) {
                                User approver = controller.getUser(assignment.AssigneeId);
                                toAddresses.add(approver.Email);
                                //ccAddresses.add(approver.Email);
                            }
                                
                        }
                    }
                }
            }*///end of if permssion_sets__c is not null
    
            if(!toAddresses.isEmpty()) {
                mail.setToAddresses(toAddresses);
                if(!ccAddresses.isEmpty())
               		mail.setCcAddresses(ccAddresses);
                mail.setReplyTo(UserInfo.getUserEmail());
                mail.setSenderDisplayName(UserInfo.getLastName()+', '+UserInfo.getFirstName());   
            }
            
            if(pendingTemplate != null) {
                mail.setSubject(pendingTemplate.Subject);
                
                String body = pendingTemplate.Body;
                body = body.replace('{!CMS_SARF__c.User_Type__c}', sarf.User_Type__c);
                body = body.replace('{!CMS_SARF__c.First_Name__c}', sarf.First_Name__c);
                body = body.replace('{!CMS_SARF__c.Last_Name__c}', sarf.Last_Name__c);
                body = body.replace('{!CMS_SARF__c.Email_Address__c} ', sarf.Email_Address__c);
                body = body.replace('{!CMS_SARF__c.Role__c} ', sarf.Role__c);
                
                if(String.isNotEmpty(sarf.Office__c))
                    office = sarf.Office__c;
               	body = body.replace('{!CMS_SARF__c.Office__c}', office);

                if(url == null)
                    url = '';

                body = body.replace(' {!CMS_SARF__c.Link} ', ' '+url+' ');
                mail.setPlainTextBody(body);
                
                try {
                    Messaging.SendEmailResult[] resultMail = Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
                } catch(Exception e) {
                    System.debug(LoggingLevel.ERROR, e.getMessage());
                }
            }
        }
    }
}
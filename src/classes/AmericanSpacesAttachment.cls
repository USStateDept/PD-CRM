public class AmericanSpacesAttachment
{
	Attachment attachment;
	American_Spaces_Notes_and_Attachments__c information;
	blob attachmentDetail;
	
	public AmericanSpacesAttachment( Attachment attachment, blob attachmentDetail, American_Spaces_Notes_and_Attachments__c information )
	{
		this.attachment = attachment;
		this.attachmentDetail = attachmentDetail;
		this.information = information;
	}
	
	
	public Attachment getAttachment()
	{
		return attachment;
	}
	public void setAttachment( Attachment attachment )
	{
		this.attachment = attachment;
	}
	
	
	public American_Spaces_Notes_and_Attachments__c getInformation()
	{
		return information;
	}
	public void setInformation( American_Spaces_Notes_and_Attachments__c information )
	{
		this.information = information;
	}
	
	
	public blob getAttachmentDetail()
	{
		return attachmentDetail;
	}
	public void setAttachmentDetail( blob attachmentDetail )
	{
		this.attachmentDetail = attachmentDetail;
	}
	
	
	public void deleteObj()
	{
		if (attachment.id != null)
		{
			delete attachment;
		}
		
		delete information;
		attachmentDetail = null;
	}
}
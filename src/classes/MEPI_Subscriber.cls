public class MEPI_Subscriber
{
	public MEPI_Email email{ get; set; }
	public String email_type{ get; set; }
	public MEPI_UserData merge_vars{ get; set; }
	
	public MEPI_Subscriber()
	{
		this.email_type = 'HTML';
	}
}
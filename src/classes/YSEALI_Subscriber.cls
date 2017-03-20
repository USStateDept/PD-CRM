public class YSEALI_Subscriber
{
  public YSEALI_Email email{ get; set; }
  public String email_type{ get; set; }
  public YSEALI_UserData merge_vars{ get; set; }
  
  public YSEALI_Subscriber()
  {
    this.email_type = 'HTML';
  }
}
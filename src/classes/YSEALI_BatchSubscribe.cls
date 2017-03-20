public class YSEALI_BatchSubscribe
{
  public String apikey{ get; set; }
  public String id{ get; set; }
  public List<YSEALI_Subscriber> batch{ get; set; }
  public Boolean double_optin{ get; set; }
  public Boolean update_existing{ get; set; }
  public Boolean replace_interests{ get; set; }
  
  public YSEALI_BatchSubscribe()
  {
    this.batch = new List<YSEALI_Subscriber>();
    this.double_optin = false;
    this.update_existing = false;
    this.replace_interests = false;
  }
}
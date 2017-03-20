public class YSEALI_BatchUnsubscribe {
    public String apikey{ get; set; }
  	public String id{ get; set; }
    public List<YSEALI_Email> batch{ get; set; }
    public Boolean delete_member{ get; set; }
    public Boolean send_goodbye{ get; set; }
    public Boolean send_notify{ get; set; }
    
    public YSEALI_BatchUnsubscribe()
    {
        this.batch = new List<YSEALI_Email>();
        this.delete_member = false;
        this.send_goodbye = false;
        this.send_notify = false;
    }
}
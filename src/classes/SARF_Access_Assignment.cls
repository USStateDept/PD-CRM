public class SARF_Access_Assignment {


    CMS_SARF__c sarf;   // SARF record
    String inputRole; 	// input Role to create list of ps for form
    String p;			// profile
    List<String> ps;    // default
    List<String> extra; // extra ps
    
    // Constructor with SARF as parameter (for actually assigning the values to the sarf)
    public SARF_Access_Assignment(CMS_SARF__c aSarf){
        sarf = aSarf;
    }
    
    // Constructor with String Role as parameter (to generate String lists of permission sets)
    public SARF_Access_Assignment (String aRole){
        inputRole = aRole;
    }
    
    // Return current name of profile on SARF
    public String getProfile(){
        return p;
    }
    
    // Return current names of standard PS on SARF
    public List<String> getPS(){
        return ps;
    }
    
    // Set current names of standard PS
    public void setPS(List<String> permSets){
        ps = permSets;
    }
    
    // Return current names of additional PS on SARF
    public List<String> getExtra(){
        extra = new List<String>();
        String formattedXPS = sarf.Permission_Sets__c;
        String[] splitList = formattedXPS.split(';',0);
        for (String s: splitList){
            s = s.replaceAll(' ', '_');
            s = s.replaceAll('-', '_');
            extra.add(s);
        }
        return extra;
    }
    
   // Set the profile and PS
   public void setProfileAndPS(String p){
    	sarf.profileTemp__c = p;
        String psFormatted = '';
        for (String s: ps){
            psFormatted += s + '\n';
        }
        sarf.permission_sets_default__c = psFormatted;
    }
    
    // Determine the profile and PS on SARF based on Role
    public void assignProfile(){
        String role = sarf.role__c;        
        p = ''; // profile
        ps = new List<String>(); //default permission set(s)
        if(String.isNotEmpty(role) && role.equalsIgnoreCase('System Administrator')){
            p  = 'System Administrator';
            ps.add('Enable SMS-based identity confirmation');
        }
        if(String.isNotEmpty(role) && role.equalsIgnoreCase('Functional')){
            p  = 'System Administrator';
            ps.add('Enable SMS-based identity confirmation');
        }
        else if(String.isNotEmpty(role) && role.equalsIgnoreCase('American Spaces Wash')){
            p = 'IIP User';
            ps.add('American Spaces Washington');
            ps.add('Enable SMS-based identity confirmation');
        }
        else if(String.isNotEmpty(role) && role.equalsIgnoreCase('American Spaces Site.com')){
            p = 'Overage Authenticated Website user';
            ps.add('American Spaces Washington_SITECOM');
        }
        else if(String.isNotEmpty(role) && role.equalsIgnoreCase('CMS Manager')){
            p = 'System Administrator (mock)';
            ps.add('CMS Project Manager');
            ps.add('CMS Incident Report Project Manager');
            ps.add('Reports Manager');
            ps.add('Embassy Manager');
            ps.add('Enable SMS-based identity confirmation');
        }
         else if(String.isNotEmpty(role) && role.equalsIgnoreCase('CMS Team')){
            p = 'CMS User';
            ps.add('CMS Basic');
            ps.add('CMS Report View');
            ps.add('Enable SMS-based identity confirmation');
        }
        else if(String.isNotEmpty(role) && role.equalsIgnoreCase('CMS Support Services')){
            p = 'System Administrator (mock)';
            ps.add('CMS Basic');
            ps.add('CMS Incident Report Creator');
            ps.add('Embassy Viewer');
            ps.add('Enable SMS-based identity confirmation');
            ps.add('SYS Support');
        }
        else if(String.isNotEmpty(role) && role.equalsIgnoreCase('CONX Project Coordinator')){
            p = 'IIP User';
            ps.add('CONX Project Coordinator');
            ps.add('Reports Editor');
            ps.add('Enable SMS-based identity confirmation');
        }
        else if(String.isNotEmpty(role) && role.equalsIgnoreCase('CONX Producer')){
            p = 'IIP User';
            ps.add('CONX Producer');
            ps.add('Reports Editor');
            ps.add('Enable SMS-based identity confirmation');
        }
        else if(String.isNotEmpty(role) && role.equalsIgnoreCase('CONX General Queue')){
            p = 'IIP User';
            ps.add('CONX General Queue'); // hard-coded workaround bc name and API do not match
            ps.add('Reports Editor');
            ps.add('Enable SMS-based identity confirmation');
        }
        else if(String.isNotEmpty(role) && role.equalsIgnoreCase('Environment Manager')){
            p = 'System Administrator';
            ps.add('Enable SMS-based identity confirmation');
        }
        else if(String.isNotEmpty(role) && role.equalsIgnoreCase('Copy Desk')){
            p = 'Publishing Copy Desk';
            ps.add('Publishing Copy Desk');
            ps.add('Reports Editor');
            ps.add('Enable SMS-based identity confirmation');
        }
        else if(String.isNotEmpty(role) && role.equalsIgnoreCase('Translator')){
            p = 'Publishing Translator';
            ps.add('Publishing Translator');
            ps.add('Reports Editor');
            ps.add('Enable SMS-based identity confirmation');
        }
        else if(String.isNotEmpty(role) && role.equalsIgnoreCase('Editor')){
            p = 'Publishing Editor';
            ps.add('Publishing Editor');
            ps.add('Reports Editor');
            ps.add('Enable SMS-based identity confirmation');
        }
        else if(String.isNotEmpty(role) && role.equalsIgnoreCase('Content Creator')){
            p = 'Publishing Content Creator';
            ps.add('Publishing Content Creator');
            ps.add('Reports Editor');
            ps.add('Enable SMS-based identity confirmation');
        }
    }  
}
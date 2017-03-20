// NEED TO ADD USERNAME GENERATOR TO THIS CLASS

public class SARF_Unique_ID_Generator {

    CMS_SARF__c sarf;
    
    //SARF User ID variables
    String randText = '';
    Integer randInt = 0;
    
    //User username variable
    String usernameText = '';
    
    //User alias variable
    String aliasText = '';
    
    public SARF_Unique_ID_Generator(CMS_SARF__c aSarf){
        sarf = aSarf;
    }
    
    public SARF_Unique_ID_Generator(){}    
    
    //SARF USER ID on SARF----------------------------------------------------------------------------------------------
    // Set the SARF User ID, continue generating new random number until it is unique
    public void queryRandomNumbers(){
        boolean randomNumberSet = false;
        while (!randomNumberSet){
        	List<CMS_SARF__c> randomNumbers = [SELECT createdDate, SARF_User_ID__c, name, SARF_Name__c from CMS_SARF__c
                                      WHERE SARF_User_ID__c = :randText LIMIT 1];
        	if(randomNumbers.size() == 0){
            	sarf.SARF_User_ID__c = randText;
                randomNumberSet = true;
            }else{
                generateRandomNumber();
            }
        }
    }
    
    // Generate random number and truncate to 6 digits
    public void generateRandomNumber(){
        randInt = Math.abs(Crypto.getRandomInteger());
        randText = '' + randInt;
        if (randText.length() >6){
            randText = randText.substring(0,6);
        }
    }
    
    // Set User username for new User, continue generating new proposed username until it is unique 
    public String queryUsername(String stdUsername, String secondHalf){ // value passed in should always be first part of email address, extracted in the UserCreator class
        usernameText = stdUsername;
        System.debug('username text passed into query method: ' + usernameText);
        boolean usernameSet = false;
        while(!usernameSet){
            String tempUName = usernameText + '@' + secondHalf;
            System.debug('Temporary full username to be queried: ' + tempUName);
            List<User> usernames = [SELECT username FROM User WHERE username = :tempUName LIMIT 1];
            if(usernames.size() == 0){
                usernameSet = true;
            }else{
                System.debug(usernames.get(0));
                generateUsername();
            }
        }
        return usernameText;
    }
    
    // Generate random truncated text to append to first part of email address
    public void generateUsername(){
        Integer randAppend = Math.abs(Crypto.getRandomInteger());
        String randAppendText = '' + randAppend;
        System.debug('Random num text before truncating:' + randAppendText);
        if (randAppendText.length() > 2){
            randAppendText = randAppendText.substring(0,2);
        }
        System.debug('Random num text after truncating:' + randAppendText);
        usernameText  = usernameText + randAppendText;
        System.debug('Final userNameText:' + usernametext);
    }
    
    //ALIAS on User---------------------------------------------------------------------------------------------------
    // Set User alias for new User, continue generating new proposed alias until it is unique 
    public String queryAlias(String stdAlias){
        aliasText = stdAlias;
        boolean aliasSet = false;
        while(!aliasSet){
            List<User> userAliases = [SELECT alias FROM User WHERE alias = :aliasText LIMIT 1];
            if(userAliases.size() == 0){
                aliasSet = true;
            }else{
                generateAlias();
            }
        }
        return aliasText;
    }
    
    // Generate random truncated text to append to alias
    public void generateAlias(){
        Integer randAppend = Math.abs(Crypto.getRandomInteger());
        String randAppendText = '' + randAppend;
        if (randAppendText.length() > 2){
            randAppendText = randAppendText.substring(0,2);
        }
        aliasText  = aliasText + randAppendText;
    }
}
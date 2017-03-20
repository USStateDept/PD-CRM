public with sharing class KeyValueStoreHelper {
  
    //Getters
    //Use this method to return value from TextValue__c field
    public static String getTextValue(String key) {
        KeyValueStore__c keyValueRecord = getPublicRecord(key);
        return keyValueRecord == null ? null : keyValueRecord.TextValue__c;
    }
    
  //Use this method to return value from BooleanValue__c field
  public static Boolean getBooleanValue(String key) {
    KeyValueStore__c keyValueRecord = getPublicRecord(key);
    return keyValueRecord == null ? null : keyValueRecord.BooleanValue__c;
  }
  
  //Use this method to return value from IntegerValue__c field
  public static Integer getIntegerValue(String key) {
    
    KeyValueStore__c keyValueRecord = getPublicRecord(key);
    return keyValueRecord == null ? null : keyValueRecord.IntegerValue__c == null ? null : keyValueRecord.IntegerValue__c.intValue();
  }
  
  //Use this method to return value from DecimalValue__c field
  public static Decimal getDecimalValue(String key) {
    KeyValueStore__c keyValueRecord = getPublicRecord(key);
    return keyValueRecord == null ? null : keyValueRecord.DecimalValue__c;
  }
  
  //Use this method to return value from DateValue__c field
  public static Date getDateValue(String key) {
    KeyValueStore__c keyValueRecord = getPublicRecord(key);
    return keyValueRecord == null ? null : keyValueRecord.DateValue__c;
  }
  
  //Use this method to return value from DateTimeValue__c field
  public static DateTime getDateTimeValue(String key) {
    KeyValueStore__c keyValueRecord = getPublicRecord(key);
    return keyValueRecord == null ? null : keyValueRecord.DateTimeValue__c;
  }
  
    /* PRIVATE METHODS */
    private static KeyValueStore__c getPublicRecord(String key) {
        return KeyValueStore__c.getInstance(key);
    }

  
}
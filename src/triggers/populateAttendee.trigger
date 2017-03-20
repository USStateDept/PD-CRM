trigger populateAttendee on Event_Registration__c( before insert , before update)
{

    Set<ID> setConIds = new Set<ID>();
    for(Event_Registration__c  obj : trigger.new){
        if(obj.Contact__c != null)
        setConIds.add(obj.Contact__c);
    }
    
     MAP<ID , Contact> mapCon = new MAP<ID , Contact>([Select Name, Title from Contact where id in: setConIds]);
     for(Event_Registration__c  obj : trigger.new)
       {
        if(obj.Contact__c != null)
          {
            Contact  c = mapCon.get(obj.Contact__c);
            if(obj.Name_on_Badge__c == null)
                {obj.Name_on_Badge__c = c.Name;}
            if(obj.Title_on_Badge__c == null)  
                {obj.Title_on_Badge__c = c.Title;}
            
          }
          
       }

}
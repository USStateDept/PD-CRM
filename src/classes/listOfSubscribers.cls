global with sharing class listOfSubscribers
{
    global list<Subscriber> Subscribers {get;set;}
    global Boolean Resubscribe {get;set;}
    global Boolean QueueSubscriptionBasedAutoResponders {get;set;}
    global Boolean RestartSubscriptionBasedAutoresponders {get;set;}
        
    global class Subscriber
    {
        global String EmailAddress {get;set;}
        global String Name {get;set;}
        global List<CustomField> CustomFields{get;set;}            
    }
    
    global class CustomField {
        global String Key {get;set;}
        global String Value {get;set;}
    }
}
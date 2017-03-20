global with sharing class SubscriberResponse {

    global List<Results> Results{get;set;}
    global String ResultsOrderedBy{get;set;}
    global String OrderDirection{get;set;}
    global Integer PageNumber{get;set;}
    global Integer PageSize{get;set;}
    global Integer RecordsOnThisPage{get;set;}
    global Integer TotalNumberOfRecords{get;set;}
    global Integer NumberOfPages{get;set;}

    global class Results {
        global String EmailAddress{get;set;}
        global String Name{get;set;}
        global String Date1{get;set;}
        global String State{get;set;}
        global List<CustomFields> CustomFields{get;set;}
        global String ReadsEmailWith{get;set;}
    }


    global class CustomFields {
        global String Key {get;set;}
        global String Value {get;set;}
    }
    
}
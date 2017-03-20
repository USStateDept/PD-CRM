global with sharing class listOfSegments {
	
    global list<RuleGroup> RuleGroups {get;set;}
    global String Title {get;set;}
        
    global class RuleGroup
    {
        global List<Rule> Rules{get;set;}            
    }
    
    global class Rule {
        global String RuleType {get;set;}
        global String Clause {get;set;}
    }
    
}
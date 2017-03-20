trigger Lead_AutoProcess on Lead (
  before insert, after insert, 
  before update, after update, 
  before delete, after delete) {
      
  if (Trigger.isBefore) {
    if (Trigger.isInsert) {
        LeadTriggerHandler.beforeActivity(Trigger.new);
    } 
    if (Trigger.isUpdate) {
        LeadTriggerHandler.beforeActivity(Trigger.new);
    }
    if (Trigger.isDelete) {
    }
  }

  if (Trigger.IsAfter) {
    if (Trigger.isInsert) {
    } 
    if (Trigger.isUpdate) {
    }
    if (Trigger.isDelete) {
    }
  }
}
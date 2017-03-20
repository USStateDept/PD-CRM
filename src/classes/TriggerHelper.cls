public virtual class TriggerHelper {

    public void process() {
        if(Trigger.isBefore){
            if(Trigger.isInsert){
                processBeforeInsert();
            }      
            else if(Trigger.isUpdate){
                processBeforeUpdate();
            }
            else if(Trigger.isDelete){
                processBeforeDelete();
            }
            else if(Trigger.isUndelete){
                processBeforeUndelete();
            }
        }
        else if(Trigger.isAfter){
            if(Trigger.isInsert){
                processAfterInsert();
            }      
            else if(Trigger.isUpdate){
                processAfterUpdate();
            }
            else if(Trigger.isDelete){
                processAfterDelete();
            }
            else if(Trigger.isUndelete){
                processAfterUndelete();
            }
        }       
    }
    
    /* The following methods can be overridden in the sub classes as per the need */
    
    public virtual void processBeforeInsert() {}
    public virtual void processBeforeUpdate() {}
    public virtual void processBeforeDelete() {}
    public virtual void processBeforeUndelete() {}
    public virtual void processAfterInsert() {}
    public virtual void processAfterUpdate() {}
    public virtual void processAfterDelete() {}
    public virtual void processAfterUndelete() {}

}
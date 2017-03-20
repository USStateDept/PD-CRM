trigger NoteUpdateValidation on Note (before update) {
    //Get all Profile Id's
    List<Id> lstProfileId = new List<Id>();
    List<Id> lstCreatedById = new List<Id>();
    for(Note at : Trigger.new){
        lstCreatedById.add(at.CreatedByid);
    }
    //Get Profile ID's
    Map<id,User> mapUser = new Map<id,User>([select id, name,profileid from user where id IN:lstCreatedById and Profile.name=:'System Administrator']);
    String strParentId=null;
    System.debug('**** mapUser ' + mapUser);
    for(Note at : Trigger.new){
        
        strParentId = at.ParentId;
        if(!strParentId.startsWith('003')) continue;
        
        Note objNotOld = Trigger.oldMap.get(at.Id);
        System.debug('**** objNotOld.CreatedBy ' + objNotOld.CreatedByid + '       pro ' + mapUser.get(at.CreatedById));
        if(objNotOld.CreatedById != at.CreatedById) {
        	if  (mapUser.get(at.CreatedById) ==null)
           		at.addError('You do not have permissions to update!');
        }
    }
}
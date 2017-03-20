trigger UpdateValidation on Attachment (before update) {
    //Get all Profile Id's
    List<Id> lstProfileId = new List<Id>();
    List<Id> lstCreatedById = new List<Id>();
    for(Attachment at : Trigger.new){
        lstCreatedById.add(at.CreatedByid);
    }
    //Get Profile ID's
    Map<id,User> mapUser = new Map<id,User>([select id, name,profileid from user where id IN:lstCreatedById and Profile.name=:'System Administrator']);
    
    System.debug('**** mapUser ' + mapUser);
    String strParentId=null;
    for(Attachment at : Trigger.new){
        //Work only for contact
        strParentId = at.ParentId;
        if(!strParentId.startsWith('003')) continue;
        
        Attachment objAttOld = Trigger.oldMap.get(at.Id);
        System.debug('**** objAttOld.CreatedBy ' + objAttOld.CreatedByid + '       pro ' + mapUser.get(at.CreatedById));
        if(objAttOld.CreatedById !=at.CreatedById || mapUser.get(at.CreatedById)==null ){
            at.addError('You do not have permissions to update!');
        }
    }
}
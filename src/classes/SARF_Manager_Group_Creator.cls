public class SARF_Manager_Group_Creator {
    
    // future call to add members to the Group
    @future
    public static void addUsersToGroup(String groupId, List<Id> userIds){
        //Clear out the existing members before adding the new ones to
        //the group
       	List<GroupMember> members = [Select Id, UserOrGroupId,GroupId 
          From GroupMember 
          Where GroupId = :groupId];
		if(members != null)
            delete members;
        
        //Adding members to the group
        List<GroupMember> GMlist = new List<GroupMember>();
        for(ID userId: userIds){
            GroupMember gm = new GroupMember();
            gm.GroupId = groupId;
            gm.UserOrGroupId = userId;
            gmList.add(GM);
        }
        if(gmList.size() > 0){
            insert gmList;
        }
    }
}
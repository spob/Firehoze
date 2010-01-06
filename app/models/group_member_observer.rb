class GroupMemberObserver < ActiveRecord::Observer
  def after_save(group_member)
    if group_member.activity_compiled_at.nil? and [OWNER, MODERATOR, MEMBER].include?(group_member.member_type)
      GroupMember.transaction do
        group_member.compile_activity
      end
    end
  end
end

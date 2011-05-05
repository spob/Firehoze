class GroupMemberObserver < ActiveRecord::Observer
  def after_save(group_member)
    if group_member.activity_compiled_at.nil? and [OWNER, MODERATOR, MEMBER].include?(group_member.member_type)
      GroupMember.transaction do
        group_member.compile_activity
      end
      # TODO: disabled facebooker
#      RunOncePeriodicJob.create!(
#              :name => 'Post Join Group to Facebook',
#                  # TODO: change :url to :cdn if using a cdn
#              :job => "FacebookPublisher.deliver_join_group(#{group_member.group.id}, #{group_member.user.id}, '#{Group.convert_logo_url_to_cdn(group_member.group.group_logo_url(:medium), :url)}')") if group_member.user.session_key and !group_member.group.private
    end
  end
end

class GroupObserver < ActiveRecord::Observer
  def after_create(group)
    if group.activity_compiled_at.nil?
      Comment.transaction do
        group.compile_activity
        
#    RunOncePeriodicJob.create!(
#            :name => 'Post Join Group to Facebook',
#            :job => "FacebookPublisher.deliver_join_group(#{group.id}, '#{Group.convert_logo_url_to_cdn(comment.topic.group.group_logo_url(:medium), :cdn)}')") if comment.user.session_key and !comment.topic.group.private
      end
    end
  end
end

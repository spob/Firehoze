class TopicCommentObserver < ActiveRecord::Observer
  def after_create(comment)
    RunOncePeriodicJob.create!(
            :name => 'Notify New Topic Comment',
            :job => "TopicComment.notify_members(#{comment.id})")

      # TODO: disabled facebook
#    RunOncePeriodicJob.create!(
#            :name => 'Post New Topic Comment to Facebook',
#            :job => "FacebookPublisher.deliver_topic_comment(#{comment.id}, '#{Group.convert_logo_url_to_cdn(comment.topic.group.group_logo_url(:medium), :cdn)}')") if comment.user.session_key and !comment.topic.group.private
  end
end

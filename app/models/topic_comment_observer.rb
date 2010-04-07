class TopicCommentObserver < ActiveRecord::Observer
  def after_create(comment)
    RunOncePeriodicJob.create!(
            :name => 'Notify New Topic Comment',
            :job => "TopicComment.notify_members(#{comment.id})")


    RunOncePeriodicJob.create!(
            :name => 'Post New Topic Comment to Facebook',
            :job => "FacebookPublisher.deliver_topic_comment(#{comment.id})") if comment.user.session_key and !comment.topic.group.private
  end
end

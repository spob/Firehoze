class TopicCommentObserver < ActiveRecord::Observer
  def after_create(comment)
    RunOncePeriodicJob.create!(
            :name => 'Notify New Topic Comment',
            :job => "TopicComment.notify_members(#{comment.id})")
  end
end

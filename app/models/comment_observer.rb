class CommentObserver < ActiveRecord::Observer
    def after_create(comment)
    if comment.activity_compiled_at.nil? and comment.public
      Comment.transaction do
        comment.compile_activity
      end
    end
  end
end

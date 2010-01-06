class GroupObserver < ActiveRecord::Observer
  def after_create(group)
    if group.activity_compiled_at.nil?
      Comment.transaction do
        group.compile_activity
      end
    end
  end
end

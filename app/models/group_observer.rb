class GroupObserver < ActiveRecord::Observer
  def after_create(group)
    if group.activity_compiled_at.nil?
      Comment.transaction do
        group.compile_activity
      end
      RunOncePeriodicJob.create!(
              :name => 'Post Create Group to Facebook',
                  # TODO: change :url to :cdn if using a cdn
              :job => "FacebookPublisher.deliver_create_group(#{group.id}, '#{Group.convert_logo_url_to_cdn(group.group_logo_url(:medium), :url)}')") if group.owner.session_key and !group.private
    end
  end
end

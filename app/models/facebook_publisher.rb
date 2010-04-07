class FacebookPublisher < Facebooker::Rails::Publisher

  def topic_comment(comment_id)
    comment = TopicComment.find(comment_id)
    send_as :publish_stream
    from comment.user.facebook_session.user
    target comment.user.facebook_session.user
    message "added the comment '#{truncate(comment.body, 100)}' to the topic #{comment.topic.title}"
    action_links [ action_link("View On Firehoze", absolute_path(:controller => 'topics', :action => 'show', :id => comment.topic)) ]
    attachment :name => "#{comment.topic.group.name}", :href => absolute_path(:controller => 'groups', :action => 'show', :id => comment.topic.group), :description => "Firehoze Groups", :media => [{:type => 'image', :src => Group.convert_logo_url_to_cdn(group_logo(comment.topic.group, :medium), :cdn), :href => absolute_path(:controller => 'groups', :action => 'show', :id => comment.topic.group)}]  
  end

  private

  def truncate(txt, len)
    txt = "#{txt[0, len]}..." if txt.length > len
    txt
  end

  def group_logo(group, size)
    group.logo.file? ? group.logo.url(size) : Group.default_logo_url(size)
  end

  def absolute_path(options)
    "#{APP_CONFIG[CONFIG_PROTOCOL]}://#{APP_CONFIG[CONFIG_HOST]}:#{APP_CONFIG[CONFIG_PORT]}#{url_for(options.merge({:only_path => true, :skip_relative_url_root => true}))}"
  end
end

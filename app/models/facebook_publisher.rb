class FacebookPublisher < Facebooker::Rails::Publisher

  def topic_comment(comment_id, logo_url)
    comment = TopicComment.find(comment_id)
    send_as :publish_stream
    from comment.user.facebook_session.user
    target comment.user.facebook_session.user
    message "added the comment '#{truncate(comment.body, 100)}' to the topic #{comment.topic.title}"
    action_links [ action_link("View On Firehoze", absolute_path(:controller => 'topics', :action => 'show', :id => comment.topic)) ]
    attachment :name => comment.topic.group.name, :href => absolute_path(:controller => 'groups', :action => 'show', :id => comment.topic.group), :description => "Firehoze Groups", :media => [{:type => 'image', :src => logo_url, :href => absolute_path(:controller => 'groups', :action => 'show', :id => comment.topic.group)}]  
  end

  def user_instructor(user_id, avatar_url)
    user = User.find(user_id)
    send_as :publish_stream
    from user.facebook_session.user
    target user.facebook_session.user
    message "became a Firehoze instructor"
    action_links [ action_link("View On Firehoze", absolute_path(:controller => 'users', :action => 'show', :id => user)) ]
    attachment :name => user.login, :href => absolute_path(:controller => 'users', :action => 'show', :id => user), :description => "Firehoze Instructor", :media => [{:type => 'image', :src => avatar_url, :href => absolute_path(:controller => 'users', :action => 'show', :id => user)}]
  end

  private

  def truncate(txt, len)
    txt = "#{txt[0, len]}..." if txt.length > len
    txt
  end

  def absolute_path(options)
    "#{APP_CONFIG[CONFIG_PROTOCOL]}://#{APP_CONFIG[CONFIG_HOST]}:#{APP_CONFIG[CONFIG_PORT]}#{url_for(options.merge({:only_path => true, :skip_relative_url_root => true}))}"
  end
end

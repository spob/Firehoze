class FacebookPublisher < Facebooker::Rails::Publisher
  extend UrlHelper

  def topic_comment(comment_id, logo_url)
    comment = TopicComment.find(comment_id)
    send_as :publish_stream
    from comment.user.facebook_session.user
    target comment.user.facebook_session.user
    message "added the comment '#{truncate_text(comment.body, 100)}' to the topic #{comment.topic.title}"
    action_links [ action_link("View On Firehoze", absolute_path(:controller => 'topics', :action => 'show', :id => comment.topic)) ]
    attachment :name => comment.topic.group.name, :href => absolute_path(:controller => 'groups', :action => 'show', :id => comment.topic.group), :description => "Firehoze Groups", :media => [{:type => 'image', :src => logo_url, :href => absolute_path(:controller => 'groups', :action => 'show', :id => comment.topic.group)}]  
  end

  def join_group(group_id, user_id, logo_url)
    group = Group.find(group_id)
    user = User.find(user_id)
    send_as :publish_stream
    from user.facebook_session.user
    target user.facebook_session.user
    message "joined the Firehoze group '#{group.name}'"
    action_links [ action_link("View On Firehoze", absolute_path(:controller => 'groups', :action => 'show', :id => group)) ]
    attachment :name => group.name, :href => absolute_path(:controller => 'groups', :action => 'show', :id => group), :description => "Firehoze Groups", :media => [{:type => 'image', :src => logo_url, :href => absolute_path(:controller => 'groups', :action => 'show', :id => group)}]
  end

  def create_group(group_id, logo_url)
    group = Group.find(group_id)
    send_as :publish_stream
    from group.owner.facebook_session.user
    target group.owner.facebook_session.user
    message "created the Firehoze group '#{group.name}'"
    action_links [ action_link("View On Firehoze", absolute_path(:controller => 'groups', :action => 'show', :id => group)) ]
    attachment :name => group.name, :href => absolute_path(:controller => 'groups', :action => 'show', :id => group), :description => "Firehoze Groups", :media => [{:type => 'image', :src => logo_url, :href => absolute_path(:controller => 'groups', :action => 'show', :id => group)}]
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
end

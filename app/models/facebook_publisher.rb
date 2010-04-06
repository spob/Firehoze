class FacebookPublisher < Facebooker::Rails::Publisher
  def group_comment_template
    one_line_story_template "{*actor*} created a Firehoze comment: {*comment*}"
    short_story_template "{*actor*} created the Firehoze comment {*comment*} in group ", "<a href='{*comment_url*}'>{*group*}</a>"
  end

  def group_comment(comment)
    send_as :publish_stream
    from comment.user.facebook_session.user
    target comment.user.facebook_session.user
    message "added the comment #{truncate(comment.body, 50)} to the Firehoze group #{comment.topic.group.name}"
    action_links [ action_link("View On Firehoze", absolute_path(:controller => 'topics', :action => 'show', :id => comment.topic)) ]
                                           
#    send_as :user_action
#    from comment.user.facebook_session.user
#    story_size SHORT
#    #:images=>[ image(comment.topic.group.logo.url(:medium), group_url(comment.topic.group))],
#    data :actor => comment.user.login, :comment=>comment.body,
#         :comment_url=>topic_url(comment.topic, :canvas => false), :group=>comment.topic.group.name
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

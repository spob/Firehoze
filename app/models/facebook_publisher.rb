class FacebookPublisher < Facebooker::Rails::Publisher
  def group_comment_template
    one_line_story_template "{*actor*} created a Firehoze comment: {*comment*}"
    short_story_template "{*actor*} created the Firehoze comment {*comment*} in group ", "<a href='{*comment_url*}'>{*group*}</a>"
  end

  def group_comment(comment)
    send_as :user_action
    from comment.user.facebook_session.user
    story_size SHORT
    data :images=>[image(comment.topic.group.logo.url(:medium),
                         group_url(comment.topic.group))],
                   :actor => comment.user.login, :comment=>comment.body,
                   :comment_url=>topic_url(comment.topic), :group=>comment.topic.group.name
  end
end

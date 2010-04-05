class TopicCommentsController < ApplicationController
  before_filter :require_user
  # Since this controller is nested, in most cases we'll need to retrieve the group first, so I made it a
  # before filter
  before_filter :retrieve_topic, :except => [ :edit, :update ]
  before_filter :retrieve_topic_comment, :only => [ :edit, :update ]

  verify :method => :post, :only => [:create ], :redirect_to => :home_path
  verify :method => :put, :only => [:update ], :redirect_to => :home_path

  def new
    @topic_comment = @topic.topic_comments.build
    can_create?(@topic)
  end

  def create
    if can_create? @topic
      @topic_comment = @topic.topic_comments.build(params[:topic_comment])
      @topic_comment.user = current_user
      if @topic_comment.save
        flash[:notice] = t 'topic_comment.create_success'
        FacebookPublisher.deliver_group_comment(@topic_comment, facebook_session) if @topic_comment.user.facebook_id
        redirect_to topic_path(@topic)
      else
        render :action => 'new'
      end
    end
  end

  def edit
    can_edit? @topic_comment, current_user
  end

  def update
    if can_edit? @topic_comment, current_user
      params[:topic_comment][:public] ||= false if Comment.show_public_private_option?(current_user)
      if @topic_comment.update_attributes(params[:topic_comment])
        flash[:notice] = t 'topic_comment.update_success'
        redirect_to topic_path(@topic_comment.topic)
      else
        render :action => 'edit'
      end
    end
  end

  private

  def can_edit?(comment, user)
    if comment.can_edit? user
      true
    else
      flash[:error] = t 'topic_comment.cannot_edit'
      redirect_to topic_path(comment.topic)
      false
    end
  end

  def retrieve_topic
    @topic = Topic.find(params[:topic_id])
  end

  # Called by the before filter to retrieve the sku based on the sku_id that
  # was passed in as a parameter
  def retrieve_topic_comment
    @topic_comment = TopicComment.find(params[:id])
  end

  def can_create? topic
    if topic.group.includes_member? current_user
      true
    else
      flash[:error] = t('topic.must_be_member', :group => topic.group.name)
      redirect_to group_path(topic.group)
      false
    end
  end

end

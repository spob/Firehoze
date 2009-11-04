class TopicsController < ApplicationController
  before_filter :require_user, :except => [ :show ]
  # Since this controller is nested, in most cases we'll need to retrieve the group first, so I made it a
  # before filter
  before_filter :retrieve_group, :except => [ :edit, :update, :show ]
  before_filter :retrieve_topic, :only => [ :edit, :show, :update ]

  verify :method => :post, :only => [:create ], :redirect_to => :home_path
  verify :method => :put, :only => [:update ], :redirect_to => :home_path

  def new
    @topic = @group.topics.build
    can_create?(@group)
  end

  def create
    if can_create? @group
      @topic = @group.topics.build(params[:topic])
      @topic.user = current_user
      @topic.last_commented_at = Time.now
      Topic.transaction do
        if @topic.save
          @topic.topic_comments.create!(:user => current_user, :status => COMMENT_STATUS_ACTIVE, :body => @topic.comments)
          flash[:notice] = t 'topic.create_success'
          redirect_to topic_path(@topic)
        else
          render :action => 'new'
        end
      end
    end
  end

  def edit
    can_edit? @topic
  end

  def update
    if can_edit? @topic
      if @topic.update_attributes(params[:topic])
        flash[:notice] = t 'topic.update_success'
        redirect_to topic_path(@topic)
      else
        render :action => 'edit'
      end
    end
  end

  def show
    can_view?(@topic)
  end

  private

  def can_view?(topic)
    if !topic.group.private or topic.group.includes_member?(current_user)
      return true
    end
    flash[:error] = t('topic.must_be_member', :group => topic.group.name)
    redirect_to groups_path
    return false
  end

  def retrieve_topic
    @topic = Topic.find(params[:id])
  end

  # Called by the before filter to retrieve the sku based on the sku_id that
  # was passed in as a parameter
  def retrieve_group
    @group = Group.find(params[:group_id])
  end

  def can_edit? topic
    if topic.group.moderated_by?(current_user) or topic.group.owned_by?(current_user)
      return true
    end
    flash[:error] = t('topic.must_be_moderator_or_owner', :group => topic.group.name)
    redirect_to topic_path(topic)
    false
  end

  def can_create? group
    if group.includes_member? current_user
      return true
    end
    flash[:error] = t('topic.must_be_member', :group => group.name)
    redirect_to group_path(group)
    false
  end
end

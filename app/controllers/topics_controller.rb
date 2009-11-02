class TopicsController < ApplicationController
  before_filter :require_user, :except => [ :show ]
  # Since this controller is nested, in most cases we'll need to retrieve the sku first, so I made it a
  # before filter
  before_filter :retrieve_group, :except => [ :edit, :update, :destroy, :show ]

  verify :method => :post, :only => [:create ], :redirect_to => :home_path
  verify :method => :put, :only => [:update ], :redirect_to => :home_path
  verify :method => :delete, :only => [:destroy ], :redirect_to => :home_path

  def new
    @topic = @group.topics.build
  end

  def create
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

  def show
    @topic = Topic.find(params[:id])
  end

  private

  # Called by the before filter to retrieve the sku based on the sku_id that
  # was passed in as a parameter
  def retrieve_group
    @group = Group.find(params[:group_id])
  end
end

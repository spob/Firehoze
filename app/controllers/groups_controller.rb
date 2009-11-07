class GroupsController < ApplicationController
  before_filter :require_user, :except => [ :show, :list_admin ]
  before_filter :find_group, :except => [:list_admin, :create, :new]

  # Admins only
  permit "#{ROLE_ADMIN} or #{ROLE_MODERATOR}", :only => [:list_admin]

  verify :method => :post, :only => [:create], :redirect_to => :home_path
  verify :method => :put, :only => [:update ], :redirect_to => :home_path

  layout :layout_for_action

  def list_admin
    @search = Group.searchlogic(params[:search])
    @groups = @search.paginate(:include => :owner,
                               :per_page => session[:per_page] || ROWS_PER_PAGE, :page => params[:page])
  end

  def show
    if can_view?(@group)
      @topics = @group.topics.paginate :per_page => ROWS_PER_PAGE, :page => params[:page]
    end
  end

  def new
    @group ||= Group.new
  end

  def create
    @group = Group.new(params[:group])
    @group.owner = current_user
    Group.transaction do
      if @group.save
        @group_member = GroupMember.create!(:user => current_user, :group => @group, :member_type => OWNER,
                                            :activity_compiled_at => Time.now)
        flash[:notice] = t('group.create_success')
        redirect_to group_path(@group)
      else
        render :action => 'new'
      end
    end
  end

  def edit
    can_edit?(@group)
  end

  def update
    if can_edit?(@group)
      if @group.update_attributes(params[:group])
        flash[:notice] = t('group.update_success')
        redirect_to group_path(@group.id)
      else
        render :action => 'edit'
      end
    end
  end

  private

  def find_group
    @group = Group.find params[:id]
  end

  def can_view?(group)
    if !group.private or group.includes_member?(current_user)
      return true
    end
    flash[:error] = t('topic.must_be_member', :group => group.name)
    redirect_to groups_path
    return false
  end

  def can_edit?(group)
    unless current_user == group.owner
      flash[:error] = t('general.no_permissions')
      redirect_to group_path(group)
      return false
    end
    true
  end

  def layout_for_action
    if %w(list_admin).include?(params[:action])
      'admin'
    else
      'application'
    end
  end
end
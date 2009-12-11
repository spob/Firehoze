class GroupsController < ApplicationController
  before_filter :require_user, :except => [ :index, :show, :list_admin ]
  before_filter :find_group, :except => [:list_admin, :create, :new, :ajaxed, :index]
  before_filter :set_per_page, :only => [ :ajaxed, :list_admin ]

  # Admins only
  permit "#{ROLE_ADMIN} or #{ROLE_MODERATOR}", :only => [:list_admin]
  permit ROLE_MODERATOR, :only => [:activate]

  verify :method => :post, :only => [:create, :clear_logo, :activate], :redirect_to => :home_path
  verify :method => :put, :only => [:update ], :redirect_to => :home_path

  layout :layout_for_action

  def list_admin
    @search = Group.searchlogic(params[:search])
    @groups = @search.paginate(:include => :owner,
                               :page => params[:page],
                               :per_page => @per_page)
  end

  def index
    if params[:category]
      @category = Category.find(params[:category])
      @groups = Group.public.active_or_owner_access_all(current_user.try(:is_moderator?), current_user ? current_user.id : -1).by_category(@category.id).ascend_by_name.paginate(:per_page => LESSONS_PER_PAGE, :page => params[:page])
    else
      @categories = Category.root.ascend_by_sort_value
    end
  end

  def show
    if can_view?(@group)
      @topics = @group.topics.paginate :per_page => ROWS_PER_PAGE, :page => params[:page]

      if params[:browse_activities_by] == 'BY_ME' and current_user
        session[:browse_activities_by] = 'BY_ME'
      elsif params[:browse_activities_by] == 'ON_ME' and current_user
        session[:browse_activities_by] = 'ON_ME'
      else
        session[:browse_activities_by] = 'ALL'
      end
      if session[:browse_activities_by] == 'BY_ME'
        @activities = Activity.group_id_equals(@group.id).visible_to_user(current_user).actor_user_id_equals(current_user).descend_by_acted_upon_at.paginate :per_page => ROWS_PER_PAGE, :page => params[:page]
      elsif session[:browse_activities_by] == 'ON_ME'
        @activities = Activity.group_id_equals(@group.id).visible_to_user(current_user).actor_user_id_not_equal_to(current_user).actee_user_id_equals(current_user).descend_by_acted_upon_at.paginate :per_page => ROWS_PER_PAGE, :page => params[:page]
      else
        @activities = Activity.group_id_equals(@group.id).descend_by_acted_upon_at.paginate :per_page => ROWS_PER_PAGE, :page => params[:page]
      end
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

  def activate
    @group.active = true
    @group.save!
    flash[:notice] = t('group.activated', :group => h(@group.name))
    redirect_to group_path(@group)
  end

  def clear_logo
    @group.logo.clear
    if @group.save
      flash[:notice] = t 'group.logo_cleared'
    else
      # getting here because not all (required) fields are getting passed in ...
      flash[:error] = t 'group.update_error'
    end
    redirect_to group_path(@group)
  end

  # SUPPORTING AJAX PAGINATION
  def ajaxed
    @collection = params[:collection]
    @groups =
            case @collection
              when 'belongs_to'
                Group.fetch_user_groups(current_user, @per_page, params[:page])
            end
  end

  private

  def find_group
    @group = Group.find params[:id]
  end

  def can_view?(group)
    if !group.private or group.includes_member?(current_user) or current_user.try(:is_moderator?)
      if (group.active or group.owned_by?(current_user) or current_user.try(:is_moderator?))
        return true
      else
        flash[:error] = t('group.inactive', :group => group.name)
        redirect_to home_path
        return false
      end
    end
    flash[:error] = t('topic.must_be_member', :group => group.name)
    redirect_to home_path
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
    elsif %w(index edit update new create).include?(params[:action])
      'application_v2'
    else
      'application'
    end
  end

  def set_per_page
    @per_page =
            if params[:per_page]
              params[:per_page]
            elsif %w(list_admin).include?(params[:action])
              (session[:per_page] || ROWS_PER_PAGE)
            else
              5
            end
  end
end
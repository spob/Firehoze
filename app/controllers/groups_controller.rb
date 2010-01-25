class GroupsController < ApplicationController
  if APP_CONFIG[CONFIG_ALLOW_UNRECOGNIZED_ACCESS]
    before_filter :require_user, :except => [ :index, :show, :list_admin ]
  else
    before_filter :require_user
  end
  before_filter :find_group, :except => [:list_admin, :create, :new, :ajaxed, :index, :check_group_by_name, :tagged_with]
  before_filter :set_per_page, :only => [ :ajaxed, :list_admin ]

  # Admins only
  permit "#{ROLE_ADMIN} or #{ROLE_MODERATOR}", :only => [:list_admin]
  permit ROLE_MODERATOR, :only => [:activate]

  verify :method => :post, :only => [:create, :clear_logo, :activate], :redirect_to => :home_path
  verify :method => :put, :only => [:update ], :redirect_to => :home_path

  layout :layout_for_action

  def check_group_by_name
    @group = Group.find_by_name(params[:group][:name].try(:strip))

    respond_to do |format|
      format.js
    end
  end

  def list_admin
    @search = Group.searchlogic(params[:search])
    @groups = @search.paginate(:include => :owner,
                               :page => params[:page],
                               :per_page => @per_page)
  end

  def tagged_with
    @tag = params[:tag]
    @groups = Group.fetch_tagged_with  nil, @tag, 10, params[:page]
  end

  def index
    if params[:category]
      @category = Category.find(params[:category])
      @ids = Group.public.active_or_owner_access_all(current_user.try(:is_moderator?), current_user ? current_user.id : -1).by_category(@category.id) + [-1]
      @groups = Group.ascend_by_name.find(:all, :conditions => { :id => @ids}).paginate(:per_page => LESSONS_PER_PAGE, :page => params[:page])
      @tags = Group.public.active.tag_counts(:conditions => ["groups.id IN (?)", @ids], :order => 'name ASC')
    else
      @categories = Category.root.ascend_by_sort_value
    end
  end

  def show
    @members = @group.group_members.reject{ |m| m.member_type == OWNER }.collect(&:user)
    @lessons = @group.active_lessons.paginate(:per_page => LESSONS_PER_PAGE, :page => params[:page])
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

    respond_to do |format|
      format.html
      format.js
    end

  end

  def new
    @group ||= Group.new
    set_no_uniform_js
  end

  def create
    set_no_uniform_js
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
    set_no_uniform_js
    can_edit?(@group)
  end

  def update
    set_no_uniform_js
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

  def set_no_uniform_js
    @no_uniform_js = true
  end

  def can_view?(group)
    if !group.private or group.includes_member?(current_user) or current_user.try(:is_moderator?)
      if (group.active or group.owned_by?(current_user) or current_user.try(:is_moderator?))
        true
      else
        flash[:error] = t('group.inactive', :group => group.name)
        redirect_to home_path
        false
      end
    else
      flash[:error] = t('topic.must_be_member', :group => group.name)
      redirect_to home_path
      false
    end
  end

  def can_edit?(group)
    if current_user == group.owner
      true
    else
      flash[:error] = t('general.no_permissions')
      redirect_to group_path(group)
      false
    end
  end

  def layout_for_action
    if %w(list_admin).include?(params[:action])
      'admin_v2'
    elsif %w(create edit index new show update).include?(params[:action])
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
              (cookies[:per_page] || ROWS_PER_PAGE)
            else
              5
            end
  end
end
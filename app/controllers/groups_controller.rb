class GroupsController < ApplicationController
  before_filter :require_user, :except => [ :show, :index ]
  before_filter :find_group, :except => [:index, :create, :new]

  # Admins only
  #  permit ROLE_ADMIN, :except => [ :show, :index ]

  verify :method => :post, :only => [:create], :redirect_to => :home_path
  verify :method => :put, :only => [:update ], :redirect_to => :home_path


  def index
    @groups = Group.list(current_user).paginate(:per_page => ROWS_PER_PAGE, :page => params[:page])
  end

  def show

  end

  def new
    @group ||= Group.new
  end

  def create
    @group = Group.new(params[:group])
    @group.owner = current_user
    Group.transaction do
      if @group.save
        @group_member = GroupMember.create!(:user => current_user, :group => @group, :member_type => OWNER)
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

  def can_edit?(group)
    unless current_user == group.owner
      flash[:error] = t('group.no_permissions')
      redirect_to group_path(group)
      return false
    end
    true
  end
end

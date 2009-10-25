class GroupsController < ApplicationController
  before_filter :require_user, :except => [ :show, :index ]
  before_filter :find_group, :except => [:index, :create, :new]

  # Admins only
#  permit ROLE_ADMIN, :except => [ :show, :index ]

  verify :method => :post, :only => [:create], :redirect_to => :home_path
  verify :method => :put, :only => [:update ], :redirect_to => :home_path
  verify :method => :delete, :only => [:destroy ], :redirect_to => :home_path


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
        redirect_to groups_path
      else
        render :action => 'new'
      end
    end
  end

  def edit
  end

  def update
  end

  def destroy
  end

  private

  def find_group
    @group = Group.find params[:id]
  end
end

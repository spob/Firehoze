class UsersController < ApplicationController
  before_filter :require_no_user, :only => [:new, :create]
  before_filter :require_user, :only => [:show, :edit, :update, :index]

  permit Constants::ROLE_SYSADMIN, :except => [:new, :create, :show]

  verify :method => :post, :only => [:create ], :redirect_to => :home_path
  verify :method => :put, :only => [ :update ], :redirect_to => :home_path

  def index
    @users = User.list params[:page]
  end

  def new
    begin
      @registration = Registration.find(params[:registration_id])
      @user = populate_user_from_registration
      @user.time_zone = APP_CONFIG['default_user_timezone']
    rescue ActiveUrl::RecordNotFound
      flash[:notice] = "Registration no longer valid"
      redirect_back_or_default home_path
    end
  end

  def create
    @registration = Registration.find(params[:registration_id])
    @user = populate_user_from_registration
    if @user.save
      flash[:notice] = "Account registered!"
      redirect_back_or_default user_path(@user)
    else
      render :action => :new
    end
  end

  def show
    @user = User.find params[:id]
  end

  def edit
    @user = User.find params[:id]
  end

  def update
    params[:user][:role_ids] ||= []
    @user = User.find params[:id]

    for role_id in params[:user][:role_ids]
      role = Role.find(role_id)
      @user.has_role role.name
    end
    if @user.update_attributes(params[:user])
      flash[:notice] = "Account updated!"
      redirect_to user_url(@user)
    else
      render :action => :edit
    end
  end
end

private

def populate_user_from_registration
  user = User.new(params[:user])
  user.email = @registration.email
  user.login = @registration.login
  user
end
class UsersController < ApplicationController
  before_filter :require_no_user, :only => [:new, :create]
  before_filter :require_user, :only => [:show, :edit, :update, :index]

  permit Constants::ROLE_SYSADMIN, :except => [:new, :create, :show]

  def index
    @users = User.list params[:page]
  end

  def new
    @user = User.new(:time_zone => APP_CONFIG['default_user_timezone'])
  end

  def create
    @user = User.new(params[:user])
    if @user.save
      flash[:notice] = "Account registered!"
      redirect_back_or_default user_path(@user)
    else
      render :action => :new
    end
  end

  def show
#    @user = @current_user
    @user = User.find params[:id]
  end

  def edit
#    @user = @current_user
    @user = User.find params[:id]
  end

  def update            
    @user = User.find params[:id]
    if @user.update_attributes(params[:user])
      flash[:notice] = "Account updated!"
      redirect_to user_url(@user)
    else
      render :action => :edit
    end
  end
end

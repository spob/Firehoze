class UsersController < ApplicationController
  before_filter :require_no_user, :only => [:new, :create]
  before_filter :require_user, :only => [:show, :edit, :update, :index, :private]

  permit ROLE_ADMIN, :except => [:new, :create, :show, :private]

  verify :method => :post, :only => [:create ], :redirect_to => :home_path
  verify :method => :put, :only => [ :update ], :redirect_to => :home_path

  def index
    @users = User.list params[:page]
  end

  def new
    # The registration record is unmarshalled based upon the URL that was created by ActiveURL
    # when the user requested the account in the first placed. If we get here, it means the user
    # clicked on the link in their registration email, in which case we can be sure that the email
    # address they entered is in fact valid.
    @registration = Registration.find(params[:registration_id])
    # retrieve various fields for the @user record based upon the values stored in the registration
    @user = populate_user_from_registration_and_params
    @user.time_zone = APP_CONFIG[CONFIG_DEFAULT_USER_TIMEZONE]
  rescue ActiveUrl::RecordNotFound
    flash[:notice] = t 'user.registration_no_longer_valid'
    redirect_back_or_default home_path
  end

  def create
    @registration = Registration.find(params[:registration_id])
    # Populate the user record based upon the values in the registration record and passed in via params,
    # as appropriate
    @user = populate_user_from_registration_and_params
    if @user.save
      flash[:notice] = t 'user.account_reg_success'
      redirect_back_or_default user_path(@user)
    else
      render :action => :new
    end
  end

  def show
    @user = User.find params[:id]
  end

  def private
    @user = User.find params[:id]
    unless @user == @current_user
      flash[:notice] = t 'user.not_permitted_to_view'
      redirect_back_or_default home_path
    end    
  end

  def edit
    @user = User.find params[:id]
  end

  def update
    # Required for supporting checkboxes
    params[:user][:role_ids] ||= []

    @user = User.find params[:id]

    # Figure out which role value checkboxes were checked and update accordingly
    for role_id in params[:user][:role_ids]
      role = Role.find(role_id)
      @user.has_role role.name
    end
    @user.login = params[:user][:login]
    @user.email = params[:user][:email]
    if @user.update_attributes(params[:user])
      flash[:notice] = t 'user.account_update_success'
      redirect_to user_url(@user)
    else
      render :action => :edit
    end
  end
end

private

def populate_user_from_registration_and_params
  user = User.new(params[:user])
  user.email = @registration.email
  user.login = @registration.username
  user
end
class UsersController < ApplicationController
  before_filter :require_no_user, :only => [ :new, :create ]
  before_filter :require_user, :except => [ :new, :create, :show ]
  before_filter :find_user, :only => [ :clear_avatar, :edit, :show, :show_admin, :private, :reset_password, :update, :update_avatar, :update_roles ]

  permit ROLE_ADMIN, :only => [ :clear_avatar, :show_admin, :private, :reset_password, :update_avatar, :update_roles, :index ]
  permit "#{ROLE_ADMIN} or #{ROLE_MODERATOR}", :only => [ :edit, :update]

  verify :method => :post, :only => [:create ], :redirect_to => :home_path
  verify :method => :put, :only => [ :update ], :redirect_to => :home_path

  layout :layout_for_action

  def list
    @users = User.list params[:page], session[:per_page] || ROWS_PER_PAGE
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
  end

  def show_admin
  end

  def private
    unless @user == @current_user
      flash[:notice] = t 'user.not_permitted_to_view'
      redirect_back_or_default home_path
    end    
  end

  def edit
  end


  def update
    @user.active = params[:user][:active] || false
    @user.rejected_bio = params[:user][:rejected_bio] || false
    @user.email = params[:user][:email].try(:strip)
    @user.first_name = params[:user][:first_name].try(:strip)
    @user.last_name = params[:user][:last_name].try(:strip)
    @user.bio = params[:user][:bio].try(:strip)
    @user.time_zone = params[:user][:time_zone]
    @user.language = params[:user][:language]

    if @user.save!
      flash[:notice] = t 'account_settings.update_success'
    else
      # getting here because not all (required) fields are getting passed in ...
      flash[:error] = t 'account_settings.update_error'
    end

    redirect_to edit_user_path(@user)

  rescue Exception => e
    flash[:error] = e.message
    redirect_to edit_user_path(@user)
  end

  #  temp: saving for "roles code"
  def update_roles
    # Required for supporting checkboxes
    params[:user][:role_ids] ||= []

    # Figure out which role value checkboxes were checked and update accordingly
    for role_id in params[:user][:role_ids].reject! {|x| x.empty? }
      role = Role.find(role_id)
      @user.has_role role.name
    end

    if @user.update_attributes(params[:user])
      flash[:notice] = t 'user.account_update_success'
      redirect_to edit_user_path(@user)
    else
      render :action => :edit
    end
  end

  def update_avatar
    if params[:user][:avatar]
      if  @user.update_attribute(:avatar, params[:user][:avatar])
        flash[:notice] = t 'account_settings.avatar_success'
        redirect_to edit_user_path(@user)
      end
    end
  end

  def clear_avatar
    @user.avatar.clear
    if @user.save
      flash[:notice] = t 'account_settings.avatar_cleared'
    else
      # getting here because not all (required) fields are getting passed in ...
      flash[:error] = t 'account_settings.update_error'
    end
    redirect_to edit_user_path(@user)
  end

  def reset_password
    if @user.deliver_password_reset_instructions! 
      flash[:notice] = t 'user.password_reset_sent'
    else
      flash[:error] = t 'account_settings.update_error'
    end
    redirect_to edit_user_path(@user)
  end

  private

  def layout_for_action
    %w(show_admin edit list).include?(params[:action]) ? 'admin' : 'application'
  end

  def find_user
    @user = User.find params[:id]
  end

  def populate_user_from_registration_and_params
    user = User.new(params[:user])
    user.email = @registration.email
    user.login = @registration.username
    user
  end
end

# Controller to allow a user to change their password when they are logged in
class PasswordsController < ApplicationController
  before_filter :require_user
  before_filter :find_user

  verify :method => :put, :only => [ :update ], :redirect_to => :home_path

  def edit
  end

  def update
    edit_redirect = edit_user_path(@user)

    if params[:admin_edit] == 'true'
      edit_redirect = edit_admin_user_path(@user)
    end

    @user.current_password = params[:user][:current_password]
    unless @user.valid_current_password? or @current_user.is_admin?
      # user typed a bad value for current password
      @user.password = params[:user][:password]
      render :action => :edit
      return
    end

    @user.password = params[:user][:password]
    @user.password_confirmation = params[:user][:password_confirmation]
    if @user.save
      flash[:notice] = t 'password.pwd_update_success'
      redirect_to edit_redirect
    end

  rescue Exception => e
    flash[:error] = e.message
    redirect_to edit_redirect
    # render :action => :edit
  end

  private

  def find_user
    if @current_user.is_admin?
      @user = User.find params[:id]
    else
      @user = @current_user
    end
  end
end
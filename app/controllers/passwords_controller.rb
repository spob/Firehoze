# Controller to allow a user to change their password when they are logged in
class PasswordsController < ApplicationController
  before_filter :require_user
  before_filter :find_user

  verify :method => :put, :only => [ :update ], :redirect_to => :home_path

  def edit
  end

  def update
    @user.current_password = params[:user][:current_password]
    unless @user.valid_current_password?
      # user typed a bad value for current password
      @user.password = params[:user][:password]
      render :template => 'accounts/edit'
      return
    end
    @user.password = params[:user][:password]
    @user.password_confirmation = params[:user][:password_confirmation]
    if @user.save
      flash[:notice] = t 'password.pwd_update_success'
      redirect_to edit_user_url(@user)
    else
      render :template => 'accounts/edit'
    end
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
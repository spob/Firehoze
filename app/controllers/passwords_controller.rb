# Controller to allow a user to change their password when they are logged in
class PasswordsController < ApplicationController
  before_filter :require_user
  
  verify :method => :put, :only => [ :update ], :redirect_to => :home_path

  def edit
    @user = @current_user
  end

  def update
    @user = User.find(@current_user.id)
    @user.current_password = params[:user][:current_password]
    unless @user.valid_current_password?
      # user typed a bad value for current password
      @user.password = params[:user][:password]
      render :action => :edit
      return
    end
    @user.password = params[:user][:password]
    @user.password_confirmation = params[:user][:password_confirmation]
    if @user.save
      flash[:notice] = t(:pwd_update_success)
      redirect_to profile_url(@user)
    else
      render :action => :edit
    end
  end
end

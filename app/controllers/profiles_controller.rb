class ProfilesController < ApplicationController
  before_filter :require_user

  def show
    @user = @current_user
  end

  def edit
    @user = @current_user
  end

  def update
    # avoid mass assignment here
    @user = @current_user
    @user.email = params[:user][:email].try(:strip)
    @user.first_name = params[:user][:first_name].try(:strip)
    @user.last_name = params[:user][:last_name].try(:strip)
    if @user.save
      flash[:notice] = "Profile updated!"
      redirect_to profile_url(@user)
    else
      render :action => :edit
    end
  end

  def edit_password
    @user = @current_user
  end

  def update_password
    @user = User.find(@current_user.id)
    @user.current_password = params[:user][:current_password]
    unless @user.valid_current_password?
      # user typed a bad value for current password
      @user.password = params[:user][:password]
      render :action => :edit_password
      return
    end
    @user.password = params[:user][:password]
    @user.password_confirmation = params[:user][:password_confirmation]
    if @user.save
      flash[:notice] = "Password updated!"
      redirect_to profile_url(@user)
    else
      render :action => :edit_password
    end
  end
end

class ProfilesController < ApplicationController
  before_filter :require_user

  verify :method => :put, :only => [ :update ], :redirect_to => :home_path

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
    @user.login = params[:user][:login].try(:strip)
    @user.time_zone = params[:user][:time_zone]
    @user.language = params[:user][:language]
    if @user.save
      flash[:notice] = "Profile updated!"
      redirect_to profile_url(@user)
    else
      render :action => :edit
    end
  end
end

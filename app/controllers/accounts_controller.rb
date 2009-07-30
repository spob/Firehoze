# The accounts controller allows the user to update personal information on their account
class AccountsController < ApplicationController
  before_filter :require_user

  verify :method => :put, :only => [ :update ], :redirect_to => :home_path

  def show
    @user = @current_user
  end

  def edit
    @user = @current_user
  end

  def update

    @user = @current_user

    # avoid mass assignment here
    if params[:user][:destroy_avatar] == 'true'
      @user.avatar.clear
    else
      @user.email = params[:user][:email].try(:strip)
      @user.first_name = params[:user][:first_name].try(:strip)
      @user.last_name = params[:user][:last_name].try(:strip)
      @user.bio = params[:user][:bio]
      @user.time_zone = params[:user][:time_zone]
      @user.language = params[:user][:language]
      @user.avatar = params[:user][:avatar] unless params[:user][:avatar].blank?
    end

    if @user.save
      flash[:notice] = t 'profile.update_success'
      redirect_to edit_user_path(@user)
    end

  rescue Exception => e
    raise params.inspect
    flash[:error] = e.message
    render edit_user_path(@user)
  end
end

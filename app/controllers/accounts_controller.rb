# The accounts controller allows the user to update personal information on their account
class AccountsController < ApplicationController
  before_filter :require_user, :populate_user

  verify :method => :put, :only => [ :update ], :redirect_to => :home_path
  verify :method => :post, :only => [ :destroy_avatar ], :redirect_to => :home_path

  def show
  end

  def edit
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

  def update
    flash_msg = t 'account_settings.update_success'

    # avoid mass assignment here
    if params[:user][:destroy_avatar] == 'true'
      @user.avatar.clear
      @user.save
    elsif params[:user][:avatar]
      @user.update_attribute(:avatar, params[:user][:avatar])
      flash_msg = t 'account_settings.avatar_success'
    else
      @user.email = params[:user][:email].try(:strip)
      @user.first_name = params[:user][:first_name].try(:strip)
      @user.last_name = params[:user][:last_name].try(:strip)
      @user.bio = params[:user][:bio]
      @user.time_zone = params[:user][:time_zone]
      @user.language = params[:user][:language]
    end

    if @user.save
      flash[:notice] = flash_msg
      redirect_to edit_user_path(@user)
    else
      # getting here because not all (required) fields are getting passed in ...  
      flash[:error] = t 'account_settings.update_error'
      redirect_to edit_user_path(@user)
    end

  rescue Exception => e
    flash[:error] = e.message
    redirect_to edit_user_path(@user)
  end

  private

  def populate_user
    @user = User.find(params[:id])
  end
end

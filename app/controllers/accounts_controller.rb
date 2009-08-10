# The accounts controller allows the user to update personal information on their account
class AccountsController < ApplicationController
  before_filter :require_user, :find_user

  verify :method => :put, :only => [ :update ], :redirect_to => :home_path
  verify :method => :post, :only => [ :clear_avatar ], :redirect_to => :home_path

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

    edit_redirect = edit_user_path(@user)
    if params[:admin_edit] == 'true'
      edit_redirect = edit_admin_user_path(@user)
    end

    if params[:user][:avatar]
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
    else
      # getting here because not all (required) fields are getting passed in ...
      flash[:error] = t 'account_settings.update_error'
    end

    redirect_to edit_redirect

  rescue Exception => e
    flash[:error] = e.message
    redirect_to edit_redirect
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

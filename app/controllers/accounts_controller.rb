# The accounts controller allows the user to update personal information on their account
class AccountsController < ApplicationController
  before_filter :require_user, :find_user

  verify :method => :put, :only => [ :update ], :redirect_to => :home_path
  verify :method => :post, :only => [ :clear_avatar ], :redirect_to => :home_path

  def show
  end

  def edit
  end

  def update_avatar
    if params[:user][:avatar]
      if  @user.update_attribute(:avatar, params[:user][:avatar])
        flash[:notice] = t 'account_settings.avatar_success'
        redirect_to edit_account_path(@user)
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
    redirect_to edit_account_path(@user)
  end

  def update
    @user.email = params[:user][:email].try(:strip)
    @user.first_name = params[:user][:first_name].try(:strip)
    @user.last_name = params[:user][:last_name].try(:strip)
    @user.bio = params[:user][:bio]
    @user.time_zone = params[:user][:time_zone]
    @user.language = params[:user][:language]

    if @user.save
      flash[:notice] = t 'account_settings.update_success'
    else
      # getting here because not all (required) fields are getting passed in ...
      flash[:error] = t 'account_settings.update_error'
    end

    redirect_to edit_account_path

  rescue Exception => e
    flash[:error] = e.message
    redirect_to edit_account_path
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

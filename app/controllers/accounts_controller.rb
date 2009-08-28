# The accounts controller allows the user to update personal information on their account
class AccountsController < ApplicationController
  before_filter :require_user, :except => [:author_agreement]
  before_filter :find_user

  verify :method => :put, :only => [ :update, :update_privacy, :update_author, :update_avatar ], :redirect_to => :home_path
  verify :method => :post, :only => [ :enroll_instructor, :clear_avatar ], :redirect_to => :home_path

  def show
  end

  def edit
  end

  def update_avatar
    if params[:user][:avatar]
      if @user.update_attribute(:avatar, params[:user][:avatar])
        flash[:notice] = t 'account_settings.avatar_success'
        redirect_to edit_account_path(@user)
      end
    end
  end

  def enroll_instructor
    if @user.instructor_status == AUTHOR_STATUS_NO
      @user.update_attribute(:instructor_status, AUTHOR_STATUS_INPROGRESS)
      flash[:notice] = t 'account_settings.enrollment_started'
    end
    redirect_to edit_account_path
  end

  def author_agreement
    render :layout => 'content_in_tab'
  end

  def update_author
    @user.address1 = params[:user][:address1]
    @user.address2 = params[:user][:address2]
    @user.city = params[:user][:city]
    @user.state = params[:user][:state]
    @user.postal_code = params[:user][:postal_code]
    @user.country = params[:user][:country]

    if @user.address1_changed? or @user.address2_changed? or @user.city_changed? or
            @user.state_changed? or @user.postal_code_changed? or @user.country_changed?
      @user.verified_address_on = nil
    elsif params[:confirm_contact]
      @user.verified_address_on = Time.now
    end

    if @user.author_agreement_accepted_on.nil? and params[:accept_agreement]
      @user.author_agreement_accepted_on = Time.now
    end
    if @user.save!
      flash[:notice] = t 'account_settings.update_success'
    else
      flash[:error] = t 'account_settings.update_error'
    end
    redirect_to edit_account_path
  rescue Exception => e
    flash[:error] = e.message
    redirect_to edit_account_path

    #:author_agreement_accepted_on,
    #:withold_taxes,
    #:payment_level_id
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

  def update_privacy
    @user.show_real_name = params[:user][:show_real_name] || false
    @user.allow_contact = params[:user][:allow_contact]

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

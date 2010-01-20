# The accounts controller allows the user to update personal information on their account
class AccountsController < ApplicationController
  include SslRequirement

  ssl_required :update, :update_instructor,
               :update_instructor_wizard, :update_privacy if Rails.env.production?
  before_filter :require_user, :except => [:instructor_agreement]
  before_filter :find_user
  before_filter :set_no_uniform_js

  verify :method => :put, :only => [ :update, :update_privacy, :update_instructor, :update_avatar, :update_instructor_wizard ], :redirect_to => :home_path
  verify :method => :post, :only => [ :clear_avatar ], :redirect_to => :home_path

  layout 'application_v2'

#  def show
#  end

  def instructor_signup_wizard
    redirect_path = "redirect_to instructor_wizard_step#{calc_next_wizard_step(@user)}_account_path"
    eval redirect_path
  end

  def instructor_wizard_step1
  end

  def instructor_wizard_step2
    enforce_order @user, 2
  end

  def instructor_wizard_step3
    enforce_order @user, 3
  end

  def instructor_wizard_step4
    enforce_order @user, 4
  end

  def instructor_wizard_step5
    enforce_order @user, 5
  end

  def update_address
    @user.address1 = params[:user][:address1]
    @user.address2 = params[:user][:address2]
    @user.city = params[:user][:city]
    @user.state = params[:user][:state]
    @user.postal_code = params[:user][:postal_code]
    @user.country = params[:user][:country]

    if @user.address1_changed? or @user.address2_changed? or @user.city_changed? or
            @user.state_changed? or @user.postal_code_changed? or @user.country_changed?
      @user.verified_address_on = nil
      @user.instructor_status = AUTHOR_STATUS_INPROGRESS
    end
  end

  def update_instructor_wizard
    if params[:step] == "1"
      # Accepting the agreement
      if @user.author_agreement_accepted_on.nil?
        if params[:accept_agreement]
          if RESTRICT_INSTRUCTOR_SIGNUP and !Registration.match?(@user.email, params[:registration_code], HASH_PREFIX, HASH_SUFFIX)
            flash[:error] = t('account_settings.must_provide_regcode')
            render :action => "instructor_wizard_step1"
          else
            @user.author_agreement_accepted_on = Time.now
            if @user.instructor_status == AUTHOR_STATUS_NO
              @user.instructor_status = AUTHOR_STATUS_INPROGRESS
            end
            if @user.save
              instructor_signup_wizard
            else
              render :action => "instructor_wizard_step1"
            end
          end
        else
          flash[:error] = t('account_settings.must_accept_agreement')
          render :action => "instructor_wizard_step1"
        end
      end
    elsif params[:step] == "2"
      if !@user.payment_level or @user.instructed_lessons.empty?
        @user.payment_level = PaymentLevel.find(params[:user][:payment_level])
        if @user.save
          instructor_signup_wizard
        else
          render :action => "instructor_wizard_step2"
        end
      end
    elsif params[:step] == "3"
      update_address
      if @user.save
        if !@user.address_provided?
          flash[:error] = t('user.address_incomplete')
        end
        instructor_signup_wizard
      else
        render :action => "instructor_wizard_step3"
      end
    elsif params[:step] == "4"
      if params[:confirm_contact]
        @user.verified_address_on = Time.now
        @user.instructor_status = AUTHOR_STATUS_OK
        @user.save
        instructor_signup_wizard
      elsif @user.verified_address_on.nil?
        flash[:error] = t 'account_settings.confirm_address'
        render :action => "instructor_wizard_step4"
      else
        instructor_signup_wizard
      end
    else
      raise
    end
  end

  def edit
    session[:lesson_to_buy] = nil
  end

  def update_avatar
    redirect_set = false
    if params[:user][:avatar]
      if @user.update_attributes(:avatar => params[:user][:avatar])
        render :action => 'crop'
        redirect_set = true
        flash[:notice] = t "account_settings.avatar_success"
      end
    elsif !params[:user][:crop_x].blank? and !params[:user][:crop_y].blank? and !params[:user][:crop_w].blank? and !params[:user][:crop_h].blank?
      @user.crop_x = params[:user][:crop_x]
      @user.crop_y = params[:user][:crop_y]
      @user.crop_w = params[:user][:crop_w]
      @user.crop_h = params[:user][:crop_h]
      @user.touch
      flash[:notice] = t "account_settings.avatar_cropped"
    end
    redirect_to edit_account_path(@user, :anchor => :avatar) unless redirect_set
  end

  def instructor_agreement
    render :layout => 'content_in_tab'
  end

  def update_instructor
    update_address
    if @user.save!
      flash[:notice] = t 'account_settings.update_success'
    else
      flash[:error] = t 'account_settings.update_error'
    end
    if @user.verified_address_on
      redirect_to edit_account_path
    else
      flash[:notice] = t 'account_settings.confirm_address'
      instructor_signup_wizard
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
    @user.login = params[:user][:login].try(:strip)
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
    # specify the id specifically because if the user updates the login, the user won't be
    # found because of the slugging
    redirect_to edit_account_path(@user.id)

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

    redirect_to edit_account_path(:anchor => :privacy)

  rescue Exception => e
    flash[:error] = e.message
    redirect_to edit_account_path(:anchor => :privacy)
  end

  private

  def set_no_uniform_js
    @no_uniform_js = true
  end

  def enforce_order user, step_num
    if calc_next_wizard_step(user) < step_num
      flash[:error] = t('account_settings.wizard_jump_ahead')
      instructor_signup_wizard
    end
  end

  def calc_next_wizard_step user
    if user.author_agreement_accepted_on.nil?
      1
    elsif !user.payment_level
      2
    elsif !user.address_provided?
      3
    elsif !user.verified_address_on
      4
    else
      5
    end
  end

  def find_user
    if @current_user.is_admin?
      @user = User.find params[:id]
    else
      @user = @current_user
    end
  end

end
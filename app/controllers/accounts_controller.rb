# The accounts controller allows the user to update personal information on their account
class AccountsController < ApplicationController
  include SslRequirement

  ssl_required :update, :update_instructor,
               :update_instructor_wizard, :update_privacy,
               :update_venture if Rails.env.production?
  before_filter :require_user, :except => [:instructor_agreement]
  before_filter :find_user
  before_filter :set_no_uniform_js

  verify :method => :put, :only => [ :update, :update_privacy, :update_facebook, :update_instructor, :update_avatar, :update_instructor_wizard, :update_venture ], :redirect_to => :home_path
  verify :method => :post, :only => [ :clear_avatar, :clear_facebook, :request_instructor_reg_code ], :redirect_to => :home_path

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
    unless @user.instructor_signup_notified_at.present?
      RunOncePeriodicJob.create!(
              :name => 'Notify New Instructor',
              :job => "User.notify_instructor_signup(#{@user.id}, '#{@user.avatar_url}')")
    end
  end

  def request_instructor_reg_code
    Notifier.deliver_instructor_reg_code @user
    flash[:notice] = "A representative from #{t('general.company')} will contact you about becoming an #{t('general.company')} #{t('lesson.instructor')}. Thank you."
    redirect_to page_path('reg_code_request_received')
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
          if APP_CONFIG[CONFIG_RESTRICT_INSTRUCTOR_SIGNUP] and !Registration.match?(@user.email, params[:registration_code], HASH_PREFIX, HASH_SUFFIX)
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

  def edit_instructor
  end

  def edit_avatar
  end

  def edit_facebook
    @facebook_key = ActiveSupport::SecureRandom.hex(10)
    unless @user.facebook_id
      User.find(@user.id).update_attribute(:facebook_key, @facebook_key)
    end
  end

  def clear_facebook
    if @user.facebook_id
      User.find(current_user.id).update_attributes(:facebook_id => nil, :session_key => nil)
      flash[:notice] = 'Your Facebook account is no longer associated to your Firehoze account'
    else
      flash[:error] = 'No Facebook account is associated to this user'
    end
    redirect_to edit_facebook_account_path(@user)
  end

  def update_facebook
  end

  def edit_privacy
  end

  def update_avatar
    redirect_set = false
    params[:user] = "" if params[:user].nil?
    if params[:user][:avatar]
      redirect_set = true
      if @user.update_attributes(:avatar => params[:user][:avatar])
        render :action => 'crop'
        flash[:notice] = t "account_settings.avatar_success"
      else
        render :action => "edit_avatar"
      end
    elsif !params[:user][:crop_x].blank? and !params[:user][:crop_y].blank? and !params[:user][:crop_w].blank? and !params[:user][:crop_h].blank?
      @user.crop_x = params[:user][:crop_x]
      @user.crop_y = params[:user][:crop_y]
      @user.crop_w = params[:user][:crop_w]
      @user.crop_h = params[:user][:crop_h]
      @user.touch
      flash[:notice] = t "account_settings.avatar_cropped"
    else
      flash[:error] = t "account_settings.avatar_not_specified"
    end
    redirect_to edit_account_path(@user, :anchor => :avatar) unless redirect_set
  end

  def instructor_agreement
    render :layout => 'content_in_tab'
  end

  def update_instructor
    update_address
    if @user.save
      flash[:notice] = t 'account_settings.update_success'
    else
      render :action => "edit_instructor"
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
      # specify the id specifically because if the user updates the login, the user won't be
      # found because of the slugging
      redirect_to edit_account_path(@user.id)
    else
      render :action => 'edit'
    end
  end

  def update_privacy
    @user.show_real_name = params[:user][:show_real_name] || false
    @user.allow_contact = params[:user][:allow_contact]

    if @user.save
      flash[:notice] = t 'account_settings.update_success'
      redirect_to edit_account_path(:anchor => :privacy)
    else
      render :action => "edit_privacy"
    end
  end

  def update_venture
    update_venture_description
    update_venture_product
    update_venture_team

    if @user.save
      flash[:notice] = t 'venture.update_success'
    else
      render :action => "edit_venture"
    end
  end

  def edit_venture
    Logger.error "edit_venture"
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
    if @current_user.is_an_admin?
      @user = User.find params[:id]
    else
      @user = @current_user
    end
  end

  # venture methods

  def venture_setup_wizard
    # redirect_to calc_venture_wizard_step_path @user.venture.wizard_step
    Logger.info "hit venture_setup_wizard"
  end

  def calc_venture_wizard_step_path step
    "venture_setup_wizard_step#{step}_account_path"
  end

  def move_venture_wizard_to_next_step
    @user.wizard_step = calc_next_venture_wizard_step
    calc_venture_wizard_step_path @user.wizard.step
  end

  def calc_next_venture_wizard_step
    @user.wizard_step + 1
  end

  def venture_setup_wizard_step1

  end

  def venture_setup_wizard_step2

  end

  def venture_setup_wizard_step3

  end

  def update_venture_wizard
    case params[:step]
      when "1" then
      when "2" then
      when "3" then
      else
        raise
    end

  end

  def show_venture
    Logger.info "show_venture"
  end

  def update_venture_description
    @user.description = params[:user][:description]
    @user.legal_entity = params[:user][:legal_entity]
    @user.state_incorporated = params[:venture][:state_incorporated]
    @user.NASIC = params[:venture][:NASIC]
    @user.finance_stage = params[:venture][:finance_stage]
    @user.development_stage = params[:venture][:development_stage]
    @user.website_URL = params[:venture][:website_URL]
    @user.has_customer = params[:venture][:has_customer]
    @user.is_paying_customer = params[:venture][:is_paying_customer]
  end

  def update_venture_product
    @user.product_name = params[:venture][:product_name]
    @user.product_description = params[:venture][:product_description]
  end

  def update_venture_team
    @user.president_needed = params[:venture][:president_needed]
    @user.CTO_needed = params[:venture][:CTO_needed]
    @user.CFO_needed = params[:venture][:CFO_needed]
    @user.advisors_needed = params[:venture][:advisors_needed]
    @user.mentor_needed = params[:venture][:mentor_needed]
    @user.graphic_designer_needed = params[:venture][:graphic_designer_needed]
    @user.product_owner_needed = params[:venture][:product_owner_needed]
    @user.scrum_master_needed = params[:venture][:scrum_master_needed]
    @user.programmer_needed = params[:venture][:programmer_needed]
    @user.architects_needed = params[:venture][:architects_needed]
    @user.sysadmins_needed = params[:venture][:sysadmins_needed]
    @user.technical_writer_needed = params[:venture][:technical_writer_needed]
    @user.marketing_needed = params[:venture][:marketing_needed]
    @user.sales_needed = params[:venture][:sales_needed]
    @user.equity_compensation = params[:venture][:equity_compensation]
    @user.cash_compensation = params[:venture][:cash_compensation]
  end

end

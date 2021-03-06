# Allow a user to request a new account
class RegistrationsController < ApplicationController
  include SslRequirement

  before_filter :require_no_user

  def new
    @registration = Registration.new
  end

  def create
    # this controller will send an email to the user to confirm their email address. Once the user clicks
    # on the link in the email, they can complete the process of requesting an account (which will then be
    # handled by the users controller).
    @registration = Registration.new(params[:registration])
    @registration.registration_code = params[:registration][:registration_code]
    @registration.facebook_id = facebook_session.user.to_i if facebook_session
    # The ActiveURL plugin can't differentiate between a creation and an update callback. So, I'm setting this
    # flag to true so that the confirmation will go out in this case, but not on subsequent updates to the
    # registration record
    @registration.send_email = true
    # If coming from facebook, we know it's not a robot
    if verify_recaptcha() or facebook_session
      if @registration.save
        flash[:notice] = t 'registration.check_email_for_registration'
        if APP_CONFIG[CONFIG_ALLOW_UNRECOGNIZED_ACCESS]
          redirect_to registration_path(@registration)
        else
          redirect_to login_path
        end
      else
        #@registration.errors.each { |attr,msg| puts "#{attr} - #{msg}" }
        render :action => "new"
      end
    else
      @registration.errors.add_to_base(I18n.t('registration.human_test_failed'))
      render :action => "new"
    end
  end

  def show
  end

  def check_user
    @user = User.find_by_login(params[:registration][:username].try(:strip))

    respond_to do |format|
      format.js
    end
  end
end

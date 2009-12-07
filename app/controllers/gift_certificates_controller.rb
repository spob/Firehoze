class GiftCertificatesController < ApplicationController
  include SslRequirement

  before_filter :require_user
  before_filter :find_gift_certificate, :only => [:redeem, :give, :pregive, :confirm_give]

  permit ROLE_PAYMENT_MGR, :only => [ :list_admin ]

  ssl_required :redeem if Rails.env.production?

  layout :layout_for_action

  verify :method => :post, :only => [ :create, :redeem, :give, :confirm_give ], :redirect_to => :home_path

  def index
    @gift_certificates = GiftCertificate.list(params[:page], current_user)
  end

  def list_admin
    @search = GiftCertificate.redeemed_at_null.search(params[:search])
    @gift_certificates = @search.paginate(:per_page => (session[:per_page] || ROWS_PER_PAGE),
                                          :page => params[:page])
  end

  def new
    @gift_certificate = GiftCertificate.new
  end

  # Redeem certificate
  def create
    code = params[:gift_certificate][:code]
    code = code.strip.gsub("-", "") unless code.nil? # strip dashes
    gift_certificate = GiftCertificate.find_by_code(code)
    if gift_certificate.nil?
      flash[:error] = t('gift_certificate.invalid_gift_certificate', :code => code)
      render 'new'
    elsif redeem_certificate(gift_certificate)
      redirect_to home_path
    else
      render 'new'
    end
  end

  # Redeem a gift certificate
  def redeem
    redeem_certificate(@gift_certificate)
    redirect_to home_path
  end

  def pregive

  end

  def confirm_give
    @to_user = User.find_by_login_or_email(params[:to_user], params[:to_user_email])
    user_str = params[:to_user]
    user_str = params[:to_user_email] if user_str.nil? or user_str.blank?
    if @to_user.nil?
      flash.now[:error] = t('gift_certificate.no_such_user', :user => user_str)
      render 'pregive'
    end
    @comments = params[:comments]
  end

  # give a certificate to someone else
  def give
    @to_user = User.find(params[:to_user_id])

    if @gift_certificate.user != current_user
      flash[:error] = t('gift_certificate.must_own_to_give')
      render 'pregive'
    else
      GiftCertificate.transaction do
        @gift_certificate.give(@to_user, params[:comments])
        RunOncePeriodicJob.create(
                :name => 'Deliver Gift Notification',
                :job => "GiftCertificate.notify_of_gift(#{@gift_certificate.id}, #{current_user.id})")
        flash[:notice] = t('gift_certificate.given',
                           :code => @gift_certificate.formatted_code, :user => @to_user.login)
        redirect_to gift_certificates_path
      end
    end
  end

  private

  def layout_for_action
    if %w(list_admin).include?(params[:action])
      'admin'
    elsif %w(new create pregive give confirm_give).include?(params[:action])
      'application_v2'
    else
      'application'
    end
  end

  def find_gift_certificate
    @gift_certificate = GiftCertificate.find(params[:id])
  end

  def redeem_certificate gift_certificate
    if gift_certificate.redeemed_at
      flash[:error] = t('gift_certificate.already_redeemed', :code => gift_certificate.formatted_code)
      return false
    else
      GiftCertificate.transaction do
        gift_certificate.redeem(current_user)
        flash[:notice] = t('gift_certificate.redeemed', :code => gift_certificate.formatted_code,
                           :num => gift_certificate.credit_quantity)
        return true
      end
    end
  end
end

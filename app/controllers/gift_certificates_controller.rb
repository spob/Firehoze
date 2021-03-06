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
    @gift_certificates = @search.paginate(:per_page => (cookies[:per_page] || ROWS_PER_PAGE),
                                          :page => params[:page])
  end

  def new
    @gift_certificate = GiftCertificate.new
  end

  # Redeem certificate
  def create
    code = params[:gift_certificate][:code]
    gift_certificate = GiftCertificate.find_by_code(cleanup_code(code))
    if gift_certificate.nil?
      flash[:error] = t('gift_certificate.invalid_gift_certificate', :code => code)
      render 'new'
    elsif redeem_certificate(gift_certificate)
      redirect_to account_history_my_firehoze_path(:anchor => 'giftcerts')
    else
      render 'new'
    end
  end

  # Redeem a gift certificate
  def redeem
    redeem_certificate(@gift_certificate)
    redirect_to account_history_my_firehoze_path(:anchor => 'giftcerts')
  end

  def pregive

  end

  def confirm_give
    @gift_certificate.to_user = params[:gift_certificate][:to_user]
    @gift_certificate.to_user_email = params[:gift_certificate][:to_user_email]
    @gift_certificate.give_comments = params[:gift_certificate][:give_comments]

    @to_user = User.find_by_login_or_email(@gift_certificate.to_user, @gift_certificate.to_user_email)
    user_str = (@gift_certificate.to_user.blank? ? @gift_certificate.to_user_email : @gift_certificate.to_user)
    if @to_user.nil?
      flash.now[:error] = t('gift_certificate.no_such_user', :user => user_str)
      render 'pregive'
    end
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
        flash[:notice] = t('gift_certificate.given', :code => @gift_certificate.formatted_code, :user => @to_user.login)
        redirect_to account_history_my_firehoze_path(:anchor => 'giftcerts')
      end
    end
  end

  def check_gift_certificate_code
    code = params[:gift_certificate][:code]
    @gift_certificate = GiftCertificate.find_by_code(cleanup_code(code))
    @gift_certificate = nil if @gift_certificate.try(:redeemed_at)
    respond_to do |format|
      format.js
    end
  end

  private

  def layout_for_action
    if %w(list_admin).include?(params[:action])
      'admin'
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
      false
    else
      GiftCertificate.transaction do
        gift_certificate.redeem(current_user)
        flash[:notice] = t('gift_certificate.redeemed', :code => gift_certificate.formatted_code,
                           :num => gift_certificate.credit_quantity)
        true
      end
    end
  end

  def cleanup_code(code)
    code.strip.gsub("-", "") unless code.nil? # strip dashes
  end
end

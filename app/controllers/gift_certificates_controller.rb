class GiftCertificatesController < ApplicationController
  before_filter :require_user
  before_filter :find_gift_certificate, :only => [:redeem, :give, :pregive]

  verify :method => :post, :only => [ :create, :redeem, :give ], :redirect_to => :home_path

  def index
    @gift_certificates = GiftCertificate.list(params[:page], current_user)
  end

  def new
    @gift_certificate = GiftCertificate.new
  end

  def create
    code = params[:gift_certificate][:code]
    code = code.strip.gsub("-", "") unless code.nil?  # strip dashes
    gift_certificate = GiftCertificate.find_by_code(code)
    if gift_certificate.nil?
      flash[:error] = t('gift_certificate.invalid_gift_certificate', :code => code)
      render 'new'
    elsif redeem_certificate(gift_certificate)
      redirect_to account_path
    else
      render 'new'
    end
  end

  # Redeem a gift certificate
  def redeem
    redeem_certificate(@gift_certificate)
    redirect_to account_path
  end

  def pregive

  end

  # give a certificate to someone else
  def give
    @to_user = User.find_by_login(params[:to_user])
    UserSession.create @user
    if @to_user.nil?
      flash[:error] = t('gift_certificate.no_such_user', :user => params[:to_user])
      render 'pregive'
    elsif @gift_certificate.user != current_user
      flash[:error] = t('gift_certificate.must_own_to_give')
      render 'pregive'
    else
      @gift_certificate.give(@to_user, params[:comments])
      flash[:notice] = t('gift_certificate.given',
                         :code => @gift_certificate.formatted_code, :user => @to_user.login)
      redirect_to gift_certificates_path
    end
  end

  private

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

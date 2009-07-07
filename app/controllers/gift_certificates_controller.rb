class GiftCertificatesController < ApplicationController
  before_filter :require_user

  verify :method => :post, :only => [ :create, :redeem ], :redirect_to => :home_path

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
    @gift_certificate = GiftCertificate.find(params[:id])
    redeem_certificate(@gift_certificate)
    redirect_to account_path
  end

  private

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

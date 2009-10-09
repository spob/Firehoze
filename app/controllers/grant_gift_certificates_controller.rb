class GrantGiftCertificatesController < ApplicationController
  include SslRequirement

  before_filter :require_user

  permit ROLE_PAYMENT_MGR

  layout 'admin'

  verify :method => :post, :only => [ :create ], :redirect_to => :home_path

  def new
    @gift_certificate = GiftCertificate.new
  end

  def create
    @gift_certificate = GiftCertificate.new(params[:gift_certificate])
    @gift_certificate.gift_certificate_sku = GiftCertificateSku.find_by_sku(GIFT_CERTIFICATE_SKU)
    @gift_certificate.price = 0.0
    if @gift_certificate.save
      flash[:notice] = t('gift_certificate.create_success')
      redirect_to list_admin_gift_certificates_path
    else
      render :action => :new
    end
  end
end
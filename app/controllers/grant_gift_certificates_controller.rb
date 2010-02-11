class GrantGiftCertificatesController < ApplicationController
  include SslRequirement

  before_filter :require_user

  permit ROLE_PAYMENT_MGR

  layout 'admin'

  verify :method => :post, :only => [ :create ], :redirect_to => :home_path

  def new
    @gift_certificate = GiftCertificate.new(:price => 0.0, :quantity_to_grant => 1, :credit_quantity => 5)
  end

  def create
    if params[:gift_certificate][:quantity_to_grant] and (params[:gift_certificate][:quantity_to_grant].match(/\A[+]?\d+?(\d+)?\Z/) == nil ? false : true) and params[:gift_certificate][:quantity_to_grant].to_i > 0 
      qty = params[:gift_certificate][:quantity_to_grant].to_i
      @gift_certificate = GiftCertificate.new(params[:gift_certificate])
      @gift_certificate.gift_certificate_sku = GiftCertificateSku.find_by_sku(GIFT_CERTIFICATE_SKU)
      if @gift_certificate.save
        flash[:notice] = t('gift_certificate.create_success')
        redirect_to list_admin_gift_certificates_path
      else
        render :action => :new
      end
    else
      flash[:error] = "Quantity to grant must be a positive integer"
      redirect_to new_grant_gift_certificate_path
    end
  end
end
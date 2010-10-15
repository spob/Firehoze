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
    @gift_certificate = GiftCertificate.new(params[:gift_certificate])
    @gift_certificate.to_user = params[:gift_certificate][:to_user]
    @gift_certificate.to_user_email = params[:gift_certificate][:to_user_email]
    @to_user = User.find_by_login_or_email(@gift_certificate.to_user, @gift_certificate.to_user_email)
    user_str = (@gift_certificate.to_user.blank? ? @gift_certificate.to_user_email : @gift_certificate.to_user)
    if @to_user.nil?
      flash.now[:error] = t('gift_certificate.no_such_user', :user => user_str)
      render 'new'
    elsif params[:gift_certificate][:quantity_to_grant] and (params[:gift_certificate][:quantity_to_grant].match(/\A[+]?\d+?(\d+)?\Z/) == nil ? false : true) and params[:gift_certificate][:quantity_to_grant].to_i > 0
      @gift_certificate.user = @to_user
      qty = params[:gift_certificate][:quantity_to_grant].to_i
      success = true
      @gift_certificate.gift_certificate_sku = GiftCertificateSku.find_by_sku(GIFT_CERTIFICATE_SKU)
      GiftCertificate.transaction do
        qty.times do
          @new_gift_certificate = @gift_certificate.clone
          if !@new_gift_certificate.save
            success = false
            break
          end
        end
      end
      if success
        flash[:notice] = t('gift_certificate.create_success')
        redirect_to list_admin_gift_certificates_path
      else
        render :action => :new
      end
    else
      flash[:error] = "Quantity to grant must be a positive integer"
      render 'new'
    end
  end
end
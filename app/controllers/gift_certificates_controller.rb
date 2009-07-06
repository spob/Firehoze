class GiftCertificatesController < ApplicationController
  before_filter :require_user

  verify :method => :post, :only => [:redeem ], :redirect_to => :home_path

  # Redeem a gift certificate
  def redeem
    @gift_certificate = GiftCertificate.find(params[:id])
    if @gift_certificate.redeemed_at
      flash[:error] = t('gift_certificate.already_redeemed', :code => @gift_certificate.code)
    else
      GiftCertificate.transaction do
        @gift_certificate.redeem(current_user)
        flash[:notice] = t('gift_certificate.redeemed', :code => @gift_certificate.formatted_code,
                           :num => @gift_certificate.credit_quantity)
      end
    end
    redirect_to account_path
  end
end

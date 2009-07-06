require 'test_helper'

class GiftCertificatesControllerTest < ActionController::TestCase

  context "when logged on" do
    setup do
      activate_authlogic
      @user = Factory(:user)
      UserSession.create @user
    end

    context "with a gift_certificate" do
      setup { @gift_certificate = Factory.create(:gift_certificate) }
      
      context "on POST to :redeem" do
        setup do
          post :redeem, :id => @gift_certificate
        end

        should_assign_to :gift_certificate
        should_respond_with :redirect
        should_set_the_flash_to /redeemed/
        should_redirect_to("account page") { account_path }
      end
    end
  end
end

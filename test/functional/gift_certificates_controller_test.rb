require 'test_helper'

class GiftCertificatesControllerTest < ActionController::TestCase

  context "when logged on" do
    setup do
      activate_authlogic
      @user = Factory(:user)
      UserSession.create @user
    end

    context "on GET to :new" do
      setup { get :new }

      should_not_set_the_flash
      should_render_template 'new'
    end

    context "with a gift_certificate" do
      setup { @gift_certificate = Factory.create(:gift_certificate, :user => @user) }

      context "on POST to :redeem" do
        setup { post :redeem, :id => @gift_certificate }

        should_assign_to :gift_certificate
        should_respond_with :redirect
        should_set_the_flash_to /redeemed/
        should_redirect_to("account page") { account_path }
      end

      context "on POST to :create" do
        setup { post :create, :gift_certificate => { :code => @gift_certificate.code }}

        should_not_assign_to :gift_certificate
        should_respond_with :redirect
        should_set_the_flash_to /redeemed/
        should_redirect_to("account page") { account_path }
      end

      context "on GET to :pregive" do
        setup { get :pregive, :id => @gift_certificate }

        should_not_set_the_flash
        should_render_template 'pregive'
      end

      context "on POST to :confirm_give" do
        setup do
          @to_user = Factory.create(:user)
        end

        context "specifying the username" do
          setup { post :confirm_give, :id => @gift_certificate, :to_user => @to_user.login, :comments => 'hello' }

          should_assign_to :gift_certificate
          should_respond_with :success
          should_not_set_the_flash
          should_render_template 'confirm_give'
        end

        context "specifying the email" do
          setup { post :confirm_give, :id => @gift_certificate, :to_user_email => @to_user.email, :comments => 'hello' }

          should_assign_to :gift_certificate
          should_respond_with :success
          should_not_set_the_flash
          should_render_template 'confirm_give'
        end

        context "with a bogus user" do
          setup do
            post :confirm_give, :id => @gift_certificate, :to_user => 'xyz'
          end
          should_assign_to :gift_certificate
          should_respond_with :success
          should_set_the_flash_to /The user .* is not recognized/
          should_render_template 'pregive'
        end
      end

      context "on POST to :give" do
        setup { @to_user = Factory.create(:user)}

        context "on a gift certificate you don't own" do
          setup do
            @gift_certificate.update_attribute(:user, Factory.create(:user))
            post :give, :id => @gift_certificate, :to_user_id => @to_user, :comments => 'hello'
          end
          should_assign_to :gift_certificate
          should_respond_with :success
          should_set_the_flash_to /You can only give a certificate that you own/
          should_render_template 'pregive'
        end

        context "specifying user" do
          setup { post :give, :id => @gift_certificate, :to_user_id => @to_user, :comments => 'hello' }

          should "update gift certificate" do
            @gift_certificate = GiftCertificate.find(@gift_certificate)
            assert_equal 'hello', @gift_certificate.comments
            assert_equal @to_user, @gift_certificate.user
          end
          should_assign_to :gift_certificate
          should_respond_with :redirect
          should_set_the_flash_to /successfully given/
          should_redirect_to("gift certificates page") { gift_certificates_path }
        end

        #context "specifying email" do
        #  setup { post :give, :id => @gift_certificate, :to_user_email => @to_user.email, :comments => 'hello22'}
        #
        #  should "update gift certificate" do
        #    @gift_certificate = GiftCertificate.find(@gift_certificate)
        #    assert_equal 'hello22', @gift_certificate.comments
        #    assert_equal @to_user, @gift_certificate.user
        #  end
        #  should_assign_to :gift_certificate
        #  should_respond_with :redirect
        #  should_set_the_flash_to /successfully given/
        #  should_redirect_to("gift certificates page") { gift_certificates_path }
        #end
      end
    end
  end
end
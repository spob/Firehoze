require File.dirname(__FILE__) + '/../test_helper'

class AccountsControllerTest < ActionController::TestCase

  context "when logged on" do
    setup do
      activate_authlogic
      @user = Factory.create(:user)
      UserSession.create(@user)
      PaymentLevel.delete_all
      @payment_level1 = Factory.create(:payment_level, :default_payment_level => true)
      @payment_level2 = Factory.create(:payment_level, :code => "xxx", :default_payment_level => false)
    end

    context "on GET to :show" do
      setup { get :show, :id => @user }

      should_assign_to :user
      should_respond_with :success
      should_not_set_the_flash
      should_render_template "show"
    end

    context "on POST to clear_avatar" do
      setup { post :clear_avatar, :id => @user }

      should_assign_to :user
      should_respond_with :redirect
      should_set_the_flash_to :avatar_cleared
      should_redirect_to("edit account page") { edit_account_path(assigns(:user)) }
    end

    context "on GET to :edit" do
      setup { get :edit, :id => Factory(:user).id }

      should_assign_to :user
      should_respond_with :success
      should_not_set_the_flash
      should_render_template "edit"
    end

    context "on PUT to :update" do
      setup { put :update, :id => @user, :user => Factory.attributes_for(:user) }

      should_assign_to :user
      should_respond_with :redirect
      should_set_the_flash_to :profile_update_success
      should_redirect_to("edit account page") { edit_account_path(assigns(:user)) }
    end

    context "on PUT to :update_privacy" do
      setup do
        assert !@user.show_real_name
        put :update_privacy, :id => @user, :user => { :show_real_name => true }
        @user = User.find(@user)
      end

      should_assign_to :user
      should_respond_with :redirect
      should_set_the_flash_to :profile_update_success
      should_redirect_to("edit account page") { edit_account_path(assigns(:user)) }
      should "set show real name" do
        assert @user.show_real_name
      end
    end

    context "on PUT to :update with bad value" do
      setup { put :update, :id => @user, :user => Factory.attributes_for(:user, :last_name => "") }

      should_assign_to :user
      should_respond_with :redirect
      should_set_the_flash_to I18n.t('account_settings.update_error')
      should_redirect_to("edit account screen") { edit_account_path(assigns(:user)) }
    end

    context "on GET to :instructor_signup_wizard" do
      setup { get :instructor_signup_wizard, :id => @user }

      should_assign_to :user
      should_respond_with :redirect
      should_not_set_the_flash
      should_redirect_to("first wizard step") {instructor_wizard_step1_account_path(assigns(:user)) }
    end

    context "on PUT to :update_instructor_wizard" do
      setup { put :update_instructor_wizard, :id => @user, :step => 1, :accept_agreement => 1  }

      should_assign_to :user
      should_respond_with :redirect
      should_not_set_the_flash
      should_redirect_to("second wizard step") {instructor_wizard_step2_account_path(assigns(:user)) }
    end

    context "on GET to :instructor_wizard_step2 when jumping ahead" do
      setup { get :instructor_wizard_step2, :id => @user }

      should_assign_to :user
      should_respond_with :redirect
      should_set_the_flash_to :wizard_jump_head
      should_redirect_to("first wizard step") {instructor_wizard_step1_account_path(assigns(:user)) }
    end

    context "when having accepted user agreement" do
      setup do
        @user.update_attribute(:author_agreement_accepted_on, Time.now)
      end

      context "on GET to :instructor_signup_wizard" do
        setup { get :instructor_signup_wizard, :id => @user }

        should_assign_to :user
        should_respond_with :redirect
        should_not_set_the_flash
        should_redirect_to("first wizard step") {instructor_wizard_step2_account_path(assigns(:user)) }
      end

      context "on GET to :instructor_wizard_step3 when jumping ahead" do
        setup { get :instructor_wizard_step3, :id => @user }

        should_assign_to :user
        should_respond_with :redirect
        should_set_the_flash_to :wizard_jump_head
        should_redirect_to("second wizard step") {instructor_wizard_step2_account_path(assigns(:user)) }
      end

      context "on PUT to :update_instructor_wizard" do
        setup { put :update_instructor_wizard, :id => @user, :step => 2, :user => { :payment_level => PaymentLevel.first }  }

        should_assign_to :user
        should_respond_with :redirect
        should_not_set_the_flash
        should_redirect_to("third wizard step") {instructor_wizard_step3_account_path(assigns(:user)) }
      end

      context "when having selected payment level" do
        setup do
          @user.update_attribute(:payment_level, PaymentLevel.first)
        end

        context "on GET to :instructor_signup_wizard" do
          setup { get :instructor_signup_wizard, :id => @user }

          should_assign_to :user
          should_respond_with :redirect
          should_not_set_the_flash
          should_redirect_to("first wizard step") {instructor_wizard_step3_account_path(assigns(:user)) }
        end

        context "on GET to :instructor_wizard_step4 when jumping ahead" do
          setup { get :instructor_wizard_step4, :id => @user }

          should_assign_to :user
          should_respond_with :redirect
          should_set_the_flash_to :wizard_jump_head
          should_redirect_to("second wizard step") {instructor_wizard_step3_account_path(assigns(:user)) }
        end

        context "on PUT to :update_instructor_wizard" do
          setup { put :update_instructor_wizard, :id => @user, :step => 3,
                      :user => { :address1 => "aaa", :city => "yyy", :state => "XX", :postal_code => "99999",
                                 :country => "US" }  }

          should_assign_to :user
          should_respond_with :redirect
          should_not_set_the_flash
          should_redirect_to("fourth wizard step") {instructor_wizard_step4_account_path(assigns(:user)) }
        end

        context "when having entered an address" do
          setup do
            @user.address1 = "xxx"
            @user.city = "yyy"
            @user.state = "XXX"
            @user.postal_code = "99999"
            @user.country = "US"
            @user.save!
            assert @user.address_provided?
          end

          context "on GET to :instructor_signup_wizard" do
            setup { get :instructor_signup_wizard, :id => @user }

            should_assign_to :user
            should_respond_with :redirect
            should_not_set_the_flash
            should_redirect_to("fourth wizard step") {instructor_wizard_step4_account_path(assigns(:user)) }
          end

          context "on GET to :instructor_wizard_step4 when jumping ahead" do
            setup { get :instructor_wizard_step5, :id => @user }

            should_assign_to :user
            should_respond_with :redirect
            should_set_the_flash_to :wizard_jump_head
            should_redirect_to("fourth wizard step") {instructor_wizard_step4_account_path(assigns(:user)) }
          end

          context "on PUT to :update_instructor_wizard" do
            setup do
              put :update_instructor_wizard, :id => @user, :step => 4,
                  :confirm_contact => 1
              @user = User.find(@user)
            end

            should_assign_to :user
            should_respond_with :redirect
            should_not_set_the_flash
            should_redirect_to("five wizard step") {instructor_wizard_step5_account_path(assigns(:user)) }
            should "be an instructor?" do
              assert @user.verified_instructor?
            end
          end

          context "on PUT to :update_instructor with no change" do
            setup do
              @user.update_attribute(:verified_address_on, Time.now)
              put :update_instructor, :id => @user, :step => 3,
                  :user => { :address1 => @user.address1,
                             :address2 => @user.address2,
                             :city => @user.city,
                             :state => @user.state,
                             :postal_code => @user.postal_code,
                             :country => @user.country }
              @user = User.find(@user)
            end

            should_assign_to :user
            should_respond_with :redirect
            should_set_the_flash_to /successfully updated/
            should_redirect_to("edit account") {edit_account_path(assigns(:user)) }
            should "be an instructor?" do
              assert @user.verified_instructor?
            end
          end

          context "on PUT to :update_instructor with a change" do
            setup do
              @user.update_attribute(:verified_address_on, Time.now)
              put :update_instructor, :id => @user, :step => 3,
                  :user => { :address1 => @user.address1 + "xxx",
                             :address2 => @user.address2,
                             :city => @user.city,
                             :state => @user.state,
                             :postal_code => @user.postal_code,
                             :country => @user.country }
              @user = User.find(@user)
            end

            should_assign_to :user
            should_respond_with :redirect
            should_set_the_flash_to :confirm_address
            should_redirect_to("three wizard step") {instructor_wizard_step4_account_path(assigns(:user)) }
            should "not be an instructor?" do
              assert !@user.verified_instructor?
            end
          end

          context "when having confirmed the address" do
            setup do
              @user.verified_address_on = Time.now
              @user.save!
            end

            context "on GET to :instructor_signup_wizard" do
              setup { get :instructor_signup_wizard, :id => @user }

              should_assign_to :user
              should_respond_with :redirect
              should_not_set_the_flash
              should_redirect_to("fifth wizard step") {instructor_wizard_step5_account_path(assigns(:user)) }
            end
          end
        end
      end
    end
  end
end
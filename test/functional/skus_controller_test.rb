require 'test_helper'

class SkusControllerTest < ActionController::TestCase

  context "when not logged on" do
    context "on GET to :new" do
      setup { get :new }

      should_not_assign_to :sku
      should_respond_with :redirect
      should_set_the_flash_to /You must be logged in/
      should_redirect_to("login page") { new_user_session_url }
    end
  end

  context "when logged on" do
    setup do
      activate_authlogic
      @user = Factory(:user)
      UserSession.create @user
    end

    context "with sysadmin access" do
      setup do
        @user.has_role 'sysadmin'
        @sku = Factory.create(:credit_sku)
      end

      context "on GET to :index" do
        setup { get :index }

        should_assign_to :skus
        should_respond_with :success
        should_not_set_the_flash
        should_render_template "index"
      end

      context "on GET to :new" do
        setup { get :new }

        should_assign_to :sku
        should_respond_with :success
        should_not_set_the_flash
        should_render_template "new"
      end

      context "on POST to :create" do
        setup do
          sku_attrs = Factory.attributes_for(:credit_sku).merge!({:type => 'CreditSku'})
            post :create, :sku => sku_attrs
        end

        should_assign_to :sku
        should_respond_with :redirect
        should_set_the_flash_to "SKU saved"
        should_redirect_to("SKU index page") { skus_url }
      end

      context "with at least one existing sku" do
        setup do
          @sku = Factory.create(:credit_sku)
        end

        context "on GET to :edit" do
          setup { get :edit, :id => @sku }
          should_assign_to :sku
          should_respond_with :success
          should_not_set_the_flash
          should_render_template "edit"
        end

        context "on PUT to :update" do
          setup { put :update, :id => @sku.id, :sku => Factory.attributes_for(:credit_sku) }

          should_set_the_flash_to :sku_update_success
          should_assign_to :sku
          should_respond_with :redirect
          should_redirect_to("sku page") { skus_path }
        end
      end
    end

    context "without sysadmin access" do
      context "on GET to :index" do
        setup { get :index }

        should_not_assign_to :skus
        should_respond_with :redirect
        should_set_the_flash_to /denied/
        should_redirect_to("home page") { home_url }
      end
    end
  end
end

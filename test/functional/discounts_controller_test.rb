require File.dirname(__FILE__) + '/../test_helper'
require 'fast_context'

class DiscountsControllerTest < ActionController::TestCase

  fast_context "when logged on" do
    setup do
      activate_authlogic
      @user = Factory(:user)
      UserSession.create @user
    end

    fast_context "with a sku defined" do
      setup { @sku = Factory.create(:credit_sku) }

      fast_context "and a range of discounts" do
        setup do
          @discount5 = Factory.create(:discount_by_volume, :minimum_quantity => 5, :percent_discount => 0.05, :sku => @sku)
          @discount10 = Factory.create(:discount_by_volume, :minimum_quantity => 10, :percent_discount => 0.10, :sku => @sku)
          @discount20 = Factory.create(:discount_by_volume, :minimum_quantity => 20, :percent_discount => 0.20, :sku => @sku)
        end

        fast_context "without admin access" do
          context "on GET to :index" do
            setup { get :index, :sku_id => @sku }

            should_not_assign_to :discounts
            should_respond_with :redirect
            should_set_the_flash_to /Permission denied/
          end
        end

        fast_context "with admin access" do
          setup do
            @user.has_role 'admin'
            @sku = Factory.create(:credit_sku)
          end

          fast_context "on GET to :index" do
            setup { get :index, :sku_id => @sku }

            should_assign_to :discounts
            should_respond_with :success
            should_not_set_the_flash
            should_render_template "index"
          end

          fast_context "on GET to :new" do
            setup { get :new, :sku_id => @sku }

            should_assign_to :discount
            should_respond_with :success
            should_not_set_the_flash
            should_render_template "new"
          end

          fast_context "on POST to :create" do
            setup do
              discount_attrs = Factory.attributes_for(:discount_by_volume).merge!(:type => 'DiscountByVolume')
              post :create, :discount => discount_attrs, :sku_id => @sku
            end

            should_assign_to :discount
            should_respond_with :redirect
            should_set_the_flash_to /Successfully created discount/
            should_redirect_to("Discounts index page") { sku_discounts_url(@sku) }
          end

          fast_context "on POST to :create with bad value" do
            setup do
              discount_attrs = Factory.attributes_for(:discount_by_volume,
                                                      :minimum_quantity => -1).merge!(:type => 'DiscountByVolume')
              post :create, :discount => discount_attrs, :sku_id => @sku
            end

            should_assign_to :discount
            should_render_template 'new'
            should_not_set_the_flash
          end

          fast_context "on GET to :edit" do
            setup { get :edit, :id => @discount5 }

            should_assign_to :discount
            should_respond_with :success
            should_not_set_the_flash
            should_render_template "edit"
          end

          fast_context "on PUT to :update" do
            setup { put :update, :id => @discount5, :discount => @discount5.attributes }

            should_set_the_flash_to /Successfully updated discount/
            should_assign_to :discount
            should_respond_with :redirect
            should_redirect_to("Discounts index page") { sku_discounts_url(@discount5.sku) }
          end

          fast_context "on PUT to :update with bad value" do
            setup do
              @discount5.update_attribute(:minimum_quantity, -1)
              put :update, :id => @discount5, :discount => @discount5.attributes
            end

            should_not_set_the_flash
            should_assign_to :discount
            should_render_template('edit')
          end

          fast_context "on DELETE to :destroy" do
            setup { delete :destroy, :id => @discount5 }

            should_set_the_flash_to /Successfully destroyed discount/
            should_respond_with :redirect
            should_redirect_to("Discounts index page") { sku_discounts_url(@discount5.sku) }
          end
        end
      end
    end
  end
end

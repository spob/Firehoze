require File.dirname(__FILE__) + '/../test_helper'
require 'fast_context'

class PaymentsControllerTest < ActionController::TestCase

  fast_context "with unpaid credits" do
    setup do
      activate_authlogic
      @lesson = Factory.create(:lesson)
      @lesson.instructor.update_attribute(:payment_level, Factory.create(:payment_level))
      @credit = Factory.create(:credit, :user => @lesson.instructor, :lesson => @lesson)
      assert_not_nil @credit.user
    end

    fast_context "when logged in" do
      setup do
        @user = Factory(:user)
        UserSession.create @user
      end

      fast_context "as a regular user" do
        fast_context "on GET to show_unpaid" do
          setup { get :show_unpaid, :id => @lesson.instructor }

          should_assign_to :user
          should_respond_with :redirect
          should_set_the_flash_to /not have permissions/
        end

        fast_context "on GET to show" do
          setup do
            @payment = @lesson.instructor.generate_payment
            @payment.save
            get :show, :id => @payment
          end

          should_assign_to :payment
          should_respond_with :redirect
          should_set_the_flash_to /not have permissions/
        end

        fast_context "on GET to list" do
          setup { get :list, :id => @lesson.instructor }

          should_assign_to :user
          should_not_assign_to :payments
          should_respond_with :redirect
          should_set_the_flash_to /not have permissions/
        end
      end

      fast_context "as a payment mgr" do
        setup { @user.is_paymentmgr }

        fast_context "on GET to index" do
          setup { get :index }

          should_assign_to :users
          should_respond_with :success
          should_not_set_the_flash
          should_render_template "index"
        end

        fast_context "on GET to list" do
          setup { get :list, :id => @lesson.instructor }

          should_assign_to :user
          should_assign_to :payments
          should_respond_with :success
          should_not_set_the_flash
          should_render_template "list"
        end

        fast_context "on GET to show_unpaid" do
          setup { get :show_unpaid, :id => @lesson.instructor }

          should_assign_to :user
          should_respond_with :success
          should_not_set_the_flash
          should_render_template "show_unpaid"
        end

        fast_context "on POST to create" do
          setup do
            assert_equal 0.25,  @lesson.instructor.payment_level.rate
            post :create, :id => @lesson.instructor
            @credit = Credit.find(@credit)
          end

          should_assign_to :user
          should_assign_to :payment
          should_respond_with :redirect
          should_set_the_flash_to /created/
          should_redirect_to("payment show page") { payment_path(assigns(:payment)) }
          should "create payment properly" do
            assert !@credit.payment.nil?
            assert_equal 0.24, @credit.commission_paid
            assert !assigns(:payment).credits.empty?
            assert_equal 1, assigns(:payment).credits.size
            assert_equal 0.24, assigns(:payment).amount
          end
        end

        fast_context "on GET to show" do
          setup do
            @payment = @lesson.instructor.generate_payment
            @payment.save
            assert !@payment.credits.empty?
            assert_equal 1, @payment.credits.size
            assert_equal 0.24, @payment.amount
            get :show, :id => @payment
          end

          should_assign_to :payment
          should_respond_with :success
          should_not_set_the_flash
          should_render_template "show"
        end
      end

      fast_context "as an instructor" do
        setup do
          @user = @lesson.instructor.reload
          UserSession.create @user
        end

        fast_context "on GET to index" do
          setup { get :index }

          should_not_assign_to :users
          should_respond_with :redirect
          should_set_the_flash_to /Permission denied/
        end

        fast_context "on GET to show_unpaid" do
          setup { get :show_unpaid, :id => @lesson.instructor }

          should_assign_to :user
          should_respond_with :success
          should_not_set_the_flash
          should_render_template "show_unpaid"
        end

        fast_context "on GET to show" do
          setup do
            @payment = @lesson.instructor.generate_payment
            @payment.save
            assert !@payment.credits.empty?
            assert_equal 1, @payment.credits.size
            assert_equal 0.24, @payment.amount
            get :show, :id => @payment
          end

          should_assign_to :payment
          should_respond_with :success
          should_not_set_the_flash
          should_render_template "show"
        end
      end
    end
  end
end

require File.dirname(__FILE__) + '/../test_helper'
require 'fast_context'

class CategoriesControllerTest < ActionController::TestCase
  fast_context "when logged on" do
    setup do
      activate_authlogic
      @user = Factory(:user)
      UserSession.create @user
    end

    fast_context "without moderator access" do
      context "on GET to :index" do
        setup { get :index }

        should_respond_with :redirect
        should_set_the_flash_to /Permission denied/
        should_redirect_to("home page") { lessons_path }
      end
    end

    fast_context "with admin access" do
      setup { @user.has_role 'admin' }

      fast_context "with existing categories" do
        setup { @category = Factory.create(:category) }
        subject { @category }

        fast_context "on GET to :show" do
          setup { get :show, :id => @category, :return_path => root_url }

          should "set the category in the session" do
            assert_equal @category.id, session[:browse_category_id]
          end
          should_respond_with :redirect
          should_not_set_the_flash
          should_redirect_to("Root pagee") { root_url }
        end

        fast_context "on GET to :show to reset the category" do
          setup do
            session[:browse_category_id] = @category.id
            assert_equal @category.id, session[:browse_category_id]
            get :show, :id => "all", :return_path => root_url
          end

          should "unset the category in the session" do
            assert_nil session[:browse_category_id]
          end
          should_respond_with :redirect
          should_not_set_the_flash
          should_redirect_to("Root page") { root_url }
        end

        fast_context "on GET to :index" do
          setup { get :index }

          should_assign_to :categories
          should_assign_to :category
          should_respond_with :success
          should_not_set_the_flash
          should_render_template "index"
        end

        fast_context "on DELETE to :destroy" do
          setup { delete :destroy, :id => @category }

          should_set_the_flash_to /Successfully deleted/
          should_respond_with :redirect
          should_redirect_to("Categories index page") { categories_url }
        end

        fast_context "on GET to :edit" do
          setup { get :edit, :id => @category }

          should_assign_to :category
          should_respond_with :success
          should_not_set_the_flash
          should_render_template "edit"
        end

        fast_context "on PUT to :update" do
          setup { put :update, :id => @category, :category => @category.attributes }

          should_set_the_flash_to /Successfully updated category/
          should_assign_to :category
          should_respond_with :redirect
          should_redirect_to("Category index page") { categories_url }
        end

        fast_context "on PUT to :update with bad value" do
          setup do
            @category.sort_value = nil
            put :update, :id => @category, :category => @category.attributes
          end

          should_not_set_the_flash
          should_assign_to :category
          should_render_template('edit')
        end
      end

      fast_context "on POST to :create" do
        setup do
          post :create, :category => Factory.attributes_for(:category)
        end

        should_assign_to :category
        should_respond_with :redirect
        should_set_the_flash_to /Successfully created category/
        should_redirect_to("Categories index page") { categories_url }
      end

      fast_context "on POST to :create with bad value" do
        setup do
          post :create, :category => Factory.attributes_for(:category, :sort_value => "aaa")
        end

        should_assign_to :category
        should_redirect_to("Categories index page") { categories_url }
        should_set_the_flash_to /failed/
      end

      fast_context "on POST to :explode" do
        setup do
          @count = PeriodicJob.count
          post :explode
        end

        should_respond_with :redirect
        should_set_the_flash_to /Started exploding categories/
        should_redirect_to("Categories index page") { categories_url }
        should "create job" do
          assert_equal @count + 1, PeriodicJob.count
        end
      end
    end
  end
end
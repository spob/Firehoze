require File.dirname(__FILE__) + '/../test_helper'

class UsersControllerTest < ActionController::TestCase

  context "while not logged on" do
    #context "with a pending registration" do
    #    @registration = Registration.new(Factory.attributes_for(:user))
    #end
    #
    #context "on GET to :new" do
    #  setup { get new_registration_user_url(@registration) }
    #
    #  should_assign_to :user
    #  should_assign_to :registration
    #  should_respond_with :success
    #  should_not_set_the_flash
    #  should_render_template "new"
    #end

    #  context "on POST to :create" do
    #    setup do
    #      post :create, :user => Factory.attributes_for(:user)
    #    end
    #
    #    should_assign_to :user
    #    should_respond_with :redirect
    #    should_set_the_flash_to "Account registered!"
    #    should_redirect_to("user page") { user_url(assigns(:user)) }
    #  end
  end

  context "when logged on" do
    setup do
      activate_authlogic
      @user = Factory(:user)
      @other_user = Factory(:user)
      UserSession.create @user
    end

    context "with admin access" do
      setup do
        @user.has_role 'admin'
      end

      context "on GET to :list" do
        setup { get :list }

        should_assign_to :users
        should_respond_with :success
        should_not_set_the_flash
        should_render_template "list"
      end

      context "on GET to :show" do
        setup { get :show, :id => @other_user.id }

        should_assign_to :user
        should_respond_with :success
        should_not_set_the_flash
        should_render_template "show"
      end

      context "for an inactive user" do
        setup do
          @other_user.update_attribute(:active, false)
        end

        context "on GET to :show" do
          setup { get :show, :id => @other_user.id }

          should_assign_to :user
          should_respond_with :redirect
          should_set_the_flash_to /account has been deactivated/
          should_redirect_to("lessons page") {lessons_path }
        end

        context "as a moderator" do
          setup do
            @user.has_role 'moderator'
          end

          context "on GET to :show" do
            setup { get :show, :id => @other_user.id }

            should_assign_to :user
            should_respond_with :success
            should_not_set_the_flash
            should_render_template "show"
          end
        end
      end

      context "on GET to :edit" do
        setup { get :edit, :id => @other_user.id }
        should_assign_to :user
        should_respond_with :success
        should_not_set_the_flash
        should_render_template "edit"
      end

      context "with an existing lesson" do
        setup do
          @lesson = Factory.create(:lesson, :instructor => @other_user)
          assert_equal LESSON_STATUS_PENDING, @lesson.status
        end

        context "on PUT to :update a profile screen" do
          setup do
            put :update, :id => @other_user.id, :user => @other_user
            @lesson = Lesson.find(@lesson)
          end

          should_assign_to :user
          should_respond_with :redirect
          should_set_the_flash_to :account_update_success
          should_redirect_to("user page") { edit_user_url(@other_user) }
          should "not change the status" do
            assert_equal LESSON_STATUS_PENDING, @lesson.status
          end
        end

        context "with inactivate the user" do
          setup { @other_user.active = false }

          context "on PUT to :update" do
            setup do
              put :update, :id => @other_user.id, :user => @other_user
              @lesson = Lesson.find(@lesson)
            end

            should_assign_to :user
            should_respond_with :redirect
            should_set_the_flash_to :account_update_success
            should_redirect_to("user page") { edit_user_url(@other_user) }
            should "not change the status" do
              assert_equal LESSON_STATUS_REJECTED, @lesson.status
            end
          end
        end


        context "on PUT to :update_privacy" do
          setup do
            assert !@user.show_real_name
            put :update_privacy, :id => @user, :user => { :show_real_name => true }
            @user = User.find(@user)
          end

          should_assign_to :user
          should_respond_with :redirect
          should_set_the_flash_to /updated/
          should_redirect_to("edit account page") { edit_user_path(assigns(:user)) }
          should "set show real name" do
            assert @user.show_real_name
          end
        end
      end

      context "with a payment level defined" do
        setup do
          @payment_level = Factory.create(:payment_level, :default_payment_level => true)
        end

        context "on PUT to :update_instructor" do
          setup { put :update_instructor, :id => @user,
                      :user => { :payment_level => nil, :address1 => "aaa", :city => "yyy",
                                 :state => "XX", :postal_code => "99999",
                                 :country => "US" }  }

          should_assign_to :user
          should_respond_with :redirect
          should_set_the_flash_to /successfully updated/
          should_redirect_to("edit user") {edit_user_path(assigns(:user)) }
        end
      end

      context "on PUT to :update a profile screen with bad values" do
        setup { put :update, :id => @other_user, :user => Factory.attributes_for(:user, :last_name => "") }

        should_respond_with :redirect
        should_set_the_flash_to :update_error
        should_redirect_to("edit user page") { edit_user_path(@other_user) }
      end

      context "on POST to :reset_password on the users update page" do
        setup { post :reset_password, :id => @other_user.id, :user => @other_user }
        should_respond_with :redirect
        should_set_the_flash_to :password_reset_sent
      end
    end

    context "without admin access" do
      context "on GET to :index" do
        setup { get :index }

        should_not_assign_to :users
        should_respond_with :redirect
        should_set_the_flash_to /denied/
        should_redirect_to("Lesson index") { lessons_url }
      end
    end
  end
end

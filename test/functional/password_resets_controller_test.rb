require 'test_helper'

class PasswordResetsControllerTest < ActionController::TestCase


  context "when not logged in" do
    setup do
      Factory(:user)
    end

    context "on GET to :new" do
      setup { get :new }

      should_respond_with :success
      should_not_set_the_flash
      should_render_template "new"
    end

    #context "on GET to :edit" do
    #  setup { get :edit }
    #
    #  should_respond_with :success
    #  should_not_set_the_flash
    #  should_render_template "edit"
    #end

    context "on POST to :create" do
      setup { post :create, :email => Factory(:user).email }

      should_assign_to :user
      should_respond_with :redirect
      should_set_the_flash_to /Instructions to reset your password/
      should_redirect_to("login page") { root_url }
    end

    context "and needing to reset the password" do
      setup do
        url = edit_password_reset_url( Factory(:user).perishable_token)
        @id = url.split('/')[url.split('/').size - 2]
      end

      context "on PUT to :update" do
        setup do
          put :update, :id => @id,
              :user => { :password => 'xxxxx',
                         :password_confirmation => "xxxxx"}
        end

        should_assign_to :user
        should_set_the_flash_to "Password successfully updated"
        should_redirect_to("my account page") { accounts_url }
      end

      context "on PUT to :update with bad password confirmation" do
        setup do
          put :update, :id => @id,
              :user => { :password => 'xxxxx',
                         :password_confirmation => "yyyyy"}
        end

        should_assign_to :user
        should_not_set_the_flash
        should_render_template "edit"
      end

      context "on PUT to :update with bad secret url" do
        setup do
          put :update, :id => "blah",
              :user => { :password => 'xxxxx',
                         :password_confirmation => "yyyyy"}
        end

        should_not_assign_to :user
        should_set_the_flash_to /could not locate your account/
        should_redirect_to("login page") { root_url }
      end
    end
  end
end
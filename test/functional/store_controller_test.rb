require File.dirname(__FILE__) + '/../test_helper'
require 'fast_context'

class StoreControllerTest < ActionController::TestCase

  fast_context "when logged on" do
    setup do
      activate_authlogic
      @user = Factory(:user)
      UserSession.create @user
    end

    fast_context "on GET to :show" do
      # Pass a bogus id to show since RESTFUL routes requires an id for show
      setup { get :show, :id => 1 }

      should_respond_with :success
      should_not_set_the_flash
      should_render_template "show"
    end
  end
end

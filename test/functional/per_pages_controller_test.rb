require File.dirname(__FILE__) + '/../test_helper'

class PerPagesControllerTest < ActionController::TestCase
  context "when logged in" do
    setup do
      activate_authlogic
      @user = Factory(:user)
      UserSession.create @user
    end

    context "on POST to create" do
      setup { post :set, :per_page => 25, :refresh_url => "http://redirect" }   

      should_respond_with :redirect
      should_set_the_flash_to "Rows to display per page set to 25"
      should_redirect_to("redirection page")  { "http://redirect" }
    end
  end
end
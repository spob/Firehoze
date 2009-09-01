require File.dirname(__FILE__) + '/../test_helper'

class PagesControllerTest < ActionController::TestCase
  tests HighVoltage::PagesController

  context "testing static pages" do
    %w( about ).each do |page|
      context "on GET to /pages/#{page}" do
        setup { get :show, :id => page }

        should_respond_with :success
        should_render_template page
      end
    end
  end
end

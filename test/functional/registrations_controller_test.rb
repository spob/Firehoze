require File.dirname(__FILE__) + '/../test_helper'
require 'fast_context'

class RegistrationsControllerTest < ActionController::TestCase

  fast_context "while not logged on" do
    fast_context "on GET to :new" do
      setup { get :new }

      should_assign_to :registration
      should_respond_with :success
      should_not_set_the_flash
      should_render_template "new"
    end

    fast_context "on POST to :create" do
      setup do
        post :create, :registration => Factory.attributes_for(:registration)
      end

      should_respond_with :redirect
      should_set_the_flash_to /Please check your email/
      should_redirect_to("root  page") { root_path }
    end

    fast_context "on POST to :create with bad value" do
      setup do
        post :create, :registration => Factory.attributes_for(:registration, :email => "")
      end

      should_respond_with :success
      should_not_set_the_flash
      should_render_template :new
    end
  end

  fast_context "Computing hashes" do
    setup do
      @hash1 =  Registration.formatted_hash("test@example.com")
      @hash2 =  Registration.formatted_hash("test@example.com", "xxx", "yyy")
    end

    should "equate hashes" do
      assert Registration.match?("test@example.com", @hash1)
      assert !Registration.match?("test@example.com", @hash2)
      assert Registration.match?("test@example.com", @hash2, "xxx", "yyy")
      assert !Registration.match?("test@example.com", @hash1, "xxx", "yyy")
      assert !Registration.match?("test@example.com", @hash2, "xxx", "yy")
    end
  end
end
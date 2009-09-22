require File.dirname(__FILE__) + '/../test_helper'
require 'fast_context'

class RoleTest < ActiveSupport::TestCase
  fast_context "given an admin" do
    setup do
      @user1 = Factory.create(:user)
      @user2 = Factory.create(:user)
      @user2.has_role 'admin'
    end

    fast_context "when querying admins" do
      should "return user2" do
        users = Role.admins
        assert_equal 1, users.size
        assert_equal @user2, users.first
      end
    end
  end
end

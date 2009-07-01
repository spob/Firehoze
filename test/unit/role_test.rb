require 'test_helper'

class RoleTest < ActiveSupport::TestCase
  context "given a sysadmin" do
    setup do
      @user1 = Factory.create(:user)
      @user2 = Factory.create(:user)
      @user2.has_role 'sysadmin'
    end

    context "when querying sysadmins" do
      should "return user2" do
        users = Role.sysadmins
        assert_equal 1, users.size
        assert_equal @user2, users.first
      end
    end
  end
end

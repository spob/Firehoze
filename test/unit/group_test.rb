require File.dirname(__FILE__) + '/../test_helper'
require 'fast_context'

class GroupTest < ActiveSupport::TestCase
  fast_context "given an existing record" do
    setup { @group = Factory.create(:group) }
    subject { @group }

    should_validate_presence_of :name, :owner
    should_validate_uniqueness_of :name
    should_belong_to            :owner
    should_have_many            :group_members
    should_have_many            :users, :through => :group_members

    should "test owned_by?" do
      assert @group.owned_by?(@group.owner)
      assert !@group.owned_by?( Factory.create(:user))
    end
  end
end

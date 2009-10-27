require File.dirname(__FILE__) + '/../test_helper'
require 'fast_context'

class GroupTest < ActiveSupport::TestCase
  fast_context "given an existing record" do
    setup do
      @group1 = Factory.create(:group)
      assert !@group1.category.nil?
    end
    subject { @group1 }

    should_validate_presence_of :name, :owner, :category
    should_validate_uniqueness_of :name
    should_belong_to :owner, :category
    should_have_many :group_members
    should_have_many :users, :through => :group_members

    should "test owned_by?" do
      assert @group1.owned_by?(@group1.owner)
      assert !@group1.owned_by?( Factory.create(:user))
    end

    fast_context "and a couple more groups" do
      setup do
        @group2 = Factory.create(:group)
        @group3 = Factory.create(:group)
      end

      fast_context "and testing by_category named_scope" do
        setup { Category.explode }

        should "filter by category" do
          assert_equal Group.all.size, Group.by_category(nil).size

          assert_equal 1, Group.by_category(@group1.category).size
          assert_equal @group2, Group.by_category(@group2.category).first

          assert_equal 1, Group.by_category(@group1.category.parent_category).size
          assert_equal @group2, Group.by_category(@group2.category.parent_category).first
        end
      end
    end
  end
end

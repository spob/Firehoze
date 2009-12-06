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
    should_ensure_length_in_range :name, (0..50)
    should_belong_to :owner, :category
    should_have_many :group_members
    should_have_many :group_lessons
    should_have_many :lessons
    should_have_many :topics
    should_have_many :active_lessons
    should_have_many :all_activities
    should_have_many :users, :through => :group_members
    should_have_many :activities

    should "test owned_by?" do
      assert @group1.owned_by?(@group1.owner)
      assert !@group1.owned_by?( Factory.create(:user))
    end

    fast_context "on invite of group" do
      setup do
        @user = Factory.create(:user)
        @group_member = @group1.invite(@user)
      end
      
      should "test invite" do
        assert @group_member
        assert_equal PENDING, @group_member.member_type
      end
    end
    

    should "test fetch method(s)" do
      assert 1, Group.fetch_user_groups(@group1.owner, 1, 10)
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

    fast_context "compile_activity" do
      setup do
        assert @group1.activities.empty?
        Activity.compile
        @group1 = Group.find(@group1.id)
      end

      should "generate activity records" do
        assert_equal @group1, @group1.activities.first.trackable
      end
    end
  end

  fast_context "given an logo url" do
    should "convert to a cdn url" do
      assert_equal "http://cdn.firehoze.com/staging/groups/logos/2/medium/DSC_0043_Small.png?1249443866",
                   Group.convert_logo_url_to_cdn("http://s3.amazonaws.com/images.firehoze.com/staging/groups/logos/2/medium/DSC_0043_Small.png?1249443866")
    end
  end
end
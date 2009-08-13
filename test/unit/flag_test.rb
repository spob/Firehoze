require 'test_helper'

class FlagTest < ActiveSupport::TestCase
  context "given an existing record" do
    setup do
      @lesson = Factory.create(:lesson)
      @lesson.flags.create!(:status => FLAG_STATUS_PENDING, :reason_type => "Smut", :comments => "Some comments",
                            :user => Factory.create(:user))
      assert !Flag.all.empty?
      assert !Flag.pending.empty? 
    end

    should_belong_to :user
    should_validate_presence_of :user, :status , :reason_type, :comments

    should "set the friendly name" do
      assert_equal @lesson.title, @lesson.flags.first.friendly_flagger_name
    end

    should "return one pending flag" do
      assert_equal 1, Flag.pending.size 
    end
  end
end

require File.dirname(__FILE__) + '/../test_helper'
require 'fast_context'

class GroupLessonTest < ActiveSupport::TestCase
  fast_context "given an group lesson" do
    setup { @group_lesson = Factory.create(:group_lesson) }
    subject { @group_lesson }

    should_belong_to                 :user
    should_belong_to                 :lesson
    should_belong_to                 :group
    should_validate_presence_of      :user, :lesson, :group
  end
end

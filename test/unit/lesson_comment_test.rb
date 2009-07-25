require 'test_helper'

class LessonCommentTest < ActiveSupport::TestCase
  context "given an existing record for a lesson comment" do
    setup { @lesson_comment = Factory.create(:lesson_comment) }

    should_belong_to :lesson
    should_validate_presence_of      :lesson
  end
end

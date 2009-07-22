require 'test_helper'

class LessonBuyPatternTest < ActiveSupport::TestCase
  context "given an existing record" do
    setup { @lesson_buy_pattern = Factory.create(:lesson_buy_pattern) }

    should_belong_to :lesson, :purchased_lesson
    should_validate_presence_of :lesson, :purchased_lesson, :counter
  end
end

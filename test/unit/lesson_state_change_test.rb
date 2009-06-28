require 'test_helper'

class LessonStateChangeTest < ActiveSupport::TestCase

  context "given an existing lesson_state_change record" do
    setup { @lesson_state_change = Factory.create(:lesson_state_change) }

    should_belong_to :lesson
  end
end

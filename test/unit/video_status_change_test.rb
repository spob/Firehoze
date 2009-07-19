require 'test_helper'

class VideoStatusChangeTest < ActiveSupport::TestCase

  context "given an existing lesson_state_change record" do
    setup { @video_status_change = Factory.create(:video_status_change) }
                                                                 
    should_validate_presence_of :lesson
    should_belong_to :lesson
    should_belong_to :video
  end
end

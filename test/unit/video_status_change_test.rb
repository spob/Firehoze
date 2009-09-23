require File.dirname(__FILE__) + '/../test_helper'
require 'fast_context'

class VideoStatusChangeTest < ActiveSupport::TestCase

  fast_context "given an existing lesson_state_change record" do
    setup { @video_status_change = Factory.create(:video_status_change) }
    subject { @video_status_change }
                                                                 
    should_validate_presence_of :lesson
    should_belong_to :lesson
    should_belong_to :video
  end
end

require 'test_helper'

class ProcessedVideoTest < ActiveSupport::TestCase
  context "Given an existing processed video" do
    setup { @processed_video = Factory.create(:processed_video) }

    should_validate_presence_of      :lesson
    should_have_class_methods        :detect_zombie_video

    should "reference an original video" do
      assert !@processed_video.converted_from_video
    end

    should "check for zombies succesfully" do
      assert_nothing_thrown do
        ProcessedVideo.detect_zombie_video(@processed_video.id, @processed_video.id * 2)
      end
    end

    context "and a response job" do
      setup do
        @job = FlixCloud::Notification.new(@processed_video.build_flix_response)
        assert !@job.nil?
        assert @processed_video.finish_conversion(@job)
      end

      should "be succesfully converted" do
        assert_equal "Ready", @processed_video.status
      end
    end

    context "when searching for zombies" do
      setup { ProcessedVideo.detect_zombie_video(@processed_video.id, @processed_video.lesson.id) }

      # should verify an email was sent but not sure how
    end
  end
end

require File.dirname(__FILE__) + '/../test_helper'
require 'fast_context'

class OriginalVideoTest < ActiveSupport::TestCase
  fast_context "Given an existing original video" do
    setup { @original_video = Factory.create(:original_video) }

    should_validate_presence_of      :lesson
    should_have_attached_file        :video
    should_have_class_methods        :convert_video

    fast_context "when setting the url" do
      setup { @original_video.set_url }
      
      should "set the url" do
        assert_not_nil @original_video.s3_key
        assert_equal @original_video.video.path, @original_video.s3_key
        assert_not_nil @original_video.url
        assert_not_nil @original_video.s3_path
      end
    end
  end
  subject { @original_video }
end

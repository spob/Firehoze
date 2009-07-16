require 'test_helper'

class OriginalVideoTest < ActiveSupport::TestCase
  context "Given an existing original video" do
    setup { @original_video = Factory.create(:original_video) }

    should_validate_presence_of      :lesson
    should_have_attached_file        :video
  end
end

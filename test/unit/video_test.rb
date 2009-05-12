require 'test_helper'

class VideoTest < ActiveSupport::TestCase

  context "given an existing record" do
    setup do
      @video = Factory.create(:video)
    end

    should_validate_presence_of      :title, :author
    should_allow_values_for          :title, "blah blah blah"
    should_ensure_length_in_range    :title, (0..150)

    context "and a couple more records" do
      setup do
        # and let's create a couple more
        Factory.create(:video)
        Factory.create(:video)
      end

      should "return video records" do
        assert_equal 3, Video.list(1).size
      end
    end
  end
end

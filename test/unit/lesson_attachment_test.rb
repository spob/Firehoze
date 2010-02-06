require File.dirname(__FILE__) + '/../test_helper'
require 'fast_context'

class LessonAttachmentTest < ActiveSupport::TestCase
  fast_context "Given an existing attachment" do
    setup { @attachment = Factory.create(:lesson_attachment) }

    should_validate_presence_of :lesson, :title
    should_ensure_length_in_range :title, (0..50)
    should_have_attached_file :attachment
  end
  subject { @attachment }
end

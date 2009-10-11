require File.dirname(__FILE__) + '/../test_helper'
require 'fast_context'

class AttachmentTest < ActiveSupport::TestCase
  fast_context "Given an existing attachment" do
    setup { @attachment = Factory.create(:attachment) }

    should_validate_presence_of :lesson, :title
    should_have_attached_file :attachment
  end
  subject { @attachment }
end

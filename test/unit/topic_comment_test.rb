require File.dirname(__FILE__) + '/../test_helper'
require 'fast_context'

class TopicCommentTest < ActiveSupport::TestCase
  fast_context "given an existing record for a topic comment" do
    setup { @topic_comment = Factory.create(:topic_comment) }
    subject { @topic_comment }

    should_belong_to :topic
    should_validate_presence_of :topic
    should_have_many :flags
  end
end

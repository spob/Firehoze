require File.dirname(__FILE__) + '/../test_helper'
require 'fast_context'

class TopicCommentTest < ActiveSupport::TestCase
  fast_context "given an existing record for a topic comment" do
    setup do
      @topic = Factory.create(:topic)
      assert 15.minutes.ago > @topic.last_commented_at
      @topic_comment = Factory.create(:topic_comment, :topic => @topic)
    end
    subject { @topic_comment }

    should_belong_to :topic
    should_validate_presence_of :topic
    should_have_many :flags

    fast_context "testing last_commented_at on the topic" do
      should "set last_commented_at" do
        assert !@topic_comment.nil?
        assert !@topic_comment.topic.nil?
        assert_equal @topic_comment.created_at, @topic_comment.topic.last_commented_at
      end
    end
  end
end

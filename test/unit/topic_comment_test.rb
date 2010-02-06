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

    fast_context "testing last comment and last public comment" do
      setup do
        @topic_comment2 = Factory.create(:topic_comment, :topic => @topic)
        @topic_comment3 = Factory.create(:topic_comment, :topic => @topic, :public => false)
      end

      should "identify the last comment" do
        assert_equal @topic_comment3, @topic.last_topic_comment
        assert_equal @topic_comment2, @topic.last_public_topic_comment
      end
    end

    fast_context "and a bunch other comments of various statuses" do
      setup do
        @topic_comment2 = Factory.create(:topic_comment, :topic => @topic, :public => false)
        @topic_comment3 = Factory.create(:topic_comment, :topic => @topic)
        @topic_comment4 = Factory.create(:topic_comment, :topic => @topic)
        @topic_comment3.update_attribute(:status, COMMENT_STATUS_REJECTED)
        assert COMMENT_STATUS_REJECTED, @topic_comment3.status
      end

      should "not see private or rejected by anonymous" do
        @comments = @topic.comments_user_sensitive(nil)
        assert @comments.include?(@topic_comment)
        assert !@comments.include?(@topic_comment2)
        assert !@comments.include?(@topic_comment3)
        assert @comments.include?(@topic_comment4)
      end

      should "see private or rejected by anonymous" do
        @comments = @topic.comments_user_sensitive(@topic.group.owner)
        assert @comments.include?(@topic_comment)
        assert !@comments.include?(@topic_comment2)
        assert @comments.include?(@topic_comment3)
        assert @comments.include?(@topic_comment4)
      end

      fast_context "as an admin" do
        setup do
          @admin = Factory.create(:user)
          @admin.has_role('admin')
        end

        should "see private or rejected by anonymous" do
          @comments = @topic.comments_user_sensitive(@admin)
          assert @comments.include?(@topic_comment)
          assert @comments.include?(@topic_comment2)
          assert @comments.include?(@topic_comment3)
          assert @comments.include?(@topic_comment4)
        end
      end
    end
  end
end

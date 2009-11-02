require File.dirname(__FILE__) + '/../test_helper'
require 'fast_context'

class TopicTest < ActiveSupport::TestCase

  fast_context "given an existing record" do
    setup do
      @topic = Factory.create(:topic)
    end
    subject { @topic }

    should_validate_presence_of :user, :group, :title
#    should_validate_presence_of :comments, :on => :create
    should_belong_to :user, :group
    should_ensure_length_in_range :title, (0..200)
    should_validate_uniqueness_of :title, :scoped_to => :group_id
  end
end

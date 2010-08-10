require File.dirname(__FILE__) + '/../test_helper'
require 'fast_context'

class QuizTest < ActiveSupport::TestCase

  context "given a quiz" do
    setup { @quiz = Factory.create(:quiz) }

    subject { @quiz }

    should_belong_to :group
    should_validate_presence_of :name, :group
    should_validate_uniqueness_of :name, :scoped_to => :group_id
    should_ensure_length_in_range :name, (0..100)
  end
end

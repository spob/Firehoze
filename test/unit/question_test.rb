require File.dirname(__FILE__) + '/../test_helper'
require 'fast_context'


class QuestionTest < ActiveSupport::TestCase

  context "given a question" do
    setup { @question = Factory.create(:question) }

    subject { @question }

    should_belong_to :quiz
    should_validate_presence_of :question, :quiz
    should_validate_uniqueness_of :question, :scoped_to => :quiz_id
    should_ensure_length_in_range :question, (0..500)
  end
end

require 'test_helper'

class ReviewTest < ActiveSupport::TestCase

  context "given an existing record" do
    setup do
      @review = Factory.create(:review)
    end
    
    should_belong_to :user
    should_belong_to :lesson
    should_validate_presence_of :user, :title, :body, :lesson
    should_validate_uniqueness_of :user_id, :scoped_to => :lesson_id
    should_ensure_length_in_range    :title, (0..100)
  end
end

require 'test_helper'

class HelpfulTest < ActiveSupport::TestCase
  context "given an existing record" do
    setup do
      @lesson = Factory.create(:helpful)
    end

    should_validate_presence_of      :review, :user, :helpful
    should_belong_to                 :review
    should_belong_to                 :user
  end
end

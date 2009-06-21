require 'test_helper'

class HelpfulTest < ActiveSupport::TestCase
  context "given an existing record" do
    setup do
      @helpful = Factory.create(:helpful)
    end

    should_validate_presence_of      :review, :user
    should_belong_to                 :review
    should_belong_to                 :user

    context "and another that is helpful and one that is not" do
      setup do
        @helpful1 = Factory.create(:helpful)
        @helpful2 = Factory.create(:helpful, :helpful => false)
      end

      should "have 2 yes and 1 no" do
        assert_equal 2, Helpful.helpful_yes.size
        assert_equal 1, Helpful.helpful_no.size
      end
    end
  end
end

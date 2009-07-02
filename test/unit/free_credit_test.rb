require 'test_helper'

class FreeCreditTest < ActiveSupport::TestCase
  context "given an existing record" do
    setup { @credit = Factory.create(:free_credit) }

    should_belong_to :user
    should_belong_to :lesson
    should_validate_presence_of :lesson

    should "retrieve rows" do
      assert !FreeCredit.available.empty?
    end

    context "that has been redeemed" do
      setup { @credit.update_attribute(:redeemed_at, Time.now) }

      should "retrieve no rows" do
        assert FreeCredit.available.empty?
      end
    end
  end
end

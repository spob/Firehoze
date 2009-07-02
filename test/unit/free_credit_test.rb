require 'test_helper'

class FreeCreditTest < ActiveSupport::TestCase
  context "given an existing record" do
    setup { @credit = Factory.create(:credit) }

    should_belong_to :user
    should_belong_to :lesson
    should_validate_presence_of :lesson
  end
end

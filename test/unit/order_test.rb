require 'test_helper'

class OrderTest < ActiveSupport::TestCase
  context "given an existing record" do
    setup { @order = Factory.create(:order) }

    should_belong_to :user
    should_belong_to :cart
    should_validate_presence_of      :user
  end
end

require 'test_helper'

class FlagTest < ActiveSupport::TestCase
  context "given an existing record" do
    setup do
      @flag = Factory.create(:flag)
    end
  end
end

require File.dirname(__FILE__) + '/../test_helper'
require 'fast_context'

class GroupTest < ActiveSupport::TestCase
  fast_context "given an existing record" do
    setup { @group = Factory.create(:group) }
    subject { @group }

    should_validate_presence_of :name, :owner
    should_validate_uniqueness_of :name
    should_belong_to            :owner
  end
end

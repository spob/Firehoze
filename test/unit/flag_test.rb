require 'test_helper'

class FlagTest < ActiveSupport::TestCase
  context "given an existing record" do
    setup do
      @lesson = Factory.create(:lesson)
      @lesson.flags.create(:status => "PENDING", :reason_type => "Smut", :comments => "Some comments")
      #@flag = Factory.create(:flag)
    end

    should_belong_to :user
    should_validate_presence_of :user, :status , :reason_type
  end
end

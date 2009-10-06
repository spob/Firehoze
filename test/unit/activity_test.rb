require File.dirname(__FILE__) + '/../test_helper'
require 'fast_context'

class ActivityTest < ActiveSupport::TestCase
  context "Given an existing activity" do
    setup do
      @lesson = Factory.create(:lesson)
      @lesson.activities.create!(:actor_user => Factory.create(:user),
                                 :actee_user => Factory.create(:user),
                                 :acted_upon_at => 1.days.ago)
    end

    should_belong_to :actor_user, :actee_user
    should_validate_presence_of :actor_user, :acted_upon_at
  end
end

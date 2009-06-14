require 'test_helper'

class LessonTest < ActiveSupport::TestCase

  context "given an existing record" do
    setup do
      @lesson = Factory.create(:lesson)
    end

    should_validate_presence_of      :title, :instructor, :video_file_name
    should_allow_values_for          :title, "blah blah blah"
    should_ensure_length_in_range    :title, (0..50)
    should_have_attached_file        :video

    context "and a couple more records" do
      setup do
        # and let's create a couple more
        Factory.create(:lesson)
        Factory.create(:lesson)
      end

      should "return less records" do
        assert_equal 3, Lesson.list(1).size
      end
    end

    context "and lessons by two different authors" do
      setup do
        @user1 = Factory.create(:user)
        @user2 = Factory.create(:user)
        @user3 = Factory.create(:user)
        @user3.is_admin
        @lesson1 =  Factory.create(:lesson, :instructor => @user1)
        @lesson2 =  Factory.create(:lesson, :instructor => @user2)
      end

      should "allow author to edit" do
        # author can edit their lessons
        assert @lesson1.can_edit?(@user1)
        assert !@lesson1.can_edit?(@user2)
        assert @lesson2.can_edit?(@user2)
        assert !@lesson2.can_edit?(@user1)
        
        # Admin should be able to edit both
        assert @lesson2.can_edit?(@user3)
        assert @lesson2.can_edit?(@user3)
      end
    end
  end
end
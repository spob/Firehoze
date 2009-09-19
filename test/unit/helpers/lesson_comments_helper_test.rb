require File.dirname(__FILE__) + '/../../test_helper'

class LessonCommentsHelperTest < ActionView::TestCase
  context "with a lesson defined" do
    setup do
      @lesson = Factory.create(:lesson)
      Factory.create(:lesson_comment, :lesson => @lesson)
    end

    should "return empty link" do
      assert_equal "", show_all_lesson_comments_link(@lesson, nil)
    end

    context "with lots of comments" do
      setup do
        for i in 1..15
          Factory.create(:lesson_comment, :lesson => @lesson)
        end
      end

      should "return empty link" do
        assert_equal "<a href=\"/lessons/#{@lesson.id}-#{@lesson.title.gsub(/ /, "-").downcase}/lesson_comments?per_page=10\">See all #{@lesson.comments.size} Comments</a>", 
                     show_all_lesson_comments_link(@lesson, nil)
      end
    end
  end
end

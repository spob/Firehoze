require 'test_helper'

class LessonBuyPairTest < ActiveSupport::TestCase
  context "given an existing record" do
    setup { @lesson_buy_pair = Factory.create(:lesson_buy_pair) }

    should_belong_to :lesson, :other_lesson
    should_validate_presence_of :lesson, :other_lesson, :counter
  end

  context "given multiple credits" do
    setup do
      @user1 = Factory.create(:user)
      @user2 = Factory.create(:user)
      @credit1 = Factory.create(:credit, :user => @user1)   # lesson 1
      @credit2 = Factory.create(:credit, :user => @user1)   # lesson 2
      @credit3 = Factory.create(:credit, :user => @user1)   # lesson 3
      @credit4 = Factory.create(:credit, :rolled_up_at => Time.now, :user => @user1) # lesson 4
      @credit5 = Factory.create(:credit, :lesson => @credit1.lesson, :user => @user2) # lesson 1
      @credit6 = Factory.create(:credit, :lesson => @credit2.lesson, :user => @user2) # lesson 2
      @credit7 = Factory.create(:credit, :user => @user2) #lesson 5
      assert 4, Credit.used.unrolled_up.size
      LessonBuyPair.rollup_buy_patterns
    end

    #Lesson	   Other Lesson   	Count
    #   1	        2	          2
    #   1	        3	          1
    #   1	        4	          1
    #   1           5             1
    #   2	        1	          2
    #   2	        3	          1
    #   2	        4	          1
    #   2	        5	          1
    #   3           1             1
    #   3	        2	          1
    #   3	        4	          1
    #   5           1             1
    #   5           2             1
    should "populate buy pairs" do
      assert_equal 13, LessonBuyPair.count
      verify_count @credit1, @credit2, 2
      verify_count @credit1, @credit3, 1
      verify_count @credit1, @credit4, 1
      verify_count @credit1, @credit7, 1
      verify_count @credit2, @credit1, 2
      verify_count @credit2, @credit3, 1
      verify_count @credit2, @credit4, 1
      verify_count @credit2, @credit7, 1
      verify_count @credit3, @credit1, 1
      verify_count @credit3, @credit2, 1
      verify_count @credit3, @credit4, 1
      verify_count @credit7, @credit1, 1
      verify_count @credit7, @credit2, 1
    end
  end

  private

  def verify_count credit, other_credit, count
    pair = LessonBuyPair.by_lesson(credit.lesson.id).by_other_lesson(other_credit.lesson.id).first
    assert_not_nil pair
    assert_equal count, pair.counter
  end
end


require File.dirname(__FILE__) + '/../test_helper'
require 'fast_context'

class QuizTest < ActiveSupport::TestCase

  context "given a quiz" do
    setup { @quiz = Factory.create(:quiz) }

    subject { @quiz }

    should_belong_to :group
    should_have_many :questions
    should_validate_presence_of :name, :group
    should_validate_uniqueness_of :name, :scoped_to => :group_id
    should_ensure_length_in_range :name, (0..100)

    fast_context "and a quiz" do
      setup do
        @user1 = Factory.create(:user)
        @user2 = Factory.create(:user)
        @user3 = Factory.create(:user)
        @group_member1 = GroupMember.create!(:user => @user1, :group => @quiz.group, :member_type => MEMBER)
        @group_member2 = GroupMember.create!(:user => @user2, :group => @quiz.group, :member_type => MODERATOR)
      end

      should "calculate who has access to the quiz" do
        assert @quiz.group.quizzes.visible_by_user(@quiz.group.owner, @quiz.group).include?(@quiz)
        assert @quiz.group.quizzes.visible_by_user(@user1, @quiz.group).include?(@quiz)
        assert @quiz.group.quizzes.visible_by_user(@user2, @quiz.group).include?(@quiz)
        assert @quiz.group.quizzes.visible_by_user(@user3, @quiz.group).include?(@quiz)
      end

      fast_context "that has expired" do
        setup { @quiz.update_attribute(:disabled_at, 1.days.ago) }

        should "calculate who has access to the quiz" do
          assert @quiz.group.quizzes.visible_by_user(@quiz.group.owner, @quiz.group).include?(@quiz)
          assert !@quiz.group.quizzes.visible_by_user(@user1, @quiz.group).include?(@quiz)
          assert @quiz.group.quizzes.visible_by_user(@user2, @quiz.group).include?(@quiz)
          assert !@quiz.group.quizzes.visible_by_user(@user3, @quiz.group).include?(@quiz)
        end
      end

      fast_context "that has not been published" do
        setup { @quiz.update_attribute(:published, false) }

        should "calculate who has access to the quiz" do
          assert @quiz.group.quizzes.visible_by_user(@quiz.group.owner, @quiz.group).include?(@quiz)
          assert !@quiz.group.quizzes.visible_by_user(@user1, @quiz.group).include?(@quiz)
          assert @quiz.group.quizzes.visible_by_user(@user2, @quiz.group).include?(@quiz)
          assert !@quiz.group.quizzes.visible_by_user(@user3, @quiz.group).include?(@quiz)
        end
      end
    end
  end
end

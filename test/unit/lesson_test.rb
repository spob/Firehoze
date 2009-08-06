require 'test_helper'

class LessonTest < ActiveSupport::TestCase

  context "given an existing lesson with initial_free_download_count" do
    setup do
      @sku = Factory.create(:credit_sku, :sku => FREE_CREDIT_SKU)
      @lesson = Factory.create(:lesson, :initial_free_download_count => 5)
      @lesson = Lesson.find(@lesson)
    end

    should 'consume a free credit' do
      assert_equal 5, @lesson.free_credits.available.size
      assert !@lesson.consume_free_credit(Factory.create(:user)).nil?
      assert_equal 4, @lesson.free_credits.available.size
    end
  end

  context "given an existing lesson" do
    setup do
      @sku = Factory.create(:credit_sku, :sku => FREE_CREDIT_SKU)
      @lesson = Factory.create(:lesson)
      @original_video = Factory.create(:original_video, :lesson => @lesson)
      @lesson = Lesson.find(@lesson)
      assert @lesson.original_video
    end

    context "with processed videos" do
      setup do
        @full_processed_video = Factory.create(:full_processed_video, :lesson => @lesson)
        @preview_processed_video = Factory.create(:ready_preview_processed_video, :lesson => @lesson)
      end

      should "have processed videos" do
        assert @lesson.full_processed_video
        assert @lesson.preview_processed_video
      end

      context "with both pending" do
        setup do
          @full_processed_video.update_attribute(:status, VIDEO_STATUS_PENDING)
          @preview_processed_video.update_attribute(:status, VIDEO_STATUS_PENDING)
          @lesson.update_status
        end

        should "be pending" do
          assert_equal VIDEO_STATUS_PENDING, @lesson.status
        end
      end

      context "with one converting" do
        setup do
          @full_processed_video.update_attribute(:status, VIDEO_STATUS_PENDING)
          @preview_processed_video.update_attribute(:status, VIDEO_STATUS_CONVERTING)
          @lesson.update_status
        end

        should "be pending" do
          assert_equal VIDEO_STATUS_CONVERTING, @lesson.status
        end
      end

      context "with one ready" do
        setup do
          @full_processed_video.update_attribute(:status, VIDEO_STATUS_READY)
          @preview_processed_video.update_attribute(:status, VIDEO_STATUS_CONVERTING)
          @lesson.update_status
        end

        should "be pending" do
          assert_equal VIDEO_STATUS_CONVERTING, @lesson.status
        end
      end

      context "with both ready" do
        setup do
          @full_processed_video.update_attribute(:status, VIDEO_STATUS_READY)
          @preview_processed_video.update_attribute(:status, VIDEO_STATUS_READY)
          @lesson.update_status
        end

        should "be pending" do
          assert_equal VIDEO_STATUS_READY, @lesson.status
        end
      end

      context "with one failed" do
        setup do
          @full_processed_video.update_attribute(:status, VIDEO_STATUS_READY)
          @preview_processed_video.update_attribute(:status, VIDEO_STATUS_FAILED)
          @lesson.update_status
        end

        should "be pending" do
          assert_equal VIDEO_STATUS_FAILED, @lesson.status
        end
      end
    end

    context "and several more lessons owned by a user" do
      setup do
        @lesson2 = Factory.create(:lesson)
        @lesson3 = Factory.create(:lesson)
        @lesson4 = Factory.create(:lesson)
        @user = Factory.create(:user)
        @credit2 = Factory.create(:credit, :lesson => @lesson2, :user => @user)
        @credit4 = Factory.create(:credit, :lesson => @lesson4, :user => @user)
        assert !@lesson.owned_by?(@user)
        assert @lesson2.owned_by?(@user)
        assert !@lesson3.owned_by?(@user)
        assert @lesson4.owned_by?(@user)
        @lessons = Lesson.not_owned_by(@user)
      end

      should "retrieve unowned videos" do
        assert_equal 2, @lessons.size
        assert @lessons.include?(@lesson)
        assert !@lessons.include?(@lesson2)
        assert @lessons.include?(@lesson3)
        assert !@lessons.include?(@lesson4)
      end
    end

    should_validate_presence_of      :title, :instructor, :synopsis
    should_allow_values_for          :title, "blah blah blah"
    should_ensure_length_in_range    :title, (0..50)
    should_ensure_length_in_range    :synopsis, (0..500)
    should_have_many                 :reviews, :video_status_changes, :credits, :free_credits, :taggings
    should_have_many                 :videos, :processed_videos, :lesson_buy_patterns, :comments
    should_have_and_belong_to_many   :lesson_wishers
    should_have_one                  :original_video
    should_have_one                  :full_processed_video
    should_have_one                  :preview_processed_video
    should_have_class_methods        :list, :ready
    should_have_instance_methods     :tag_list

    should "not be ready" do
      assert !@lesson.ready?
    end

    context "with buy patterns" do
      setup do
        @buy_pattern1 = Factory.create(:lesson_buy_pattern, :lesson => @lesson, :counter => 1)
        @buy_pattern2 = Factory.create(:lesson_buy_pattern, :lesson => @lesson, :counter => 2)
        @buy_pattern3 = Factory.create(:lesson_buy_pattern, :lesson => @lesson, :counter => 3)
      end

      should "return buy patterns" do
        assert_equal 3, @lesson.lesson_buy_patterns.size
        assert_equal 6, @lesson.total_buy_pattern_counts
      end
    end

    should "not have any tags assigned" do
      assert @lesson.tags.empty?
    end

    context "and then receives tags" do
      setup do
        @lesson.tag_list = "Foo, Bar, Baz"
        @lesson.save!
      end

      should "acts as taggable" do
        assert_equal 3, @lesson.tags.size
        assert_same_elements %w(Foo Bar Baz), @lesson.tag_list
      end

      should "find tagged with" do
        @lesson.tag_list = "Foo, Bar, Baz"
        @lesson.save!
        assert_equal @lesson, Lesson.find_tagged_with('Foo').first
      end

      context "which is processing" do
        setup do
          # notifier needs at least one admin
          @admin = Factory.create(:user)
          @admin.has_role 'admin'
          @lesson.update_attributes(:status => VIDEO_STATUS_CONVERTING,
                                    :flixcloud_job_id => @lesson.id * 2)
        end
      end

      context "which is ready" do
        setup { @lesson.update_attribute(:status, VIDEO_STATUS_READY) }

        should "be ready" do
          assert @lesson.ready?
        end
      end

      should "not have any credits" do
        assert_nil @lesson.initial_free_download_count
      end

      should "not consume free credits" do
        assert @lesson.free_credits.empty?
        assert !@lesson.consume_free_credit(Factory.create(:user))
      end

      context "and trigger a conversion" do
        setup { @job = @lesson.trigger_conversion }

        should "create a job" do
          assert_equal "ConvertVideo", @job.name
        end
      end

      context "and a couple more records" do
        setup do
          # and let's create a couple more
          @lesson2 = Factory.create(:lesson)
          @lesson3 = Factory.create(:lesson)
          @lesson.update_attribute(:status, VIDEO_STATUS_PENDING)
          @lesson2.update_attribute(:status, VIDEO_STATUS_READY)
          @lesson3.update_attribute(:status, VIDEO_STATUS_READY)
        end

        should "not show that it has been reviewed" do
          assert !@lesson.reviewed_by?(Factory.create(:user))
        end

        context "with a user defined" do
          setup { @user = Factory.create(:user) }

          should "return less records" do
            assert_equal 2, Lesson.list(1).size
            assert_equal 2, Lesson.list(1, @user).size
            assert_equal 3, Lesson.list(1, @lesson.instructor).size
          end

          context "who is an admin" do
            setup { @user.has_role 'admin' }

            should "return less records" do
              assert_equal 3, Lesson.list(1, @user).size
            end
          end
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
end
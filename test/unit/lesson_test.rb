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
    end

    should_validate_presence_of      :title, :instructor
    should_allow_values_for          :title, "blah blah blah"
    should_ensure_length_in_range    :title, (0..50)
    should_have_many                 :reviews, :lesson_state_changes, :credits, :free_credits, :taggings
    should_have_class_methods        :convert_video, :detect_zombie_video, :list, :ready
    should_have_instance_methods     :tag_list

    should "not be ready" do
      assert !@lesson.ready?
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
          @lesson.update_attributes(:state => LESSON_STATE_START_CONVERSION_SUCCESS,
            :flixcloud_job_id => @lesson.id * 2)
        end

        should "check for zombies succesfully" do
          assert_nothing_thrown do
            Lesson.detect_zombie_video(@lesson.id, @lesson.id * 2)
          end
        end
      end

      context "which is ready" do
        setup { @lesson.update_attribute(:state, 'ready') }

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

      should "have a state change record" do
        assert_equal 1, @lesson.lesson_state_changes.size
        assert_nil @lesson.lesson_state_changes.first.from_state
        assert_equal "pending", @lesson.lesson_state_changes.first.to_state
        assert_match /Lesson created/, @lesson.lesson_state_changes.first.message
      end

      context "and trigger a conversion" do
        setup { @job = @lesson.trigger_conversion }

        should "create a job" do
          assert_equal "ConvertVideo", @job.name
        end
      end

      context "and a response job" do
        setup do
          @lesson.update_attribute(:conversion_started_at, 1.minutes.ago)
          @job = FlixCloud::Notification.new(@lesson.build_flix_response)
          assert !@job.nil?
          assert @lesson.finish_conversion(@job)
        end

        should "be succesfully converted" do
          assert @lesson.ready?
        end
      end

      context "that changed state" do
        setup do
          @lesson.change_state('ready', 'test msg')
          @lesson = Lesson.find(@lesson)
        end

        should "have another state change record" do
          assert_equal 2, @lesson.lesson_state_changes.count
          assert_equal "pending", @lesson.lesson_state_changes.last.from_state
          assert_equal "ready", @lesson.lesson_state_changes.last.to_state
          assert_equal "Video conversion completed successfully and is ready for viewing: test msg",
                       @lesson.lesson_state_changes.last.message
        end
      end

      context "and a couple more records" do
        setup do
          # and let's create a couple more
          @lesson2 = Factory.create(:lesson)
          @lesson3 = Factory.create(:lesson)
          @lesson.update_attribute(:state, LESSON_STATE_PENDING)
          @lesson2.update_attribute(:state, LESSON_STATE_READY)
          @lesson3.update_attribute(:state, LESSON_STATE_READY)
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
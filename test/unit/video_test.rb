require 'test_helper'

class VideoTest < ActiveSupport::TestCase

  context "given an existing record" do
    setup do
      @video = Factory.create(:video)
    end

    should_validate_presence_of      :title, :author
    should_allow_values_for          :title, "blah blah blah"
    should_ensure_length_in_range    :title, (0..50)

    context "and a couple more records" do
      setup do
        # and let's create a couple more
        Factory.create(:video)
        Factory.create(:video)
      end

      should "return video records" do
        assert_equal 3, Video.list(1).size
      end
    end

    context "and videos by two different authors" do
      setup do
        @user1 = Factory.create(:user)
        @user2 = Factory.create(:user)
        @user3 = Factory.create(:user)
        @user3.is_admin
        @video1 =  Factory.create(:video, :author => @user1)
        @video2 =  Factory.create(:video, :author => @user2)
      end

      should "allow author to edit" do
        # author can edit their videos
        assert @video1.can_edit?(@user1)
        assert !@video1.can_edit?(@user2)
        assert @video2.can_edit?(@user2)
        assert !@video2.can_edit?(@user1)
        
        # Admin should be able to edit both
        assert @video2.can_edit?(@user3)
        assert @video2.can_edit?(@user3)
      end
    end
  end
end

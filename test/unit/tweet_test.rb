require File.dirname(__FILE__) + '/../test_helper'
require 'fast_context'

class TweetTest < ActiveSupport::TestCase

  fast_context "given an existing record" do
    setup do
      @tweet = Factory.create(:tweet)
    end
    subject { @tweet }

    should_validate_presence_of :search_code, :twitter_post_id, :posted_at, :from_user,
                                :tweet_text, :iso_language_code, :profile_image_url
    should_validate_uniqueness_of :twitter_post_id, :scoped_to => :search_code

    fast_context "and a couple more tweets" do
      setup do
        @tweet = Factory.create(:tweet)
        @tweet2 = Factory.create(:tweet)
        @tweet3 = Factory.create(:tweet)
        @tweet4 = Factory.create(:tweet)
      end

      should "return rows" do
        assert_equal 3, Tweet.list_tweets(@tweet.search_code, 3).size
      end
    end
  end
end
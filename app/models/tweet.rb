class Tweet < ActiveRecord::Base
  validates_presence_of :search_code, :twitter_post_id, :posted_at, :from_user,
                        :tweet_text, :iso_language_code, :profile_image_url
  validates_uniqueness_of :twitter_post_id, :scope => :search_code

  def self.fetch_firehoze_tweets(search_label, twitter_user)
    Twitter::Search.new.from(twitter_user).each do |t|
      unless Tweet.find_by_search_code_and_twitter_post_id(search_label, t.id)
        Tweet.create(:search_code => search_label, :twitter_post_id => t.id,
                     :posted_at => t.created_at, :from_user => t.from_user,
                     :tweet_text => t.text, :iso_language_code => t.iso_language_code,
                     :profile_image_url => t.profile_image_url)
      end
    end
  end

  def self.list_tweets(search_code, limit)
    Tweet.where("search_code = ?", search_code).order("posted_at DESC").paginate(:page => 1, :per_page => limit)
  end
end

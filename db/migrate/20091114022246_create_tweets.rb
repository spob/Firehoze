class CreateTweets < ActiveRecord::Migration
  def self.up
    create_table :tweets do |t|
      t.string      :search_code, :limit => 50, :null => false
      t.string      :twitter_post_id, :limit => 50, :null => false
      t.datetime    :posted_at, :null => false
      t.string      :from_user, :null => false
      t.string      :tweet_text, :limit => 250, :null => false
      t.string      :iso_language_code, :limit => 10, :null => false
      t.string      :profile_image_url, :null => false
      t.timestamps
    end
    add_index :tweets, [:search_code, :twitter_post_id], :unique => true
  end

  def self.down
    remove_index :tweets, [:search_code, :twitter_post_id]
    drop_table :tweets
  end
end

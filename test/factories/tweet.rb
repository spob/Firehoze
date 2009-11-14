Factory.sequence :tweet_post do |n|
  "#{n}"
end

Factory.define :tweet do |f|
  f.search_code  "FIREHOZE"
  f.twitter_post_id { Factory.next(:tweet_post) }
  f.posted_at { 1.days.ago }
  f.from_user "bulldog"
  f.tweet_text "This is the tweet"
  f.iso_language_code "en"
  f.profile_image_url "http://www.firehoze.com/tweet"
end
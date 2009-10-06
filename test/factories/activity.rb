Factory.define :activity do |activity|
  activity.acted_upon_at { 1.hours.ago }
  activity.actor_user_id "Smut"
  activity.actee_user_id "Some comments"
  activity.association :actor_user_id, :factory => :user
  activity.association :actee_user_id, :factory => :user
end
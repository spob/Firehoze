Factory.define :activity do |activity|
  activity.acted_upon_at { 1.hours.ago }
  activity.actor_user_id "Smut"
  activity.actee_user_id "Some comments"
  activity.activity_string "lesson.activity"
  activity.activity_object_id { Factory.create(:lesson).id } 
  activity.activity_object_human_identifier "some lesson"
  activity.activity_object_class "Lesson"
  activity.association :actor_user_id, :factory => :user
  activity.association :actee_user_id, :factory => :user
  activity.association :group
end
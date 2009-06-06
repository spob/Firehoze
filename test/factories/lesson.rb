Factory.define :lesson do |lesson|
  lesson.title "The lesson title"
  lesson.description "This is a longer description"
  lesson.association :author, :factory => :user
  lesson.video_file_name "path_to_video"
end
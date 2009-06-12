Factory.define :lesson do |lesson|
  lesson.title "The lesson title"
  lesson.description "This is a longer description"
  lesson.association :instructor, :factory => :user
  lesson.video_file_name "path_to_video"
end
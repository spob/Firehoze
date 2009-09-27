Factory.define :lesson do |lesson|
  lesson.title "The lesson title"
  lesson.synopsis "This is a short synopsis"
  lesson.notes "This is a longer description"
  lesson.association :instructor, :factory => :user
  lesson.association :category
  # lesson.video_file_name "path_to_video"
end
Factory.sequence :title do |n|
  "The lesson title#{n}"
  end

Factory.define :lesson do |lesson|
  lesson.title { Factory.next(:title) }
  lesson.synopsis "This is a short synopsis"
  lesson.notes "This is a longer description"
  lesson.association :instructor, :factory => :user
  lesson.association :category
  # lesson.video_file_name "path_to_video"
end
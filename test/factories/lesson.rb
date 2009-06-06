Factory.define :lesson do |f|
  f.title "The lesson title"
  f.description "This is a longer description"
  f.association :author, :factory => :user
  f.video_file_name "path_to_video"
end
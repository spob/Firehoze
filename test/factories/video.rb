Factory.define :video do |f|
  f.title "The video title"
  f.description "This is a longer description"
  f.association :author, :factory => :user
  f.video_file_name "path_to_video"
end
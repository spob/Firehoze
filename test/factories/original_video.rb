Factory.define :original_video do |video|
  video.association :lesson
  video.video_file_name "path_to_video"
end
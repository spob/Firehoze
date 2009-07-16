Factory.define :processed_video do |video|
  video.association :lesson
  video.video_file_name "path_to_video"
  video.flixcloud_job_id 123456
  video.conversion_started_at  { 2.hours.ago}
  video.s3_key "/videos/2/video.avi"
end

Factory.define :ready_processed_video, :parent => :processed_video do |video|
  video.s3_path "s3://amazon.com/somepath"
  video.url "http://some/path"
  video.video_file_size 21342
  video.status "Ready"
  video.video_width 640
  video.video_height 460
  video.video_duration 23423
  video.processed_video_cost 234
  video.input_video_cost  234
  video.thumbnail_url  "http://path_to_thumbnail"
  video.association :converted_from_video, :factory => :original_video
  video.conversion_ended_at  { 2.minutes.ago}
end
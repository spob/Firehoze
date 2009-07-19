Factory.define :video_status_change do |video_status_change|
  video_status_change.association :lesson
  video_status_change.from_status 'pending'
  video_status_change.to_status 'converting'
end
Factory.define :attachment do |attachment|
  attachment.association :lesson
  attachment.attachment_file_name "path_to_video.avi"
end
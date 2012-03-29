class FullProcessedVideo < ProcessedVideo
  def flix_recipe_id
    FLIX_FULL_RECIPE_ID
  end

  def thumbnail_size
    "large"
  end

  def output_ftp_path
    "s3://#{APP_CONFIG[CONFIG_AWS_S3_OUTPUT_VIDEO_BUCKET]}/#{APP_CONFIG[CONFIG_S3_DIRECTORY]}/videos/#{self.id}/full.flv"
  end

  def update_lesson_attributes(duration)
    self.lesson.reload
    self.lesson.update_attributes(:finished_video_duration => duration,
                                  :thumbnail_url           => thumbnail_path("<size>"))
  end

  def output_rtmp_path
    "flv:#{APP_CONFIG[CONFIG_S3_DIRECTORY]}/videos/#{self.id.to_s}/full"
  end
end

class FullProcessedVideo < ProcessedVideo
  def flix_recipe_id
    FLIX_FULL_RECIPE_ID
  end

  def thumbnail_size
    "large"
  end

  def output_ftp_path
    "s3://videos.firehoze.com/#{APP_CONFIG[CONFIG_S3_DIRECTORY]}/videos/#{self.id}/full.flv"
#    "ftp://#{OUTPUT_FTP_USERNAME}:#{OUTPUT_FTP_PASSWORD}@#{APP_CONFIG[CONFIG_FTP_CDN_PATH]}/#{self.s3_root_dir}/videos/#{self.id.to_s}.flv"
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

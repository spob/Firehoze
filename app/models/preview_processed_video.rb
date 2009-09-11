class PreviewProcessedVideo < ProcessedVideo
  def flix_recipe_id
    FLIX_PREVIEW_RECIPE_ID
  end

  def thumbnail_size
    "small"
  end

  def output_ftp_path
    "ftp://#{APP_CONFIG[CONFIG_FTP_CDN_PATH]}/#{self.s3_root_dir}/previews/#{self.id.to_s}.flv"
  end


  def update_lesson_attributes(job)
    self.lesson.update_attributes(:finished_video_duration => job.output_media_file.duration,
                                  :thumbnail_small_url => self.thumbnail_url)
  end

  def output_rtmp_path
    "#{APP_CONFIG[CONFIG_CDN_VIDEO_BUCKET]}/#{APP_CONFIG[CONFIG_S3_DIRECTORY]}/previews/#{self.id.to_s}.flv"
  end
end
require 'test_helper'

class PreviewProcessedVideoTest < ActiveSupport::TestCase
  context "Given an existing processed video" do
    setup { @processed_video = Factory.create(:ready_preview_processed_video)}

    should "populate a video" do
      assert @processed_video
      assert FLIX_PREVIEW_RECIPE_ID, @processed_video.flix_recipe_id
      assert "ftp://#{APP_CONFIG[CONFIG_FTP_CDN_PATH]}/#{@processed_video.s3_root_dir}/previews/#{self.id.to_s}.flv", @processed_video.output_ftp_path
    end
  end
end

class ChangeProcessedVideoType < ActiveRecord::Migration
  def self.up
    execute "update videos set type = 'FullProcessedVideo' where type = 'ProcessedVideo'"
    remove_column :videos, :format
    add_column :videos, :thumbnail_s3_path, :string
  end

  def self.down
    add_column :videos, :format, :string
    remove_column :videos, :thumbnail_s3_path
    execute "update videos set type = 'ProcessedVideo' where type = 'FullProcessedVideo'"
  end
end

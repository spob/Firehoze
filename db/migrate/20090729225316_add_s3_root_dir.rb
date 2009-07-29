class AddS3RootDir < ActiveRecord::Migration
  def self.up
    add_column :videos, :s3_root_dir, :string
  end

  def self.down
    remove_column :videos, :s3_root_dir
  end
end

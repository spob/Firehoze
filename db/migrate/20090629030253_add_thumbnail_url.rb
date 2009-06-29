class AddThumbnailUrl < ActiveRecord::Migration
  def self.up
    change_table :lessons do |t|
      t.column :thumbnail_url, :string
    end
  end

  def self.down
    remove_column :lessons, :thumbnail_url
  end
end

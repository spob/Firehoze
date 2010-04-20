class CreateFacebookPublishers < ActiveRecord::Migration
  def self.up
    create_table :facebook_publishers do |t|

      t.timestamps
    end
  end

  def self.down
    drop_table :facebook_publishers
  end
end

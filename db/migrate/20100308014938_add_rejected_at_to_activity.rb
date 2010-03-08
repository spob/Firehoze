class AddRejectedAtToActivity < ActiveRecord::Migration
  def self.up
    add_column :activities, :rejected_at, :datetime
  end

  def self.down
    remove_column :activities, :rejected_at
  end
end

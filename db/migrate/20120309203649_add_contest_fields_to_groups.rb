class CreateContests < ActiveRecord::Migration
  def self.up
    add_column :groups, :contest,             :boolean
    add_column :groups, :starts_at,           :datetime
    add_column :groups, :ends_at,             :datetime
  end

  def self.down
    remove_column :groups, :contest
    remove_column :groups, :starts_at
    remove_column :groups, :ends_at
  end
end

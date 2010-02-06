class LimitGroupName < ActiveRecord::Migration
  def self.up
    change_column(:groups, :name, :string, :limit => 50)
  end

  def self.down     
  end
end

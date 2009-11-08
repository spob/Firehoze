class AddIndexToTopics < ActiveRecord::Migration
  def self.up
    add_index :topics, [:title]
  end

  def self.down
    remove_index :topics, [:title]
  end
end
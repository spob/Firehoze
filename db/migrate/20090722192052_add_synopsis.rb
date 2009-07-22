class AddSynopsis < ActiveRecord::Migration
  def self.up
    add_column :lessons, :synopsis, :string, :limit => 500
    execute('update lessons set synopsis = description where synopsis is null');
    change_column :lessons, :synopsis, :string, :limit => 500, :null => false
  end

  def self.down
    remove_column :lessons, :synopsis
  end
end

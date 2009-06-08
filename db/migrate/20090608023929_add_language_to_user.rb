class AddLanguageToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :language, :string, :null => false, :default => 'en', :limit => 20
  end

  def self.down
    remove_column :users, :language
  end
end

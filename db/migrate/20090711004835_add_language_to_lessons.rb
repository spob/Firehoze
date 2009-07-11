class AddLanguageToLessons < ActiveRecord::Migration
  def self.up
    change_table :lessons do |t|
      t.string   :language, :null => false, :default => 'en', :limit => 20
    end
  end

  def self.down
    remove_column :lessons, :language
  end
end

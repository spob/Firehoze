class RenameDescriptionToNotes < ActiveRecord::Migration
  def self.up
    rename_column :lessons, :description, :notes
  end

  def self.down
    rename_column :lessons, :notes, :description
  end
end
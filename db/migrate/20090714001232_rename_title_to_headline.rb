class RenameTitleToHeadline < ActiveRecord::Migration
  def self.up
    rename_column :reviews, :title, :headline
  end

  def self.down
    rename_column :reviews, :headline, :title
  end
end

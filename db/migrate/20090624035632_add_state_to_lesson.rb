class AddStateToLesson < ActiveRecord::Migration
  def self.up
    change_table :lessons do |t|
      t.column :state, :string, :null => false, :default => 'Pending', :limit => 25
    end
    add_index(:lessons, :state, :unique => false)
  end

  def self.down
    remove_index(:lessons, :state)
    remove_column :lessons, :state
  end
end

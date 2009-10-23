class CreateGroups < ActiveRecord::Migration
  def self.up
    create_table :groups do |t|
      t.string  :name,       :null => false
      t.boolean :private,    :null => false
      t.text    :description

      t.timestamps
    end

    add_index(:groups, :name, :unique => true)
  end

  def self.down
    remove_index(:groups, :name)
    drop_table :groups
  end
end

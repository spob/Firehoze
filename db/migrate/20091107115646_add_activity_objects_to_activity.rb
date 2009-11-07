class AddActivityObjectsToActivity < ActiveRecord::Migration
  def self.up
    execute('delete from activities')
    execute('update groups set activity_compiled_at = null where activity_compiled_at IS NOT NULL')
    execute('update group_lessons set activity_compiled_at = null where activity_compiled_at IS NOT NULL')
    execute('update group_members set activity_compiled_at = null where activity_compiled_at IS NOT NULL')
    execute('update reviews set activity_compiled_at = null where activity_compiled_at IS NOT NULL')
    execute('update comments set activity_compiled_at = null where activity_compiled_at IS NOT NULL')
    execute('update lessons set activity_compiled_at = null where activity_compiled_at IS NOT NULL')
    execute('update reviews set activity_compiled_at = null where activity_compiled_at IS NOT NULL')

    add_column :activities, :activity_string, :string, :null => false
    add_column :activities, :activity_object_id, :integer, :null => false
    add_column :activities, :activity_object_human_identifier, :string, :null => false
    add_column :activities, :activity_object_class, :string
    add_column :activities, :secondary_activity_object_id, :integer
    add_column :activities, :secondary_activity_object_human_identifier, :string
    add_column :activities, :secondary_activity_object_class, :string
  end

  def self.down
    remove_column :activities, :activity_string
    remove_column :activities, :activity_object_id
    remove_column :activities, :activity_object_human_identifier
    remove_column :activities, :activity_object_class
    remove_column :activities, :secondary_activity_object_id
    remove_column :activities, :secondary_activity_object_human_identifier
    remove_column :activities, :secondary_activity_object_class
  end
end

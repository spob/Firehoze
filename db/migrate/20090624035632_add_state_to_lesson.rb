class AddStateToLesson < ActiveRecord::Migration
  def self.up
    change_table :lessons do |t|
      t.column :state, :string, :null => false, :default => 'pending', :limit => 25
      t.column :flixcloud_job_id, :integer
      t.column :conversion_started_at, :datetime
      t.column :conversion_ended_at, :datetime
    end
    add_index(:lessons, :state, :unique => false)
    add_index(:lessons, :flixcloud_job_id, :unique => false)
  end

  def self.down
    remove_index(:lessons, :state)
    remove_index(:lessons, :flixcloud_job_id)

    remove_column :lessons, :state
    remove_column :lessons, :flixcloud_job_id
    remove_column :lessons, :conversion_started_at
    remove_column :lessons, :conversion_ended_at
  end
end

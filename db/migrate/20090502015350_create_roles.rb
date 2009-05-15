class CreateRoles < ActiveRecord::Migration
    extend MigrationHelpers

  def self.up
    create_table :roles_users, :id => false, :force => true  do |t|
      t.integer :user_id, :role_id
      t.timestamps
    end

    create_table :roles, :force => true do |t|
      t.string  :name, :authorizable_type, :limit => 40
      t.integer :authorizable_id
      t.timestamps
    end

    add_foreign_key(:roles_users, :user_id, :users)
    add_foreign_key(:roles_users, :role_id, :roles)
  end

  def self.down
    remove_foreign_key :roles_users, :user_id
    remove_foreign_key :roles_users, :role_id

    drop_table :roles
    drop_table :roles_users
  end

end

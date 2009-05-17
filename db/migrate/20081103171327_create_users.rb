class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.timestamps
      t.string   :login,              :null => false, :limit => 25
      t.string   :email,              :null => false, :limit => 100
      t.string   :crypted_password,   :null => false
      t.string   :password_salt,      :null => false
      t.string   :persistence_token,  :null => false
      t.string   :perishable_token,   :null => false, :default => ""
      t.string   :time_zone,          :null => false
      t.integer  :login_count,        :null => false, :default => 0
      t.integer  :failed_login_count, :null => false, :default => 0
      t.boolean  :active,             :null => false, :default => 1
      t.string   :last_name,          :null => false, :limit => 40
      t.string   :first_name,         :null => true, :limit => 40
      t.datetime :last_request_at
      t.datetime :last_login_at
      t.datetime :current_login_at
      t.string   :last_login_ip,      :limit => 20
      t.string   :current_login_ip,   :limit => 20
    end

    add_index :users, :login, :unique => true
    add_index :users, :email, :unique => true
    add_index :users, :persistence_token
    add_index :users, :last_request_at
  end

  def self.down
    drop_table :users
  end
end

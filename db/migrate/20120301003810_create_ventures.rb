class CreateVentures < ActiveRecord::Migration
  extend MigrationHelpers

  def self.up
    add_column :users, :venture_created, :boolean
    add_column :users, :venture_name, :text                    , :limit => 255
    add_column :users, :venture_category_id, :integer
    add_column :users, :description, :text                     , :limit => 1000
    add_column :users, :finance_stage, :string                 , :limit => 8
    add_column :users, :development_stage, :string             , :limit => 10
    add_column :users, :website_URL, :string                   , :limit => 255
    add_column :users, :need_mentor, :boolean
    add_column :users, :has_customer, :boolean
    add_column :users, :is_paying_customer, :boolean
  end

  def self.down
    remove_column :users, :venture_created
    remove_column :users, :venture_name
    remove_column :users, :venture_category_id
    remove_column :users, :description
    remove_column :users, :finance_stage
    remove_column :users, :development_stage
    remove_column :users, :website_URL
    remove_column :users, :need_mentor
    remove_column :users, :has_customer
    remove_column :users, :is_paying_customer
  end
end

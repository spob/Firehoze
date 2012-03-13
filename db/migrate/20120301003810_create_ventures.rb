class CreateVentures < ActiveRecord::Migration
  extend MigrationHelpers

  def self.up
      add_column :users, :wizard_step, :integer,                 :default => 1
      # entity
      add_column :users, :description, :text                     , :limit => 1000
      add_column :users, :legal_entity, :string                  , :limit => 4
      add_column :users, :state_incorporated, :string
      add_column :users, :NASIC, :string
      add_column :users, :finance_stage, :string                 , :limit => 8
      add_column :users, :development_stage, :string             , :limit => 10
      # external site
      add_column :users, :website_URL, :string                   , :limit => 255
      add_column :users, :has_customer, :boolean
      add_column :users, :is_paying_customer, :boolean
      # product
      add_column :users, :product_name, :string                 , :limit => 255
      add_column :users, :product_description, :string           , :limit => 1000
      # team needed
      add_column :users, :president_needed, :boolean
      add_column :users, :CTO_needed, :boolean
      add_column :users, :CFO_needed, :boolean
      add_column :users, :advisors_needed, :boolean
      add_column :users, :mentor_needed, :boolean
      add_column :users, :graphic_designer_needed, :boolean
      add_column :users, :product_owner_needed, :boolean
      add_column :users, :scrum_master_needed, :boolean
      add_column :users, :programmer_needed, :boolean
      add_column :users, :architects_needed, :boolean
      add_column :users, :sysadmins_needed, :boolean
      add_column :users, :technical_writer_needed, :boolean
      add_column :users, :marketing_needed, :boolean
      add_column :users, :sales_needed, :boolean
      add_column :users, :equity_compensation, :boolean
      add_column :users, :cash_compensation, :boolean

=begin
    create_table :ventures do |t|
      t.references :user
      t.integer :wizard_step,                                   :default => 1
      t.datetime :created_at
      t.datetime :updated_at
      # demographic
      t.string :name                          , :limit => 100
      t.string :address1                      , :limit => 150
      t.string :address2                      , :limit => 150
      t.string :city                          , :limit => 50
      t.string :state                         , :limit => 50
      t.string :country                       , :limit => 50
      t.string :zip                           , :limit => 25
      # entity
      t.text :description                     , :limit => 1000
      t.string :legal_entity                  , :limit => 4
      t.string :state_incorporated
      t.string :NASIC
      t.string :finance_stage                 , :limit => 8
      t.string :development_stage             , :limit => 10
      # external site
      t.string :website_URL                   , :limit => 255
      t.boolean :has_customer
      t.boolean :is_paying_customer
      # product
      t.string  :product_name                 , :limit => 255
      t.string :product_description           , :limit => 1000
      # team needed
      t.boolean :president_needed
      t.boolean :CTO_needed
      t.boolean :CFO_needed
      t.boolean :advisors_needed
      t.boolean :mentor_needed
      t.boolean :graphic_designer_needed
      t.boolean :product_owner_needed
      t.boolean :scrum_master_needed
      t.boolean :programmer_needed
      t.boolean :architects_needed
      t.boolean :sysadmins_needed
      t.boolean :technical_writer_needed
      t.boolean :marketing_needed
      t.boolean :sales_needed
      t.boolean :equity_compensation
      t.boolean :cash_compensation
    end
    add_foreign_key(:ventures, :user_id, :users)
=end

  end

  def self.down
=begin
    remove_foreign_key(:ventures, :user_id)

    drop_table :ventures
=end

    remove_column :users, :wizard_step
    # entity
    remove_column :users, :description
    remove_column :users, :legal_entity
    remove_column :users, :state_incorporated
    remove_column :users, :NASIC
    remove_column :users, :finance_stage
    remove_column :users, :development_stage
    # external site
    remove_column :users, :website_URL
    remove_column :users, :has_customer
    remove_column :users, :is_paying_customer
    # product
    remove_column :users, :product_name
    remove_column :users, :product_description
    # team needed
    remove_column :users, :president_needed
    remove_column :users, :CTO_needed
    remove_column :users, :CFO_needed
    remove_column :users, :advisors_needed
    remove_column :users, :mentor_needed
    remove_column :users, :graphic_designer_needed
    remove_column :users, :product_owner_needed
    remove_column :users, :scrum_master_needed
    remove_column :users, :programmer_needed
    remove_column :users, :architects_needed
    remove_column :users, :sysadmins_needed
    remove_column :users, :technical_writer_needed
    remove_column :users, :marketing_needed
    remove_column :users, :sales_needed
    remove_column :users, :equity_compensation
    remove_column :users, :cash_compensation
  end
end

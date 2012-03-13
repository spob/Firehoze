class CreateVentures < ActiveRecord::Migration
  extend MigrationHelpers

  def self.up
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
  end

  def self.down
    remove_foreign_key(:ventures, :user_id)

    drop_table :ventures
  end
end

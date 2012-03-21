class CreatePrizes < ActiveRecord::Migration
  def self.up
    create_table :prizes do |t|
      t.datetime  :created_at
      t.datetime  :updated_at
      t.string    :name                          , :limit => 100
      t.text      :description                   , :limit => 1000
      t.string    :type
    end
  end

  def self.down
    drop_table :prizes
  end
end

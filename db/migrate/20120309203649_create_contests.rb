class CreateContests < ActiveRecord::Migration
  def self.up
    create_table :contests do |t|
      t.datetime  :created_at
      t.datetime  :updated_at
      t.string    :name                          , :limit => 100
      t.text      :description                   , :limit => 1000
      t.datetime  :starts_at
      t.datetime  :ends_at
      t.string    :thumbnail_url
      t.datetime  :completed_at
    end
  end

  def self.down
    drop_table :contests
  end
end

class CreateContestPrizes < ActiveRecord::Migration
  extend MigrationHelpers

  def self.up
    create_table :contest_prizes do |t|
      t.references :group
      t.references :prize
      t.datetime  :created_at
      t.datetime  :updated_at
      t.integer   :place
      t.float     :quantity
      t.datetime  :awarded_at
    end

    add_foreign_key(:contest_prizes, :group_id, :groups)
    add_foreign_key(:contest_prizes, :prize_id, :prizes)
  end

  def self.down
    remove_foreign_key(:contest_prizes, :group_id)
    remove_foreign_key(:contest_prizes, :prize_id)

    drop_table :contest_prizes
  end
end

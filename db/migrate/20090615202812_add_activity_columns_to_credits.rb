class AddActivityColumnsToCredits < ActiveRecord::Migration
  def self.up
    change_table :credits do |t|
      t.column :will_expire_at, :datetime, :null => false, :default => 1.years.since
      t.column :expiration_warning_issued_at, :datetime, :null => true
    end

    change_table :credits do |t|
      t.change_default(:will_expire_at, nil)
    end
  end

  def self.down
    remove_column :credits, :will_expire_at
    remove_column :credits, :expiration_warning_issued_at
  end
end

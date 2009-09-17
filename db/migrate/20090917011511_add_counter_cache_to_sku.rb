class AddCounterCacheToSku < ActiveRecord::Migration
  def self.up
    add_column :skus, :credits_count, :integer, :default => 0   #
    CreditSku.reset_column_information
    CreditSku.all.each do |p|
      p.update_attribute :credits_count, p.credits.length
    end
  end

  def self.down
    remove_column :skus, :credits_count
  end
end

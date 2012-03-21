class ChangeLessonsAudienceDefaultValue < ActiveRecord::Migration
  def self.up
    change_table :lessons do |t|
      t.change_default(:audience, 'other')
    end
  end

  def self.down
    change_table :lessons do |t|
      t.change_default(:audience, 'college')
    end
  end
end

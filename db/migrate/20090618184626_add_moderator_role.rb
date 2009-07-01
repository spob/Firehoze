class AddModeratorRole < ActiveRecord::Migration
  def self.up
    Role.create! :name => ROLE_MODERATOR
  end

  def self.down
    Role.find_by_name(ROLE_MODERATOR).destroy
  end
end

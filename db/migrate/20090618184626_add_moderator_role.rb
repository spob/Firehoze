class AddModeratorRole < ActiveRecord::Migration
  def self.up
    Role.create! :name => Constants::ROLE_MODERATOR
  end

  def self.down
    Role.find_by_name(Constants::ROLE_MODERATOR).destroy
  end
end

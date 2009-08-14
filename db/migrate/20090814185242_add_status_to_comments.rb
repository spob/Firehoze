class AddStatusToComments < ActiveRecord::Migration
  def self.up
    add_column :comments, :status, :string, :limit => 15

    Comment.reset_column_information                        

    Comment.update_all(:status => COMMENT_STATUS_ACTIVE)
  end

  def self.down
    remove_column :comments, :status
  end
end

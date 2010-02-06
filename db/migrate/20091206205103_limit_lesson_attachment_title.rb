class LimitLessonAttachmentTitle < ActiveRecord::Migration
  def self.up
    change_column(:lesson_attachments, :title, :string, :limit => 50)
  end

  def self.down
  end
end

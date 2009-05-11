class Video < ActiveRecord::Base
  belongs_to :author, :class_name => "User", :foreign_key => "user_id"
  validates_presence_of :author, :title
  validates_length_of :title, :maximum => 150, :allow_nil => true
end

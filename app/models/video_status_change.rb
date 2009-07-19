class VideoStatusChange < ActiveRecord::Base
  validates_presence_of :lesson
  belongs_to :lesson
  belongs_to :video
end

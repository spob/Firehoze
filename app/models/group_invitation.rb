class GroupInvitation < ActiveUrl::Base
  extend HashHelper

  attribute :message, :accessible => true
  attribute :to_user, :accessible => true
  attribute :to_user_email, :accessible => true 
  belongs_to :user
  belongs_to :group
  validates_presence_of :user, :group
  after_save :send_invitation_email

  private
  
  def send_invitation_email
    Notifier.deliver_group_invitation(self)
  end
end
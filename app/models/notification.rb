class Notification < ApplicationRecord

  belongs_to :recipient, class_name: "User", :foreign_key => 'recipient_id',  optional: true
  belongs_to :organization,  optional: true
  validates :subject, :message, presence: true
  default_scope { where(is_deleted: false) }
  scope :not_readed, -> {where(is_read: false)}
  
end

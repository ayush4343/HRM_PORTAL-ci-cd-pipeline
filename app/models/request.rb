class Request < ApplicationRecord
  include ActiveStorageSupport::SupportForBase64
  include FirebaseNotification
  include OrganizationFirebaseNotification

  # attachment
  has_many_base64_attached :ticket_images

  # enum
  enum status: [:open, :in_progress, :resolved, :escalate, :reopened]
  enum type_of_concern: [:queries, :complaint, :request]

  # scope
  scope :request_status, ->(status, type_of_concern) { where(status: status, type_of_concern: type_of_concern) }
  scope :queries_ticket, -> { where(type_of_concern: "queries") }
  scope :complaint_ticket, -> { where(type_of_concern: "complaint") }
  scope :request_ticket, -> { where(type_of_concern: "request") }
  scope :resolved_request, -> { where(status: "resolved") }

  # association
  has_many :comments, dependent: :destroy
  belongs_to :department
  belongs_to :user

  # validation
  validates :title, :description, :status,  presence: true

  # callback
  after_save :send_notifications
  after_update :update_notification
  

  private
  def send_notifications
    return unless status == 'open'
    notify_admins
    notify_user
  end


  def update_notification
  	if status == 'in_progress'
	  	notify_open_organization
	  	notify_open_user
	  elsif status == 'resolved'
	  	notify_resolved_admin
	  	notify_resolved_user
	  elsif
	  	status == 'escalate'
	  	notify_escalate_admin
	  	notify_escalate_user
	  else
	  	status == 'reopened'
	  	notify_reopen_admin
	  	notify_reopen_user
	  end		
  end

  private

  def notify_admins
    organization = self.user.organization
    notification = Notification.create(organization_id: organization.id,subject: "New Ticket Request from #{user.first_name}",message: "Congratulations, a new ticket request is here, please check and accept the ticket.", notification_type: "open", parent_id: id)
    OrganizationFirebaseNotification.organization_push_notification(notification.subject,notification.message,notification.notification_type,[notification.organization],recipient_id: notification.organization_id )
  end

  def notify_user
    roles = Array.new(User.where(role_id: self.department.roles.ids, organization_id: self.department.organization).ids)
    roles << self.user_id
    User.where(id: roles).each do |admin|
      notification = Notification.create(recipient_id: admin.id,  subject: 'Your ticket is under process', message: "Hello, your ticket is under process, Admin owner will resolve the ticket soon.", notification_type: "open",parent_id: id )
      FirebaseNotification.fcm_push_notification(notification.subject,notification.message,notification.notification_type,[notification.recipient],recipient_id: notification.recipient_id)
    end
  end


  def notify_open_user
    roles = Array.new(User.where(role_id: self.department.roles.ids, organization_id: self.department.organization).ids)
    roles << self.user_id
    User.where(id: roles).each do |admin|
      notification = Notification.create(recipient_id: admin.id,subject: 'Your ticket is under process',message: "Hello, your ticket has been opened, Admin owner will resolve the ticket soon.", notification_type: "in_progress", parent_id: id)
      FirebaseNotification.fcm_push_notification(notification.subject,notification.message,notification.notification_type,[notification.recipient],recipient_id: notification.recipient_id )
    end
  end

  def notify_open_organization
    organization = self.user.organization
    notification = Notification.create(organization_id: organization.id,  subject: "Ticket has been opened for #{user.first_name}", message: "Congratulations, ticket has been opended.", notification_type: "in_progress",parent_id: id )
    OrganizationFirebaseNotification.organization_push_notification(notification.subject,notification.message,notification.notification_type,[notification.organization],organization_id: notification.organization_id)
  end

  def notify_resolved_admin   
    organization = self.user.organization
    notification = Notification.create(organization_id: organization.id,subject: "Ticket has been resolved for #{user.first_name}",message: "Congratulations, ticket has been resolved.", notification_type: "resolved", parent_id: id)
    OrganizationFirebaseNotification.organization_push_notification(notification.subject,notification.message,notification.notification_type,[notification.organization],recipient_id: notification.organization_id )
  end

  def notify_resolved_user
    roles = Array.new(User.where(role_id: self.department.roles.ids, organization_id: self.department.organization).ids)
    roles << self.user_id 
    User.where(id: roles).each do |admin|
      notification = Notification.create(recipient_id: admin.id,  subject: 'Your ticket has been resolved', message: "Hello, your ticket has been resolved.", notification_type: "resolved",parent_id: id )
      FirebaseNotification.fcm_push_notification(notification.subject,notification.message,notification.notification_type,[notification.recipient],recipient_id: notification.recipient_id)
    end
  end

  def notify_escalate_admin
    organization = self.user.organization
    notification = Notification.create(organization_id: organization.id,subject: "Ticket has been escalated for #{user.first_name}",message: "Ticket has been escalated.", notification_type: "escalated", parent_id: id)
    OrganizationFirebaseNotification.organization_push_notification(notification.subject,notification.message,notification.notification_type,[notification.organization],recipient_id: notification.organization_id )
  end

  def notify_escalate_user
    roles = Array.new(User.where(role_id: self.department.roles.ids, organization_id: self.department.organization).ids)
    roles << self.user_id 
    User.where(id: roles).each do |admin|
      notification = Notification.create(recipient_id: admin.id,  subject: 'Your ticket has been escalated', message: "Hello, your ticket has been escalated.", notification_type: "escalated",parent_id: id )
      FirebaseNotification.fcm_push_notification(notification.subject,notification.message,notification.notification_type,[notification.recipient],recipient_id: notification.recipient_id)
    end
  end

  def notify_reopen_admin
    organization = self.user.organization
    notification = Notification.create(organization_id: organization.id,subject: "Ticket has been reopend for #{user.first_name}",message: "Congratulations, ticket has been resolved.", notification_type: "reopened", parent_id: id)
    OrganizationFirebaseNotification.organization_push_notification(notification.subject,notification.message,notification.notification_type,[notification.organization],recipient_id: notification.organization_id )
  end

  def notify_reopen_user
    roles = Array.new(User.where(role_id: self.department.roles.ids, organization_id: self.department.organization).ids)
    roles << self.user_id 
    User.where(id: roles).each do |admin|
      notification = Notification.create(recipient_id: admin.id,  subject: 'Your ticket has been reopend', message: "Hello, your ticket has been reopend,Admin owner will resolve the ticket soon.", notification_type: "reopened",parent_id: id )
      FirebaseNotification.fcm_push_notification(notification.subject,notification.message,notification.notification_type,[notification.recipient],recipient_id: notification.recipient_id)
    end
  end
end


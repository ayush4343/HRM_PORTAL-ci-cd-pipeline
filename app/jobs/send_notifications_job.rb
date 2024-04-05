# app/jobs/send_notifications_job.rb
class SendNotificationsJob < ApplicationJob
  queue_as :default

  def perform
    request = Request.find(self.id)
    case request.status
    when 'open'
      notify_admins(request)
      notify_user(request)
    when 'in_progress'
      notify_in_progrss_organization(request)
      notify_in_progress_user(request)
    when 'resolved'
      notify_resolved_admin(request)
      notify_resolved_user(request)
    when 'escalate'
      notify_escalate_admin(request)
      notify_escalate_user(request)
    when 'reopened'
      notify_reopen_admin(request)
      notify_reopen_user(request)
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


  def notify_in_progress_user
    roles = Array.new(User.where(role_id: self.department.roles.ids, organization_id: self.department.organization).ids)
    roles << self.user_id
    User.where(id: roles).each do |admin|
      notification = Notification.create(recipient_id: admin.id,subject: 'Your ticket is under process',message: "Hello, your ticket has been in_progress, Admin owner will resolve the ticket soon.", notification_type: "in_progress", parent_id: id)
      FirebaseNotification.fcm_push_notification(notification.subject,notification.message,notification.notification_type,[notification.recipient],recipient_id: notification.recipient_id )
    end
  end

  def notify_in_progrss_organization
    organization = self.user.organization
    notification = Notification.create(organization_id: organization.id,  subject: "Ticket has been in_progress for #{user.first_name}", message: "Congratulations, ticket has been in_progress.", notification_type: "in_progress",parent_id: id )
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

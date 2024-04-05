# app/jobs/send_regularization_notifications_job.rb
class SendRegularizationNotificationsJob < ApplicationJob
  queue_as :default

  def perform(regularization_id)
    @regularization = Regularization.find(regularization_id)
    case @regularization.status
    when 'pending'
      notify_admins_pending
      notify_user_pending
    when 'rejected'
      notify_admins_rejected
      notify_user_rejected
    when 'approved'
      notify_admins_approved
      notify_user_approved
    when 'cancel'
      notify_admins_cancel
      notify_user_cancel
    end
  end

    def notify_admins_pending
      organization = @regularization&.attendance&.user&.organization
      return unless organization.present? && organization.device_token.present?

      notification = Notification.create(
        organization_id: organization.id,
        subject: "New regularization Request from #{@regularization&.attendance&.user&.first_name}",
        message: "Congratulations, a new regularization request is here, please check and approve the regularization request.",
        notification_type: "pending"
      )

      OrganizationFirebaseNotification.organization_push_notification(
        notification.subject,
        notification.message,
        notification.notification_type,
        organization.id,
        recipient_id: organization.id
      )
    end

    def notify_user_pending
      notification = Notification.create(recipient_id: @regularization&.attendance&.user&.id,  subject: 'Your regularization Request is under process', message: "Hello, your regularization Request is under process, Admin owner will approve the regularization Request soon.", notification_type: "pending")
      FirebaseNotification.fcm_push_notification(notification.subject,notification.message,notification.notification_type,[notification.recipient],recipient_id: notification.recipient_id)
    end

    def notify_admins_rejected
      organization = @regularization&.attendance&.user&.organization
      return unless organization.present? && organization.device_token.present?

      notification = Notification.create(
        organization_id: organization.id,
        subject: "New regularization Request from #{@regularization&.attendance&.user&.first_name}",
        message: "Congratulations, a new regularization request is here, please check and approve the regularization request.",
        notification_type: "rejected"
        # parent_id: id
      )

      OrganizationFirebaseNotification.organization_push_notification(
        notification.subject,
        notification.message,
        notification.notification_type,
        organization.id,
        recipient_id: organization.id
      )
    end

    def notify_user_rejected
      notification = Notification.create(recipient_id: @regularization&.attendance&.user&.id,  subject: 'Your regularization Request is reject', message: "Hello, your regularization Request is reject", notification_type: "rejected")
      FirebaseNotification.fcm_push_notification(notification.subject,notification.message,notification.notification_type,[notification.recipient],recipient_id: notification.recipient_id)
    end

    def notify_admins_approved
      organization = @regularization&.attendance&.user&.organization
      return unless organization.present? && organization.device_token.present?

      notification = Notification.create(
        organization_id: organization.id,
        subject: "New regularization Request from #{@regularization&.attendance&.user&.first_name}",
        message: "Congratulations, a new regularization request is here, please check and approve the regularization request.",
        notification_type: "approved"
      )

      OrganizationFirebaseNotification.organization_push_notification(
        notification.subject,
        notification.message,
        notification.notification_type,
        organization.id,
        recipient_id: organization.id
      )
    end

    def notify_user_approved
      notification = Notification.create(recipient_id: @regularization&.attendance&.user&.id,  subject: 'Your regularization Request is approved', message: "Hello, your regularization approved", notification_type: "approved")
      FirebaseNotification.fcm_push_notification(notification.subject,notification.message,notification.notification_type,[notification.recipient],recipient_id: notification.recipient_id)
    end

    def notify_admins_cancel
      organization = @regularization&.attendance&.user&.organization
      return unless organization.present? && organization.device_token.present?

      notification = Notification.create(
        organization_id: organization.id,
        subject: "New regularization Request from #{@regularization&.attendance&.user&.first_name}",
        message: "Congratulations, a new regularization request is here, please check and approve the regularization request.",
        notification_type: "cancel"
      )

      OrganizationFirebaseNotification.organization_push_notification(
        notification.subject,
        notification.message,
        notification.notification_type,
        organization.id,
        recipient_id: organization.id
      )
    end

    def notify_user_cancel
      notification = Notification.create(recipient_id: @regularization&.attendance&.user&.id,  subject: 'Your regularization Request is cancel', message: "Hello, your regularization cancel", notification_type: "cancel")
      FirebaseNotification.fcm_push_notification(notification.subject,notification.message,notification.notification_type,[notification.recipient],recipient_id: notification.recipient_id)
    end
end





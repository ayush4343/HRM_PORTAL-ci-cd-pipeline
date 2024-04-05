module OrganizationFirebaseNotification
  require 'fcm'
    def self.organization_push_notification(title, message, type, organization_id, data)
    puts "**************************************#{data}"
    fcm_client = FCM.new('AAAANNkkDbo:APA91bHZXkVBFrkzMDZ26IBxJN4H27YoZ77GJbGKMN4UjWShw9e5kgg3hziOc5uW9oGB9j1oiGe9EGOcVgSpL3OnFrBwR32IvsBQfJGtE7nvgpEIFvULGF_1A4SPuCYEK5kV16_AS6BN') # set your FCM_SERVER_KEY

    organization = Organization.find_by(id: organization_id)
    return unless organization.present? && organization.device_token.present?

    device_notifications_android = Organization.where(id: organization_id, device_type: 'android').where.not(device_token: nil)
    device_notifications_ios = Organization.where(id: organization_id, device_type: 'ios').where.not(device_token: nil)

    puts "Android Devices: #{device_notifications_android.pluck(:device_token)}"
    puts "iOS Devices: #{device_notifications_ios.pluck(:device_token)}"

    ios_options = {
      priority: 'high',
      notification: {
        title: title,
        body: message,
        type: type
      },
      data: data
    }

    begin
      response = fcm_client.send(device_notifications_ios.pluck(:device_token), ios_options)
      Rails.logger.info "iOS Notification Response: #{response}"
    rescue StandardError => e
      puts "iOS Notification Error: #{e.message}"
    end

    android_options = {
      priority: 'high',
      notification: {
        title: title,
        body: message,
        type: type
      },
      data: data
    }

    begin
      response = fcm_client.send(device_notifications_android.pluck(:device_token), android_options)
      Rails.logger.info "Android Notification Response: #{response}"
    rescue StandardError => e
      puts "Android Notification Error: #{e.message}"
    end
  end

end
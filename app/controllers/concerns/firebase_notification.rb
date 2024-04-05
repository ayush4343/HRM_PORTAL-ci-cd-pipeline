module FirebaseNotification
  require 'fcm'
  def self.fcm_push_notification(title, message, type, user_ids, data)
    puts "**************************************#{data}"
    fcm_client = FCM.new('AAAANNkkDbo:APA91bHZXkVBFrkzMDZ26IBxJN4H27YoZ77GJbGKMN4UjWShw9e5kgg3hziOc5uW9oGB9j1oiGe9EGOcVgSpL3OnFrBwR32IvsBQfJGtE7nvgpEIFvULGF_1A4SPuCYEK5kV16_AS6BN') # set your FCM_SERVER_KEY
    users = User.where(id: user_ids)
    Rails.logger.info "-----users-------------------#{users.inspect}---------------------------"
    device_notifications_android = users.where(device_type: 'android').where.not(device_token: nil)
    device_notifications_ios = users.where(device_type: 'ios').where.not(device_token: nil)
    ios_options = { priority: 'high',
          data: data,
          notification: {
            body: message,
            title: title,
            type: type
          }
        }
    device_notifications_ios.pluck(:device_token).each_slice(20) do |registration_id|
      Rails.logger.info "-----registration_id-------------------#{registration_id}---------------------------"
      begin
        response = fcm_client.send(registration_id, ios_options)
        Rails.logger.info "^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^#{response}"
      rescue Exception => e
        puts "=============>#{e.message}"
      end
    end

    android_options = { priority: 'high',
     data: data,
      notification: {
        body: message,
        title: title,
        type: type
      }
    }

    device_notifications_android.pluck(:device_token).each_slice(20) do |registration_id|
      puts "=======================+#{android_options}"
      begin
        response = fcm_client.send(registration_id, android_options)
        Rails.logger.info "^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^#{response}"
      rescue Exception => e
        puts "=============>#{e.message}"
      end
    end
  end
end

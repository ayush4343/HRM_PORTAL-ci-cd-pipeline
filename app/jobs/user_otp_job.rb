class UserOtpJob < ApplicationJob
  queue_as :default

  def perform(user, verification_code, host)
    if user.email.present?
      UserOtpMailer.otp_email(user, verification_code, host).deliver_now    
    end
  end
end

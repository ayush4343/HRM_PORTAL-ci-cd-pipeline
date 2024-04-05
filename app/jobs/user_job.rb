class UserJob < ApplicationJob
  queue_as :default

  def perform(user)
    if user.email.present?
      UserMailer.welcome_email(user).deliver_now    
    end
  end
end

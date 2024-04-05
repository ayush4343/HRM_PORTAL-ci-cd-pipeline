class AttendanceAdjustmentJob < ApplicationJob
  queue_as :default

  def perform(user,regularization, current_user)
    @org = user&.organization
    @current_user = current_user
    @regularization = regularization
    regularization.user_ids.each do|user|
      user = User.find_by(id: user)
      if user.email.present?
        SendRegulrizationMailer.send_regularization_email(user, @regularization, @current_user).deliver_now    
      end
    end
     SendRegulrizationMailer.send_regularization_email(@org, @regularization, @current_user).deliver_now
   end
end

class SendApprovalEmailJob < ApplicationJob
  queue_as :default

  def perform(user,regularization, current_user)
    @org = user&.organization
    @user = user
    @current_user = current_user
    @regularization = regularization
    regularization.user_ids.each do|user|
      user = User.find_by(id: user)
      if user.email.present?
        RegularizationMailer.request_approved_email(user, @regularization, @current_user).deliver_now    
      end
    end
     RegularizationMailer.request_approved_email(@user, @regularization, @current_user).deliver_now
     RegularizationMailer.request_approved_email(@org, @regularization, @current_user).deliver_now
   end
end

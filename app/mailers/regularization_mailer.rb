class RegularizationMailer < ApplicationMailer
  default from: 'your_email@example.com'

  def request_approved_email(user,regularization, current_user)
    @user = user
    @regularization = regularization
    @current_user = current_user
    attachments['logo.png'] = File.read(Rails.root.join('app', 'assets', 'images', 'logo.png'))
    mail(to: @user.email, subject: 'Your Regularization Request has been Approved')
  end
end
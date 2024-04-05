class SendRegulrizationMailer < ApplicationMailer
  default from: 'your_email@example.com'
  def send_regularization_email(user,regularization, current_user)
      @user = user
      @regularization = regularization
      @current_user = current_user
      attachments['logo.png'] = File.read(Rails.root.join('app', 'assets', 'images', 'logo.png'))
      mail(to: @user.email, subject: 'Regularization Request')
  end
end

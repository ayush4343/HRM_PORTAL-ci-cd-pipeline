class UserMailer < ApplicationMailer
  default from: 'notifications@example.com'
   def welcome_email(user)
      @user = user  
      attachments['logo.png'] = File.read(Rails.root.join('app', 'assets', 'images', 'logo.png'))
      mail to: @user.email, subject: "Welcome to OMS Portal", from: "info@mysite.com"
   end
end
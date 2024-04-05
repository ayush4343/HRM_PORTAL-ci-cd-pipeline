class UserOtpMailer < ApplicationMailer
  def otp_email(user, verification_code, host)
     @user = user
     @verification_code  = verification_code
     @host = host
      @host = Rails.env.development? ? 'http://localhost:3000' : host
      attachments['logo.png'] = File.read(Rails.root.join('app', 'assets', 'images', 'logo.png'))
      mail(
      to: @user.email,
      from: 'notifications@example.com',
      subject: 'OMS Portal | OTP to reset your password') do |format|
      format.html { render 'otp_email' }
    end
  end
end


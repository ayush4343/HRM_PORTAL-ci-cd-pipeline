class RequestMailer < ApplicationMailer
  default from: 'notifications@example.com'
	def send_escalate_mail(request, comments)
		@request = request 
		@comment = comments 
		@organization = @request&.user&.organization
		attachments['logo.png'] = File.read(Rails.root.join('app', 'assets', 'images', 'logo.png'))
		mail to: @organization.email, subject: "OMS Portal | A Ticket is Escalated ", from: "info@mysite.com"
	end
end

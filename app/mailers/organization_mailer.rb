class OrganizationMailer < ApplicationMailer
  default from: 'notifications@example.com'
	def welcome_organization_email(organization)
		@organization = organization  
		attachments['logo.png'] = File.read(Rails.root.join('app', 'assets', 'images', 'logo.png'))
		mail to: @organization.email, subject: "Welcome to OMS Portal", from: "info@mysite.com"
	end
end

class OrganizationWelocmeEmailJob < ApplicationJob
  queue_as :default

  def perform(organization)
    if organization.email.present?
      OrganizationMailer.welcome_organization_email(organization).deliver_now    
    end
  end
end

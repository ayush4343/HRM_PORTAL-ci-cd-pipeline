class RequestJob < ApplicationJob
  queue_as :default

  def perform(request, comments)
    @organization = request&.user&.organization
    if  @organization&.email&.present?
     RequestMailer.send_escalate_mail(request, comments).deliver_now 
    end
  end
end

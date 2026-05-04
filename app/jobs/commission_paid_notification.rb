class CommissionPaidNotification
  include ActionView::Helpers::UrlHelper
  @queue = :notifications_queue

  def self.perform(lead_id, lead_property_id)
    lead_property = LeadProperty.find(lead_property_id)
    lead = Lead.find(lead_id)
    agent = User.find(lead.user_id)
    lead.create_manager_notification("Commission paid - #{agent.fullname} received the commission for property ID##{link_to(lead_property.property_id, Rails.application.routes.url_helpers.property_path(lead_property.property_id))} from #{lead.name}")
  end
end

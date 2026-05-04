class ContractSignedNotification
  include ActionView::Helpers::UrlHelper
  @queue = :notifications_queue

  def self.perform(lead_id, lead_property_id)
    lead_property = LeadProperty.find(lead_property_id)
    lead = Lead.find(lead_id)
    agent = User.find(lead.user_id)
    lead.create_manager_notification("Contract signed - #{agent.fullname} signed a contract for property ID##{link_to(lead_property.property_id, Rails.application.routes.url_helpers.property_path(lead_property.property_id))} for #{lead.name}")
  end
end

class VisitDateNotification
  include ActionView::Helpers::UrlHelper
  @queue = :notifications_queue

  def self.perform(lead_id, lead_property_id)
    lead = Lead.find(lead_id)
    lead_property = LeadProperty.find(lead_property_id)
    property = Property.find(lead_property.property_id)
    lead.create_notification("Reminder: You have a visit today with #{link_to(lead.name, Rails.application.routes.url_helpers.lead_path(lead.id))} in a #{link_to(property.property_title, Rails.application.routes.url_helpers.property_path(property.id))}!")
  end

end

class NewLeadNotification
  include ActionView::Helpers::UrlHelper
  @queue = :notifications_queue

  def self.perform(lead_id)
    lead = Lead.find(lead_id)
    lead.create_notification("New lead - #{lead.contract_type}: #{lead.name} | #{link_to('Go to lead »', Rails.application.routes.url_helpers.lead_path(lead.id))}")
  end
end

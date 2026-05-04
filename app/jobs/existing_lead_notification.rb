class ExistingLeadNotification
  include ActionView::Helpers::UrlHelper
  @queue = :notifications_queue

  def self.perform(lead_id)
    lead = Lead.find(lead_id)
    lead.create_notification("#{lead.name} submitted a new request | #{link_to('Check it out »', Rails.application.routes.url_helpers.lead_path(lead.id))}")
  end

end

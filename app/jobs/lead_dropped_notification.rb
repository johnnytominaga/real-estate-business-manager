class LeadDroppedNotification
  include ActionView::Helpers::UrlHelper
  @queue = :notifications_queue

  def self.perform(lead_id, user_id)
    lead = Lead.find(lead_id)
    user = User.find(user_id)
    lead.create_notification("Lead dropped by #{link_to(user.fullname, Rails.application.routes.url_helpers.user_path(user.nickname))} - #{lead.contract_type}: #{lead.name} | #{link_to('Go to lead »', Rails.application.routes.url_helpers.lead_path(lead.id))}")
  end
end

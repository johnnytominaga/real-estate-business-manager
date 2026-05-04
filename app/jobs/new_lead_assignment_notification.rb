class NewLeadAssignmentNotification
  include ActionView::Helpers::UrlHelper
  @queue = :notifications_queue

  def self.perform(lead_id, manager_id)
    lead = Lead.find(lead_id)
    manager = User.find(manager_id)
    lead.create_notification("You've got a new client: #{link_to(lead.name, Rails.application.routes.url_helpers.lead_path(lead.id))} assigned to you by #{link_to(manager.fullname, Rails.application.routes.url_helpers.lead_path(manager.id))}")
  end
end

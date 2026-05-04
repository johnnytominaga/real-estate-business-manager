class ReminderToCallNotification
  include ActionView::Helpers::UrlHelper
  @queue = :owner_notifications_queue

  def self.perform(user_id, property_id)
    property = Property.find(property_id)
    owner = Owner.find(property.owner_id)
    user = User.find_by(id: user_id)
    if !owner.name.blank?
      name = owner.name
    else
      name = owner.phone_number
    end
    owner.remind_to_call("Reminder: Check updates from #{name}: #{link_to('Click to call', Rails.application.routes.url_helpers.owner_path(owner.id))}. This reminder was created when you were on property: #{link_to(property.property_title, Rails.application.routes.url_helpers.property_path(property.id))}.", user.id)

  end

end

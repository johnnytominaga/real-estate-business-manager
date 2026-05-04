class NotificationsChannel < ApplicationCable::Channel
  def subscribed
    stream_from "notification_#{params[:notification_id]}"
  end
end

$(() ->
  App.notifications = App.cable.subscriptions.create {channel: "NotificationsChannel", notification_id: $('#user_id').val()},
    received: (data) ->
      $('#num_of_unread').html(data.unread)
      $('#notifications').prepend(data.message)
      $('#navbar_num_of_unread').html(data.unread)
)

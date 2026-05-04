$(() ->
  App.messages = App.cable.subscriptions.create {channel: "MessagesChannel", conversation_id: $('#conversation_id').val()},
    received: (data) ->
      $('#new_message')[0].reset()
      $('#chat').prepend data.message
)

class MessagesController < ApplicationController

  before_action :authenticate_user!
  before_action :set_conversation

  def index
    if current_user == @conversation.sender || current_user == @conversation.recipient
      @other = current_user == @conversation.sender ? @conversation.recipient : @conversation.sender
      @messages = @conversation.messages.order("created_at DESC")
    else
      redirect_to conversations_path, alert: "Sorry, you can't view this chat."
    end
  end

  def create
    @message = @conversation.messages.new(message_params)
    @messages = @conversation.messages.order("created_at DESC")

    if @message.save
      ActionCable.server.broadcast "conversation_#{@conversation.id}", message: render_message(@message)
      # redirect_to conversation_messages_path(@conversation)
    end

  end

  private

  def set_conversation
      @conversation = Conversation.find(params[:conversation_id])
  end

  def message_params
      params.require(:message).permit(:content, :user_id)
  end

  def render_message(message)
    self.render(partial: 'messages/message', locals: {message:message})
  end

end

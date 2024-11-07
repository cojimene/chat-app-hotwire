class MessagesController < ApplicationController
  before_action :set_room, only: %i[new create]
  before_action :set_message, only: %i[show edit update destroy actions]

  def show; end

  def new; end

  def create
    @message = @room.messages.new(message_params)
    @message.user = current_user

    if @message.save
      @message.broadcast_append_to(@room, :messages, locals: {from_stream: true})
    else
      render :new
    end
  end

  def edit; end

  def update
    if @message.update(message_params)
      @message.broadcast_replace_to(@message.room, :messages, locals: {from_stream: true})
    else
      render :edit
    end
  end

  def destroy
    @message.destroy
    @message.broadcast_remove_to(@message.room, :messages)
  end

  def actions
    render partial: 'actions', locals: {message: @message}
  end

  private

    def set_room
      @room = Room.find(params[:room_id])
    end

    def set_message
      @message = Message.find(params[:id])
    end

    def message_params
      params.require(:message).permit(:content)
    end
end
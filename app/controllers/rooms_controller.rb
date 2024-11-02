class RoomsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_room, only: %i[ show edit update destroy ]

  def index
    @rooms = Room.all
  end

  def show
  end

  def new
    @room = Room.new
  end

  def edit
  end

  def create
    @room = current_user.rooms.create(room_params)

    respond_to do |format|
      format.turbo_stream do
        if @room.errors.any?
          render(
            turbo_stream: turbo_stream.replace(
              'room_form', partial: 'form', locals: {room: @room}
            )
          )
        end
      end
    end
  end

  def update
    respond_to do |format|
      unless @room.update(room_params)
        format.html { render :edit }
      end
    end
  end

  def destroy
    @room.destroy

    respond_to do |format|
      format.html { redirect_to rooms_path, status: :see_other, notice: "Room was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  def add_user
    user_room = UserRoom.create(room_id: params[:room_id], user_id: params[:user_id])

    respond_to do |format|
      format.turbo_stream do
        render(
          turbo_stream: turbo_stream.replace(
            "room_show_#{user_room.room_id}", partial: 'room', locals: {room: user_room.room}
          )
        )
      end
    end
  end

  private
    def set_room
      @room = Room.find(params[:id])
    end

    def room_params
      params.require(:room).permit(:name)
    end
end

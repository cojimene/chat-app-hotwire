class RoomsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_room, only: %i[show edit update destroy add_user]

  def index
    @rooms = current_user.rooms
  end

  def show; end

  def new
    @room = Room.new
  end

  def edit; end

  def create
    @room = current_user.rooms.create(room_params)

    respond_to do |format|
      if @room.persisted?
        format.turbo_stream do
          render turbo_stream: turbo_stream.append(:rooms, @room)
        end
      else
        format.html { render :new }
      end
    end
  end

  def update
    respond_to do |format|
      if @room.update(room_params)
        format.turbo_stream do
          @room.users.each do |user|
            @room.broadcast_replace_to(user, :rooms)
          end
        end
      else
        format.html { render :edit }
      end
    end
  end

  def destroy
    users = @room.users.load
    @room.destroy

    users.each do |user|
      @room.broadcast_remove_to(user, :rooms)

      @room.broadcast_replace_to(
        user, :rooms,
        partial: 'rooms/welcome',
        target: "detail_room_#{@room.id}"
      )
    end
  end

  def add_user
    user_room = @room.user_rooms.create(user_id: params[:user_id])
    @room.broadcast_append_to(user_room.user, :rooms)

    respond_to do |format|
      format.turbo_stream do
        render(
          turbo_stream: turbo_stream.replace(
            "users_room_#{@room.id}", partial: 'users', locals: {room: @room}
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

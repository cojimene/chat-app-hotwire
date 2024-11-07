class RoomsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_room, only: %i[show edit update destroy add_user remove_user]

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
    if @room.update(room_params)
      @room.users.each do |user|
        @room.broadcast_replace_to(user, :rooms)

        @room.broadcast_replace_to(
          user, :rooms,
          partial: 'rooms/title',
          locals: {room: @room},
          target: "title_room_#{@room.id}"
        )
      end
    else
      render :edit
    end
  end

  def destroy
    users = @room.users.load
    @room.destroy
    users.each { |user| broadcast_remove_room_for(user) }
  end

  def add_user
    user_room = @room.user_rooms.create(user_id: params[:user_id])
    @room.broadcast_append_to(user_room.user, :rooms)

    @room.users.each do |user|
      @room.broadcast_replace_to(
        user, :rooms,
        partial: 'rooms/users',
        locals: {room: @room},
        target: "users_room_#{@room.id}"
      )
    end
  end

  def remove_user
    user_room = @room.user_rooms.find_by(user_id: params[:user_id])
    user_room.destroy
    broadcast_remove_room_for(user_room.user)

    @room.users.each do |user|
      @room.broadcast_replace_to(
        user, :rooms,
        partial: 'rooms/users',
        locals: {room: @room},
        target: "users_room_#{@room.id}"
      )
    end
  end

  private

    def set_room
      @room = Room.find(params[:id])
    end

    def room_params
      params.require(:room).permit(:name)
    end

    def broadcast_remove_room_for(user)
      @room.broadcast_remove_to(user, :rooms)

      @room.broadcast_replace_to(
        user, :rooms,
        partial: 'rooms/welcome',
        target: "detail_room_#{@room.id}"
      )
    end
end

class CreateRoomsUsersJoinTable < ActiveRecord::Migration[7.0]
  def up
    create_join_table :rooms, :users

    ActiveRecord::Base.connection.execute(
      <<~SQL
        INSERT INTO rooms_users (room_id, user_id)
        SELECT room_id, user_id
        FROM user_rooms;
      SQL
    )
  end

  def down
    drop_join_table :rooms, :users
  end
end

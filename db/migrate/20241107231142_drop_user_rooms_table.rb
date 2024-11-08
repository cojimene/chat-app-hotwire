class DropUserRoomsTable < ActiveRecord::Migration[7.0]
  def up
    drop_table :user_rooms
  end

  def down
    create_table :user_rooms do |t|
      t.references :user, null: false, foreign_key: true
      t.references :room, null: false, foreign_key: true

      t.timestamps
    end

    ActiveRecord::Base.connection.execute(
      <<~SQL
        INSERT INTO user_rooms (room_id, user_id)
        SELECT room_id, user_id
        FROM rooms_users;
      SQL
    )
  end
end

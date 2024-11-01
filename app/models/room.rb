class Room < ApplicationRecord
  validates :name, presence: true

  has_many :user_rooms, dependent: :destroy
  has_many :users, through: :user_rooms
end

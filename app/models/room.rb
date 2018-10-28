class Room < ApplicationRecord
  belongs_to :user

  has_many :memberships
  has_many :members, through: :memberships, source: :user
end

class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :jwt_authenticatable, jwt_revocation_strategy: JwtBlacklist

  has_many :memberships, dependent: :destroy
  has_many :rooms, through: :memberships
  has_many :tracks, dependent: :nullify
  has_many :messages, dependent: :destroy
  has_many :rooms, dependent: :nullify

  include ImageUploader[:avatar]

end

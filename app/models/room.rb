class Room < ApplicationRecord
  belongs_to :user
  has_many :memberships, dependent: :delete_all
  has_many :members, through: :memberships, source: :user

  def update_track(track, user)
    updatedQueue = self.queue
    i = queue.index{|i| i['user_id'] == user.id}
    updatedQueue[i] = track
    self.update_column(:queue, updatedQueue)
  end

  def set_playing(bool)
    self.playing = bool
  end

  def add_user(user)
    # change to '<< user'
    self.members << user

    # create empty arr
    self.queue = [] if self.queue.nil?

    # add placeholder
    self.queue.push({'user_id': user.id})
    self.save
  end

  def remove_user(user)
    # remove from queue
    position = self.queue.index{|i| i['user_id'] == user.id}
    self.queue.delete_at(position)
    self.save

    # remove from members
    self.members.delete(user)
    self.save

  end
end

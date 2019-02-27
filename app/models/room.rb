class Room < ApplicationRecord
  belongs_to :user

  has_many :memberships, dependent: :delete_all
  has_many :members, through: :memberships, source: :user

  has_many :dj_memberships, dependent: :delete_all
  has_many :djs, through: :dj_memberships, source: :user

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
    if self.members.where(id: user.id).exists?
      p 'user is already a member'
      return
    end

    self.members << user
    self.save
  end

  def remove_user(user)
    self.members.delete(user)
    self.save
  end

  def add_dj(user)
    if self.djs.where(id: user.id).exists?
      p 'user is already a dj'
      return
    end

    self.djs << user

    # add to dj order
    self.current_dj_order = [] if self.current_dj_order.nil?
    self.current_dj_order.push(user)

    # create placeholder queue item
    self.queue = [] if self.queue.nil?
    self.queue.push({'user_id': user.id})

    self.save
  end

  def remove_dj(user)
    # remove from queue
    position = self.queue.index{|i| i['user_id'] == user.id}
    self.queue.delete_at(position)
    self.save

    # remove from dj order
    dj_i = self.current_dj_order.index{|i| i['id'] == user.id}
    self.current_dj_order.delete_at(dj_i)
    self.save

    # remove djs
    self.djs.delete(user)
    self.save
  end

end

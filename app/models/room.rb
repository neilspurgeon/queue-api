class Room < ApplicationRecord
  belongs_to :user

  has_many :memberships, dependent: :delete_all
  has_many :members, through: :memberships, source: :user
  # has_many :queued_tracks

  # before_destroy :destroy_memberships

  def update_track(track, user)
    queue = self.queue
    count = self.members.count

    if (count == 1)

      queue = track

    else

      user_i = self.members.index(user)

      # the inital order position the currently playing user
      current_order_i = self.queue.index(self.current_track)

      # find place in queue to add track
      position = ((count - current_order_i) + user_i) % count

      # place in correct queue position
      queue[position] = track

    end

    self.queue = queue
    self.save

  end

  def set_playing(bool)
    self.playing = bool
  end

  def play_next
    next_i = self.queue.index{|x|!x.nil?}

    if (next_i.nil?)
      self.playing = false
      # self.current_track = nil
      self.save
      return

    else

      track = self.queue[next_i]

      # reorder queue
      arr_a = self.queue.splice(next_i, self.queue.length)
      arr_b   = self.queue.splice(0, next_i)
      queue = arr_a + arr_b

      self.current_track = track
      self.queue = queue
      self.save

    end
  end

  def add_user(user)
    # change to '<< user'
    self.members << user

    # add placeholder
    self.queue.push(nil)
    self.save
  end

  def remove_user(user)

    # remove from queue
    count = self.members.count
    user_i = self.members.index(user)
    current_order_i = self.queue.index(self.current_track)
    position = ((count - current_order_i) + user_i) % count

    self.queue.delete_at(position)
    self.save

    # remove from members
    self.members.delete(user)
    self.save

  end

  # private

  # def destroy_memebers
  #   self.members.destroy_all
  # end

end

class Room < ApplicationRecord
  belongs_to :user

  has_many :memberships
  has_many :members, through: :memberships, source: :user
  # has_many :queued_tracks

  def add_track(track, user)
    queue = self.queue
    count = self.members.count
    p count

    if (count == 1)

      p 'only 1 user'
      queue = track

    else

      user_i = self.members.index(user)
      p user_i

      # the inital order position the currently playing user
      current_order_i = self.queue.index(self.current_track)
      # change to playing in schema
      p current_track
      # need to set current track

      # find place in queue to add track
      position = ((count - current_order_i) + user_i) % count

      # place in correct queue position
      queue[position] = track

    end

    self.queue = queue
    self.save
    p self.queue

  end

  def add_user(user)
    # change to '<< user'
    self.members << User.find(user.id)

    # add nil to queue to keep correct length
    #  even though there isn't a track yet
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

end

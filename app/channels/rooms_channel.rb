class RoomsChannel < ApplicationCable::Channel

  def subscribed
    stream_from "rooms_channel_#{params[:room]}"

    room = Room.find(params[:room])
    room.add_user(current_user)

    # Large initial data should be sent in HTTP request and action cable to broadcast small updates
    ActionCable.server.broadcast("rooms_channel_#{params[:room]}", {
      'memberJoined': current_user
    })
  end

  # change to play next
  def track_change(track)
    room = Room.find(params[:room])
    room.play_next

    ActionCable.server.broadcast("rooms_channel_#{params[:room]}", {
      'trackChanged': 'track'
    })
  end

  def set_playing(bool)
    room = Room.find(params[:room])
    room.set_playing
  end

  def update_user_queue(track)
    p 'udpate user queue'
    room = Room.find(params[:room])
    track = current_user.tracks.create(track: track)

    # this should really only broadcast to the room host
    # I think we can broadcast on the host channel here, just need to store host userID on Room to use
    room.update_track(track, current_user)
    ActionCable.server.broadcast("rooms_channel_#{params[:room]}", {
      'sharedQueueChanged': room.queue
    })
  end

  def unsubscribed
    room = Room.find(params[:room])
    room.remove_user(current_user)

    ActionCable.server.broadcast("rooms_channel_#{params[:room]}", {
      'unsubscribed': {
        'members': room.members
      }
    })

  end
end

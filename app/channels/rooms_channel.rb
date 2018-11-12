class RoomsChannel < ApplicationCable::Channel

  def subscribed
    stream_from "rooms_channel_#{params[:room]}"

    room = Room.find(params[:room])
    room.add_user(current_user)

    # Large initial data should be sent in HTTP request and action cable to broadcast small updates
    ActionCable.server.broadcast("rooms_channel_#{params[:room]}", {
      'memberJoined': current_user.to_json
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
    room = Room.find(params[:room])
    track = current_user.tracks.create(track: track)

    room.update_track(track, current_user)
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

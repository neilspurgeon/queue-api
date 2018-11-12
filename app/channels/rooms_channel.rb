class RoomsChannel < ApplicationCable::Channel

  def subscribed
<<<<<<< HEAD
    stream_from "rooms_channel_#{params[:room]}"

    room = Room.find(params[:room])
    room.add_user(current_user)

    # Large initial data should be sent in HTTP request and action cable to broadcast small updates
    ActionCable.server.broadcast("rooms_channel_#{params[:room]}", {
      'memberJoined': current_user.to_json
    })
=======
    # need to stream for correct room channel id!!!
    stream_from "rooms_channel_#{params[:room]}"
    p "~~ Subscribed to rooms_channel_#{params[:room]} ~~"
    p current_user
>>>>>>> b00994c0beadb87fe985999a232acb419030ab8f
  end

  # change to play next
  def track_change(track)
    room = Room.find(params[:room])
    room.play_next

<<<<<<< HEAD
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
=======
    ActionCable.server.broadcast("rooms_channel_#{params[:room]}", payload )
>>>>>>> b00994c0beadb87fe985999a232acb419030ab8f
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

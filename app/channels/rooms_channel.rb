class RoomsChannel < ApplicationCable::Channel

  def subscribed
    stream_from "rooms_channel_#{params[:room]}"
    p "~~ Subscribed to rooms_channel_#{params[:room]} ~~"
    p current_user
    room = Room.find(params[:room])
    room.add_user(current_user)

    # Large initial data should be sent in HTTP request and action cable to broadcast small updates
    ActionCable.server.broadcast("rooms_channel_#{params[:room]}", {
      'subscribed': {
        'newMember': current_user
      }
    })
  end

  def track_change(track)
    room = Room.find(params[:room])
    room.current_track = track.to_json
    room.save

    ActionCable.server.broadcast("rooms_channel_#{params[:room]}", {
      'trackChanged': track
    })
  end

  def update_user_queue(track)
    room = Room.find(params[:room])
    track = current_user.tracks.create(track: track)
    room.add_track(track, current_user)
  end

  def unsubscribed
    p 'handle unsubscribe here ––––––––––––'
    room = Room.find(params[:room])

    room.remove_user(current_user)

    # remove user membership

    ActionCable.server.broadcast("rooms_channel_#{params[:room]}", {
      'unsubscribed': {
        'members': room.members
      }
    })

    # Any cleanup needed when channel is unsubscribed
    # if user=dj, broadcast change
    # If user=host, set playing to false and broadcast

  end

end

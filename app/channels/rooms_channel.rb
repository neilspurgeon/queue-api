class RoomsChannel < ApplicationCable::Channel

  def subscribed
    stream_from "rooms_channel_#{params[:room]}"
    p "~~ Subscribed to rooms_channel_#{params[:room]} ~~"
    p current_user
    room = Room.find(params[:room])
    room.members << User.find(current_user.id)

    ActionCable.server.broadcast("rooms_channel_#{params[:room]}", {
      'subscribed': {
        'members': room.members
      }
    })
  end

  def track_change(data)
    ActionCable.server.broadcast("rooms_channel_#{params[:room]}", {
      'trackChanged': {
        'track': data
      }
    })
  end

  def unsubscribed
    p 'handle unsubscribe here ––––––––––––'
    room = Room.find(params[:room])

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

class RoomsChannel < ApplicationCable::Channel
  def subscribed
    stream_from 'rooms_channel'
    p '~~ Subscribed to Rooms Channel ~~'
    p current_user
    p params[:room]
  end

  def track_change(data)
    payload = {
      'trackChanged': {
        'track': data
      }
    }

    p payload

    ActionCable.server.broadcast('rooms_channel', payload )
  end

  def unsubscribed
    p 'handle unsubscribe here ––––––––––––'
    # Any cleanup needed when channel is unsubscribed

    # if user=dj, broadcast change

    # If user=host, set playing to false and broadcast
  end
end

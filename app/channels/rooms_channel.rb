class RoomsChannel < ApplicationCable::Channel
  def subscribed
    stream_from "rooms_channel"
    p '~~ Subscribed to Rooms Channel ~~'
    p current_user
  end

  def track_change(data)
    payload = {
      'trackChanged': {
        'track': data
      }
    }

    ActionCable.server.broadcast('rooms_channel', payload )
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end

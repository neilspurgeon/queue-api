class RoomsChannel < ApplicationCable::Channel
  def subscribed
    # need to stream for correct room channel id!!!
    stream_from "rooms_channel_#{params[:room]}"
    p "~~ Subscribed to rooms_channel_#{params[:room]} ~~"
    p current_user
  end

  def track_change(data)
    payload = {
      'trackChanged': {
        'track': data
      }
    }

    ActionCable.server.broadcast("rooms_channel_#{params[:room]}", payload )
  end

  def unsubscribed
    p 'handle unsubscribe here ––––––––––––'
    # Any cleanup needed when channel is unsubscribed

    # if user=dj, broadcast change

    # If user=host, set playing to false and broadcast
  end
end

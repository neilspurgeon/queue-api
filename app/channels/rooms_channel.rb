class RoomsChannel < ApplicationCable::Channel
  def subscribed
    stream_from "rooms_channel"
    p 'subscribed to Rooms Channel ~~~~~~ YAYA'
  end

  def track_change(data)
    p 'track changed'
    # p params
    p data
    p '–––––––––––––––––––––––––––––––––––––––––––––––'
    # @track = params[:track]
    ActionCable.server.broadcast('rooms_channel', {
      'trackChanged': {
        'track': data
      }
    })
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end

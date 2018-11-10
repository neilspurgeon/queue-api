class HostChannel < ApplicationCable::Channel
  def subscribed
    stream_from "some_channel"
    p '–––––––––––––––––––~~~~~~~~~~~~~~~~~~~~~~~~~'
    stream_from "host_channel_#{current_user.id}"
    p "~~ Subscribed to host_channel_#{current_user.id} ~~"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end

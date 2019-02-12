class RoomsChannel < ApplicationCable::Channel

  def subscribed
    stream_from "rooms_channel_#{params[:room]}"

    room = Room.find(params[:room])
    room.add_user(current_user)

    p 'SUBSCRIBED_______________________________________'

    # Large initial data should be sent in HTTP request and action cable to broadcast small updates
    ActionCable.server.broadcast("rooms_channel_#{params[:room]}", {
      'memberJoined': current_user,
      'members': room.members
    })
  end

  def played_from_shared_queue(data)
    room = Room.find(params[:room])
    track = data['track']
    # find the index of the track played
    playedTrackI = room.queue.index(track)
    # split the array into two parts with track played at the END of one
    arr_a = room.queue.slice(0, playedTrackI + 1) # first half 0 - i
    arr_b = room.queue.slice((playedTrackI + 1), room.queue.length)

    # join array back together with track played + 1 at the beginning
    updated_queue = (arr_b + arr_a)
    room.queue = updated_queue
    room.save

    room.current_track = track
    room.save

    # send update of shared queue
    ActionCable.server.broadcast("rooms_channel_#{params[:room]}", {
      'sharedQueueChanged': room.queue
    })

    ActionCable.server.broadcast("rooms_channel_#{params[:room]}", {
      'trackChanged': data
    })

    # tell user their song was played
    ActionCable.server.broadcast("user_channel_#{data['track']['user_id']}", {
      'playedFromMemberQueue': true
    })
  end

  def set_playing(bool)
    room = Room.find(params[:room])
    room.set_playing
  end

  def update_user_queue(track)
    p 'udpate user queue'

    room = Room.find(params[:room])
    track = current_user.tracks.create(track: track['track'])

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
      'memberLeft': {
        'members': room.members,
        'sharedQueueChanged': room.queue
      }
    })

  end
end

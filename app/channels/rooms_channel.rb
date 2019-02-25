class RoomsChannel < ApplicationCable::Channel

  def subscribed
    stream_from "rooms_channel_#{params[:room]}"

    room = Room.find(params[:room])
    room.add_user(current_user)

    ActionCable.server.broadcast("rooms_channel_#{params[:room]}", {
      'memberJoined': current_user,
      'members': room.members,
    })
  end

  def start_djing
    room = Room.find(params[:room])
    room.add_dj(current_user)

    ActionCable.server.broadcast("rooms_channel_#{params[:room]}", {
      'djsChanged': room.current_dj_order
    })
  end

  def stop_djing
    room = Room.find(params[:room])
    room.remove_dj(current_user)

    ActionCable.server.broadcast("rooms_channel_#{params[:room]}", {
      'djsChanged': room.current_dj_order
    })
  end

  def start_playing()
    room = Room.find(params[:room])

    if play_next_track()
      ActionCable.server.broadcast("rooms_channel_#{params[:room]}", {
          'startedPlaying': room.current_track,
          'djsChanged':     room.current_dj_order
        })

      # tell user their song was played to trigger them to send their next song
      ActionCable.server.broadcast("user_channel_#{queuedTrack['user_id']}", {
        'playedFromMemberQueue': true
      })
    else
      ActionCable.server.broadcast("rooms_channel_#{params[:room]}", {
      'error': {'message': 'There are no songs queued.'}
    })
    end
  end

  def track_finished(data)
    room = Room.find(params[:room])

    # Check start timestamp to make sure track actually played
    now = (Time.now.to_f * 1000).to_i
    start = room.current_track['track']['start_time']
    duration = room.current_track['track']['duration_ms']

    if (now - start >= duration)

      if play_next_track()

        updated_room = Room.find(params[:room])
        ActionCable.server.broadcast("rooms_channel_#{params[:room]}", {
          'startedPlaying': updated_room.current_track,
          'djsChanged':     updated_room.current_dj_order
        })

        # tell user their song was played to trigger them to send their next song
        ActionCable.server.broadcast("user_channel_#{updated_room.current_track['user_id']}", {
          'playedFromMemberQueue': true
        })
      else
        # no songs in queue
        ActionCable.server.broadcast("rooms_channel_#{params[:room]}", {
          'playbackFinished': true
        })
      end

    else
      ActionCable.server.broadcast("rooms_channel_#{params[:room]}", {
        'error': {'message': 'Error syncing'}
      })
    end
  end

  def update_user_queue(track)
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

    # remove dj
    if room.djs.find(current_user)
      room.remove_dj(current_user)
    end

    ActionCable.server.broadcast("rooms_channel_#{params[:room]}", {
      'djsChanged': room.current_dj_order,
      'memberLeft': {
        'members': room.members,
        'sharedQueueChanged': room.queue
      }
    })

  end

  private

  def play_next_track
    room = Room.find(params[:room])

    room.queue.each_with_index do |queuedTrack, i|

      # find first item with non-nil track
      if queuedTrack['track']

        # split the array into two parts with track played at the END of one
        queue_arr_a = room.queue.slice(0, i + 1) # first half 0 - i
        queue_arr_b = room.queue.slice((i + 1), room.queue.length)

        # join array back together with track played + 1 at the beginning
        room.queue = (queue_arr_b + queue_arr_a)

        room.current_track = queuedTrack
        # record when the track started playing so we know when it should end
        room.current_track['track']['start_time'] = (Time.now.to_f * 1000).to_i

        # Update DJ order
        dj_i = room.current_dj_order.index{|index| index['id'] ==  queuedTrack['user_id']}
        dj_arr_a = room.current_dj_order.slice(0, dj_i)
        dj_arr_b = room.current_dj_order.slice(dj_i, room.current_dj_order.length)
        room.current_dj_order = (dj_arr_b + dj_arr_a)

        # record when the track started playing so we know when it should end
        room.current_track['track']['start_time'] = (Time.now.to_f * 1000).to_i
        return room.save

      end
    end

    return false

  end
end

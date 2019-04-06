class RoomsChannel < ApplicationCable::Channel
  def subscribed
    stream_from "rooms_channel_#{params[:room]}"

    room = Room.find(params[:room])
    room.add_user(current_user)

    ActionCable.server.broadcast("rooms_channel_#{params[:room]}",{
      type: 'RECEIVED_MEMBER_JOINED',
      data: current_user,
    })

    ActionCable.server.broadcast("rooms_channel_#{params[:room]}",{
      type: 'RECEIVED_MEMBERS_CHANGED',
      data: room.members,
    })

    if room.playing
      ActionCable.server.broadcast("user_channel_#{current_user.id}", {
        type: 'RECEIVED_JOINED_ROOM_IS_PLAYING',
        data: room.current_track,
      })
    end
  end

  def start_djing(data)
    room = Room.find(params[:room])
    track = data['track']
    room.add_dj(current_user)

    ActionCable.server.broadcast("rooms_channel_#{params[:room]}", {
      type: 'RECEIVED_DJS_CHANGED',
      data: room.current_dj_order,
    })

    ActionCable.server.broadcast("user_channel_#{current_user.id}", {
      type: 'RECEIVED_STARTED_DJING',
      data: true
    })

    if track
      updated_room = Room.find(params[:room])
      created_track = current_user.tracks.create(track: track)
      updated_room.update_track(created_track, current_user)

      ActionCable.server.broadcast("rooms_channel_#{params[:room]}", {
        type: 'RECEIVED_SHARED_QUEUE_CHANGED',
        data: updated_room.queue
      })

      # TO DO: add conditional so this only send if the roomready changes
      ActionCable.server.broadcast("rooms_channel_#{params[:room]}", {
        type: 'RECEIVED_ROOM_READY',
        data: true
      })
    end
  end

  def stop_djing
    room = Room.find(params[:room])
    room.remove_dj(current_user)

    ActionCable.server.broadcast("rooms_channel_#{params[:room]}", {
      type: 'RECEIVED_DJS_CHANGED',
      data: room.current_dj_order
    })

    ActionCable.server.broadcast("user_channel_#{current_user.id}", {
      type: 'RECIVED_STOPPED_DJING',
      data: true,
    })

    if room.djs.count < 1
      ActionCable.server.broadcast("rooms_channel_#{params[:room]}", {
        type: 'RECEIVED_ROOM_READY',
        data: false
      })
    end
  end


  def send_message(message)
    room = Room.find(params[:room])
    p message
    new_message = current_user.messages.new(text: message['text'], room: room)

    if (new_message.save)
      ActionCable.server.broadcast("rooms_channel_#{params[:room]}", {
        type: 'RECEIVED_MESSAGE',
        data: new_message.as_json(:include => :user)
      })
    end
  end

  def start_playing()
    if play_next_track()
      updated_room = Room.find(params[:room])
      ActionCable.server.broadcast("rooms_channel_#{params[:room]}", {
        type: 'RECEIVED_STARTED_PLAYING',
        data: updated_room.current_track,
      })

      ActionCable.server.broadcast("rooms_channel_#{params[:room]}", {
        type: 'RECEIVED_DJS_CHANGED',
        data: updated_room.current_dj_order,
      })

      # tell user their song was played to trigger them to send their next song
      ActionCable.server.broadcast("user_channel_#{updated_room.current_track['user_id']}", {
        type: 'RECEIVED_PLAYED_FROM_MEMBER_QUEUE',
        data: true,
      })
    else
      ActionCable.server.broadcast("rooms_channel_#{params[:room]}", {
        type: 'RECEIVED_ERROR',
        data: 'There are no songs queued.',
      })
    end
  end

  def track_finished
    room = Room.find(params[:room])

    # Check start timestamp to make sure track actually played
    now = (Time.now.to_f * 1000).to_i
    start = room.current_track['track']['start_time']
    duration = room.current_track['track']['duration_ms']

    if (now - start >= duration)

      if play_next_track()

        p 'PLAY NEXT TRACK TRUE!!!!!!'

        updated_room = Room.find(params[:room])
        ActionCable.server.broadcast("rooms_channel_#{params[:room]}", {
          type: 'RECEIVED_STARTED_PLAYING',
          data: updated_room.current_track,
        })

        ActionCable.server.broadcast("rooms_channel_#{params[:room]}", {
          type: 'RECEIVED_DJS_CHANGED',
          data: updated_room.current_dj_order
        })

        # tell user their song was played to trigger them to send their next song
        ActionCable.server.broadcast("user_channel_#{updated_room.current_track['user_id']}", {
          type: 'RECEIVED_PLAYED_FROM_MEMBER_QUEUE',
          data: true,
        })
      else
        # no songs in queue
        ActionCable.server.broadcast("rooms_channel_#{params[:room]}", {
          type: 'RECEIVED_PLAYBACK_FINISHED',
          data: true,
        })
        ActionCable.server.broadcast("rooms_channel_#{params[:room]}", {
          type: 'RECEIVED_ROOM_READY',
          data: false,
        })
      end

    else
      ActionCable.server.broadcast("rooms_channel_#{params[:room]}", {
        type: 'RECEIVED_ERROR',
        data: 'Error syncing',
      })
    end
  end

  def update_user_queue(track)
    room = Room.find(params[:room])
    created_track = current_user.tracks.create(track: track['track'])

    # this should really only broadcast to the room host
    # I think we can broadcast on the host channel here, just need to store host userID on Room to use
    if room.update_track(created_track, current_user)
      updated_room = Room.find(params[:room])
      ActionCable.server.broadcast("rooms_channel_#{params[:room]}", {
        type: 'RECEIVED_SHARED_QUEUE_CHANGED',
        data: updated_room.queue
      })

      if room.queue.find {|e| e['track'] }
        # TO DO: add conditional so this only send if the roomready changes
        ActionCable.server.broadcast("rooms_channel_#{params[:room]}", {
          type: 'RECEIVED_ROOM_READY',
          data: true
        })
      end

    end
  end

  def unsubscribed
    room = Room.find(params[:room])
    room.remove_user(current_user)

    # remove dj
    if room.djs.include? current_user
      room.remove_dj(current_user)
    end

    ActionCable.server.broadcast("rooms_channel_#{params[:room]}", {
      type: 'RECEIVED_MEMBER_LEFT',
      data: current_user,
    })

    ActionCable.server.broadcast("rooms_channel_#{params[:room]}", {
      type: 'RECEIVED_DJS_CHANGED',
      data: room.current_dj_order,
    })

    ActionCable.server.broadcast("rooms_channel_#{params[:room]}", {
      type: 'RECEIVED_MEMBERS_CHANGED',
      data: room.members,
    })

    ActionCable.server.broadcast("rooms_channel_#{params[:room]}", {
      type: 'RECEIVED_SHARED_QUEUE_CHANGED',
      data: room.queue,
    })
  end

  private

  def play_next_track
    room = Room.find(params[:room])

    room.queue.each_with_index do |next_track, i|
      # byebug
      p 'PLAYNEXT TRACK!!!!!!'

      # find first item with non-nil track
      if next_track['track']

        room.play(next_track['track']['album'])

        room.current_track = next_track
        # record when the track started playing so we know when it should end
        room.current_track['track']['start_time'] = (Time.now.to_f * 1000).to_i

        # remove track from queue but leave placeholder
        room.queue[i] = {'user_id': current_user.id}

        # split the array into two parts with track played at the END of one
        queue_arr_a = room.queue.slice(0, i + 1) # first half 0 - i
        queue_arr_b = room.queue.slice((i + 1), room.queue.length)

        # join array back together with track played + 1 at the beginning
        room.queue = (queue_arr_b + queue_arr_a)

        # Update DJ order
        dj_i = room.current_dj_order.index{|index| index['id'] == next_track['user_id']}
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

class RoomController < ApplicationController
  def index
    rooms = Room.all
    render json: 'rooms'
  end

  def create
    room = Room.new(room_params)
    if room.save
      serialized_data = ActiveModelSerializers::Adapter::Json.new(
        RoomSerializer.new(conversation)
      ).serializable_hash
      ActionCable.server.broadcast 'rooms_channel', serialized_data
      head :ok
    end
  end

  private

  def rooms_params
    params.require(:room).permit(:name)
  end

end

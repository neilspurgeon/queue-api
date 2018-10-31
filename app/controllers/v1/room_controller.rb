class V1::RoomController < ApplicationController

  before_action :authenticate_user!

  def index
    rooms = Room.all
    render json: 'rooms'
  end

  def create
    room = Room.new(room_params)
    room.user_id = current_user.id

    if room.save
      render json: room.to_json
    else
      render :json => {'error': 'could not create room'}
    end

  end

  private

  def room_params
    params.require(:room).permit(:name)
  end

end

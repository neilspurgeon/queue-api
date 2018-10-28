class V1::RoomController < ApplicationController

  before_action :authenticate_user!

  def index
    rooms = Room.all
    render json: 'rooms'
  end

  def create
    room = Room.new(room_params)
    room.user_id = current_user.id
    p 'created new room'

    if room.save
      render :json => {'success': 'yes'}
    else
      render :json => {'success': 'no'}
    end

  end

  private

  def room_params
    params.require(:room).permit(:name)
  end

end

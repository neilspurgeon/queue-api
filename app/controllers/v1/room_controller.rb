class V1::RoomController < ApplicationController

  before_action :authenticate_user!

  def index
    rooms = Room.all
    render json: rooms.to_json
  end

  def index_top
    rooms = Room.includes(:members).where(playing: true).order("memberships_count desc").limit(10)
    render json: rooms.to_json(
      :include => :members
    )
  end

  def create
    room = Room.new(room_params)
    room.user_id = current_user.id

    if room.max_djs > 0 && room.max_djs <= 5
      if room.save
        render json: room.to_json
      else
        render :json => {'error': 'could not create room'}
      end
    else
      render :json => {'error': 'could not create room'}
    end
  end

  def show
    # Room.last.members.order('memberships.created_at DESC')
    room = Room.find(params[:id])
    render json: room.to_json(
      :include => :members.order('memberships.created_at DESC'),
      :include => :djs.order('memberships.created_at DESC')
    )
  end

  def find
    room = Room.find(params[:id])
    if room
      render json: room.to_json(
      :include => :members.order('memberships.created_at DESC'),
      :include => :djs.order('memberships.created_at DESC')
    )
    else
      return render :status => 404, :error => "Room not found", :json => {'error': 'We could not find a match for your invite code.'}
    end
  end

  private

  def room_params
    params.require(:room).permit(:name, :description, :private, :max_djs)
  end

end

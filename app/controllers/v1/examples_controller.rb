class V1::ExamplesController < ApplicationController

  before_action :authenticate_user!

  def index
    examples = Example.all.select(:id, :name, :color)
    render json: examples
  end
end

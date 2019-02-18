class ApplicationController < ActionController::API
  before_action :configure_permitted_parameters, if: :devise_controller?
  include ActionController::MimeResponds
  respond_to :json

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:update_avatar, keys: [:avatar])
  end
end

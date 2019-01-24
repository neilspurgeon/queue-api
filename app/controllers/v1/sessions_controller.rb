class V1::SessionsController < Devise::SessionsController
  def create
    super { @token = current_token }
  end

  private

  def current_token
    request.env['warden-jwt_auth.token']
  end
end
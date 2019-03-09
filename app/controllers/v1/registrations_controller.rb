class V1::RegistrationsController < Devise::RegistrationsController

  def update_avatar
    current_user.update(avatar: image_io)

    urls = {
      small: current_user.avatar[:small].url,
      medium: current_user.avatar[:medium].url,
      large: current_user.avatar[:large].url,
    }
    current_user.update(avatar_urls: urls)

    render :json => current_user
  end

  private

  def image_io
    decoded_image = Base64.decode64(params[:avatar])
    StringIO.new(decoded_image)
  end

  def sign_up_params
    params.require(:user).permit(:first_name, :last_name, :email, :password, :password_confirmation)
  end

  def account_update_params
    params.require(:user).permit(:first_name, :last_name, :email, :password, :current_password)
  end

  def update_resource(resource, params)
    resource.update_without_password(params)
  end

end

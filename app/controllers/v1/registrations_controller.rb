class V1::RegistrationsController < Devise::RegistrationsController

  private

  def sign_up_params
    print params
    params.require(:user).permit(:first_name, :last_name, :email, :password, :password_confirmation)
  end

  def account_update_params
    params.require(:user).permit(:first_name, :last_name, :email, :password, :current_password)
  end

  def update_resource(resource, params)
    resource.update_without_password(params)
  end
end

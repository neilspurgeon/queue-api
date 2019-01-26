class V1::PasswordsController < Devise::PasswordsController

  before_action :authenticate_user!

  def update
    current_password = password_update_params[:current_password]
    new_password = password_update_params[:new_password]

    if !current_user.valid_password?(current_password)
     return render :json => {'error': 'Your current password is incorrect'}
    end

    current_user.password = new_password

    if !current_user.valid?
      return render :json => {'error': 'Your new password is not valid'}
    end

    current_user.save
    return render :json => {'success': 'Your password was successfully updated'}

  end

  private

  def password_update_params
    params.require(:user).permit(:new_password, :current_password)
  end

end
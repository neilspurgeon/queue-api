if user_signed_in?
  json.user do
    json.(current_user, :id, :email, :first_name, :last_name)
    json.avatar_url current_user.avatar.attached? ? current_user.avatar.service_url : nil
  end
end
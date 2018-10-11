module ApplicationCable
  class Connection < ActionCable::Connection::Base

    identified_by :current_user

    def connect
      self.current_user = find_verified_user
      p self.current_user
    end

    private

    def find_verified_user
      p 'finding verififed user'

      # p request.headers
      header_array = request.headers[:HTTP_SEC_WEBSOCKET_PROTOCOL].split(',')
      token = header_array[header_array.length-1]
      p token.strip

      # access_token = request.params[:'access-token']
      # client_id = request.params[:client]
      # p request.params
      # verified_user = User.find_by(email: client_id)
      # p verified_user

      # if verified_user && verified_user.valid_token?(access_token, client_id)
        # p 'user is verififed'
      #   verified_user
      # else
      #   p 'user is a total reject'
      #   reject_unauthorized_connection
      # end
    end

  end
end

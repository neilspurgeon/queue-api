module ApplicationCable
  class Connection < ActionCable::Connection::Base

    identified_by :current_user

    def connect
      self.current_user = find_verified_user
    end

    private

    def find_verified_user
      begin
        header_array = request.headers[:HTTP_SEC_WEBSOCKET_PROTOCOL].split(',')
        token = header_array[header_array.length-1].strip

        decoded_token =  JWT.decode(token, Devise::JWT.config.secret)
        if (current_user = User.find((decoded_token[0])['sub']))
          current_user
        else
          reject_unauthorized_connection
        end
      rescue
        reject_unauthorized_connection
      end
    end

  end
end

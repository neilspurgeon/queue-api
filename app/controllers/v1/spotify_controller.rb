class V1::SpotifyController < ApplicationController
  include HTTParty
  base_uri  'https://accounts.spotify.com'

  # before_action :authenticate_user!

  def authenticate
    options = {
      body: {
        grant_type: 'authorization_code',
        code: params[:code],
        redirect_uri: 'queueapp://spotify-redirect',
        client_id: '3983df69e7664e75a49cab7d3408d4af',
        client_secret: Rails.application.secrets.spotify_secret
      }
    }

    @data = self.class.post('/api/token', options)
    render :json => @data
  end

  def refresh_token
    options = {
      body: {
        grant_type: 'refresh_token',
        refresh_token: params[:code],
        client_id: '3983df69e7664e75a49cab7d3408d4af',
        client_secret: Rails.application.secrets.spotify_secret
      }
    }

    @data = self.class.post('/api/token', options)
    render :json => @data
  end

end
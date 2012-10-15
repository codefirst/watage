require 'dropbox_sdk'

class WatageDropbox
  API_URL = "https://api.dropbox.com/1"
  API_CONTENT_URL = "https://api-content.dropbox.com/1"

  def WatageDropbox::authorize(params, callback_url)
    return {:action => "index"} if ENV["ACCESS_TOKEN"] and ENV["ACCESS_TOKEN_SECRET"]

    session = DropboxSession.new(ENV["APP_KEY"], ENV["APP_SECRET"])
    unless params["oauth_token"]
      session.get_request_token
      request_token = session.request_token
      ENV["REQUEST_TOKEN_KEY"] = request_token.key
      ENV["REQUEST_TOKEN_SECRET"] = request_token.secret
      {:url_for_authorize => session.get_authorize_url(callback_url)}
    else
      session.set_request_token(ENV["REQUEST_TOKEN_KEY"], ENV["REQUEST_TOKEN_SECRET"])
      ENV.delete "REQUEST_TOKEN_KEY"
      ENV.delete "REQUEST_TOKEN_SECRET"
      session.get_access_token

      access_token = session.access_token
      ENV["ACCESS_TOKEN"] = access_token.key
      ENV["ACCESS_TOKEN_SECRET"] = access_token.secret
      ENV["DROPBOX_UID"] = params["uid"]
      {}
    end
  end

  def put(file)
    session = DropboxSession.new(ENV["APP_KEY"], ENV["APP_SECRET"])
    session.set_access_token(ENV["ACCESS_TOKEN"],ENV["ACCESS_TOKEN_SECRET"])
    client = DropboxClient.new(session, :dropbox)
    filename = file.original_filename
    response = client.put_file("/public/#{filename}", file.read)
    {:source => "http://dl.dropbox.com/u/#{client.account_info["uid"]}/#{filename}"}
  end
end

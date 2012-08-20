require 'httputil'

class SkyDrive
  def initialize
    @client = Signet::OAuth2::Client.new(
                :token_credential_uri => 'https://oauth.live.com/token',
                :client_id => ENV["CLIENT_ID"],
                :client_secret => ENV["CLIENT_SECRET"],
                :refresh_token => ENV["REFRESH_TOKEN"]
              )
    @client.access_token = ENV["ACCESS_TOKEN"] unless ENV["ACCESS_TOKEN"].nil? 
  end

  def refresh_access_token
    @client.fetch_access_token!
    ENV["ACCESS_TOKEN"] = @client.access_token
  end

  def put(file)
    response = try_put(file, @client.access_token || refresh_access_token)
    response = try_put(file, refresh_access_token) unless response["source"]
    response
  end

  def try_put(file, access_token)
    rest_create = "https://apis.live.net/v5.0/me/skydrive/files?access_token=#{access_token}"
    uri = URI.parse rest_create
    JSON.parse(post_multipart(uri, file).body)
  end
end

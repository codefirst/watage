require 'httputil'

class Dropbox
  API_URL = "https://api.dropbox.com/1"
  API_CONTENT_URL = "https://api-content.dropbox.com/1"

  def initialize
    unless ENV["ACCESS_TOKEN"] and ENV["ACCESS_TOKEN_SECRET"]
      response = https_post(URI.parse("#{API_URL}/oauth/request_token"),
                      "Authorization" => "OAuth oauth_version=\"1.0\", oauth_signature_method=\"PLAINTEXT\", oauth_consumer_key=\"#{ENV["APP_KEY"]}\", oauth_signature=\"#{ENV["APP_SECRET"]}&\"")
      response.body.match /oauth_token_secret=(.+)&oauth_token=(.+)/
      request_token = $2
      request_token_secret = $1
      puts "ACCESS: https://www.dropbox.com/1/oauth/authorize?oauth_token=#{request_token}&oauth_callback=http://asakusasatellite.heroku.com"

      sleep 15
      response = https_post(URI.parse("#{API_URL}/oauth/access_token"),
                      "Authorization" => "OAuth oauth_version=\"1.0\", oauth_signature_method=\"PLAINTEXT\", oauth_consumer_key=\"#{ENV["APP_KEY"]}\", oauth_token=\"#{request_token}\", oauth_signature=\"#{ENV["APP_SECRET"]}&#{request_token_secret}\"")
      response.body.match /oauth_token_secret=(.+)&oauth_token=(.+)&uid=(.+)/
      access_token = $2
      access_token_secret = $1
      uid = $3

      ENV["ACCESS_TOKEN"] = access_token
      ENV["ACCESS_TOKEN_SECRET"] = access_token_secret
      ENV["DROPBOX_UID"] = uid
    end
  end

  def put(file)
    resource = URI::parse "#{API_CONTENT_URL}/files_put/dropbox/public/#{file.original_filename}"
    response = https_put(resource, file, "Authorization" => "OAuth oauth_version=\"1.0\", oauth_signature_method=\"PLAINTEXT\", oauth_consumer_key=\"#{ENV["APP_KEY"]}\", oauth_token=\"#{ENV["ACCESS_TOKEN"]}, oauth_signature=\"#{ENV["APP_SECRET"]}&#{ENV["ACCESS_TOKEN_SECRET"]}\"")

    {:source => "http://dl.dropbox.com/u/#{ENV["DROPBOX_UID"]}/#{file.original_filename}"}
  end
end

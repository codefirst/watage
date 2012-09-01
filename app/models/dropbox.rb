require 'httputil'

class Dropbox
  include HTTPUtil

  API_URL = "https://api.dropbox.com/1"
  API_CONTENT_URL = "https://api-content.dropbox.com/1"

  def Dropbox::authorize(params, callback_url)
    return {:action => "index"} if ENV["ACCESS_TOKEN"] and ENV["ACCESS_TOKEN_SECRET"] and ENV["DROPBOX_UID"]

    unless params["oauth_token"]
      response = https_post(URI::parse("https://api.dropbox.com/1/oauth/request_token"),
                            "Authorization" => "OAuth oauth_version=\"1.0\", oauth_signature_method=\"PLAINTEXT\", oauth_consumer_key=\"#{ENV["APP_KEY"]}\", oauth_signature=\"#{ENV["APP_SECRET"]}&\"")
      response.body.match /oauth_token_secret=(.+)&oauth_token=(.+)/
      ENV["request_token"]        = $2
      ENV["request_token_secret"] = $1

      {:url_for_authorize => "https://www.dropbox.com/1/oauth/authorize?oauth_token=#{ENV["request_token"]}&oauth_callback=#{callback_url}"}
    else
      response = https_post(URI.parse("https://api.dropbox.com/1/oauth/access_token"),
                            "Authorization" => "OAuth oauth_version=\"1.0\", oauth_signature_method=\"PLAINTEXT\", oauth_consumer_key=\"#{ENV["APP_KEY"]}\", oauth_token=\"#{ENV["request_token"]}\", oauth_signature=\"#{ENV["APP_SECRET"]}&#{ENV["request_token_secret"]}\"")
      response.body.match /oauth_token_secret=(.+)&oauth_token=(.+)&uid=(.+)/
      ENV["ACCESS_TOKEN"]        = $2
      ENV["ACCESS_TOKEN_SECRET"] = $1
      ENV["DROPBOX_UID"]         = $3
      ENV.delete "request_token"
      ENV.delete "request_token_secret"
    end
  end

  def put(file)
    resource = URI::parse "#{API_CONTENT_URL}/files_put/dropbox/public/#{file.original_filename}"
    response = https_put(resource, file, "Authorization" => "OAuth oauth_version=\"1.0\", oauth_signature_method=\"PLAINTEXT\", oauth_consumer_key=\"#{ENV["APP_KEY"]}\", oauth_token=\"#{ENV["ACCESS_TOKEN"]}, oauth_signature=\"#{ENV["APP_SECRET"]}&#{ENV["ACCESS_TOKEN_SECRET"]}\"")
    {:source => "http://dl.dropbox.com/u/#{ENV["DROPBOX_UID"]}/#{file.original_filename}"}
  end
end

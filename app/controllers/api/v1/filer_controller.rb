# -*- coding: utf-8 -*-
require 'net/https'
require 'uri'
require 'signet/oauth_2/client'

module Api
  module V1
    class FilerController < ApplicationController
      skip_before_filter :verify_authenticity_token ,:only=>[:put]

      def put
        skydrive = SkyDrive.new

        response = skydrive.put params[:upload][:file]
        send_data(response.to_json, :type => 'text/json', :disposition => 'inline')
      end
    end

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

      def post_multipart(uri, file, content_type=file.content_type, boundary="A300x")
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        http.start do
          request = Net::HTTP::Post.new(uri.path + "?" + (uri.query || ""))
          request["user-agent"] = "Ruby/#{RUBY_VERSION} MyHttpClient"
          request.set_content_type "multipart/form-data; boundary=#{boundary}"
          body = "--#{boundary}\r\n"
          body += "Content-Disposition: form-data; name=\"file\"; filename=\"#{file.original_filename}\"\r\n"
          body += "Content-Type: #{content_type}\r\n"
          body += "\r\n"
          body += "#{file.read}\r\n"
          body += "\r\n"
          body += "--#{boundary}--\r\n"
          request.body = body
          http.request request
        end
      end
    end
  end
end

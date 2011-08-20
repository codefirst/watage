# -*- coding: utf-8 -*-
require 'net/https'
require 'uri'
require 'signet/oauth_2/client'

module Api
  module V1
    class FilerController < ApplicationController
      skip_before_filter :verify_authenticity_token ,:only=>[:add]

      def add
        skydrive = SkyDrive.new

        file = params[:upload][:file]
        resp = skydrive.put("", file)
        send_data(resp, :type => 'text/json', :disposition => 'inline')
      end

      def put
      end
    end

    class SkyDrive
      # todo: take these parameters from environment or DB
      CLIENT_ID = ''
      CLIENT_SECRET = ''
      REFRESH_TOKEN = ''

      def initialize
        @client = Signet::OAuth2::Client.new(
          :token_credential_uri => 'https://oauth.live.com/token',
          :client_id => CLIENT_ID,
          :client_secret => CLIENT_SECRET,
          :refresh_token => REFRESH_TOKEN
        )
      end

      def get_access_token
        @client.fetch_access_token!
        @client.access_token
      end

      def put(key, file)
        access_token = get_access_token

        rest_create = "https://apis.live.net/v5.0/me/skydrive/files?access_token=#{access_token}"

        uri = URI.parse rest_create
        res = post_multipart(uri, file)
        res.body
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

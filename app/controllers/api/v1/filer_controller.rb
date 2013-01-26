# -*- coding: utf-8 -*-
require 'uuidtools'

module Api
  module V1
    class FilerController < ApplicationController
      skip_before_filter :verify_authenticity_token ,:only=>[:put]

      def put
        file                = params[:upload][:file] rescue nil
        access_token        = params[:access_token]
        access_token_secret = params[:access_token_secret]

        if file.nil? or access_token.nil? or access_token_secret.nil?
          send_data({:error => "blank parameter(s)"}.to_json, :type => 'text/json', :disposition => 'inline')
          return
        end

        uuid = UUIDTools::UUID.random_create.to_s
        file.original_filename = URI::encode "#{uuid}_#{file.original_filename}"
        
        response = DropboxAccount::put(file, access_token, access_token_secret)
        send_data(response.to_json, :type => 'text/json', :disposition => 'inline')
      end
    end
  end
end

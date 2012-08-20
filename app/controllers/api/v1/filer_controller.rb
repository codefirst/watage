# -*- coding: utf-8 -*-
require 'uuidtools'

module Api
  module V1
    class FilerController < ApplicationController
      skip_before_filter :verify_authenticity_token ,:only=>[:put]

      def put
        file = params[:upload][:file]
        uuid = UUIDTools::UUID.random_create.to_s
        file.original_filename = URI::encode "#{uuid}_#{file.original_filename}"

        storage = Dropbox.new
        response = storage.put file
        send_data(response.to_json, :type => 'text/json', :disposition => 'inline')
      end
    end
  end
end

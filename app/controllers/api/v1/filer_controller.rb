module Api
  module V1
    class FilerController < ApplicationController
      skip_before_filter :verify_authenticity_token, only: [:put]

      def put
        file                = params[:upload][:file] rescue nil
        access_token        = params[:access_token]
        access_token_secret = params[:access_token_secret]

        if file.nil? or access_token.nil? or access_token_secret.nil?
          render json: {error: 'blank parameter(s)'}, status: :internal_server_error
          return
        end

        account = DropboxAccount.find_by_watage_token(access_token, access_token_secret)
        if account.nil?
          render json: {error: 'invalid access_token or access_token_secret'}, status: :internal_server_error
          return
        end

        file.original_filename = URI::encode("#{uuid}_#{file.original_filename}")
        response = account.put(file)
        render json: response
      end

    end
  end
end

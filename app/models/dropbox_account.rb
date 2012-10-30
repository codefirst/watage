require 'dropbox_sdk'
require 'uuidtools'

class DropboxAccount
  include Mongoid::Document
  include Mongoid::Timestamps

  field :app_key
  field :app_secret
  field :request_token_key
  field :request_token_secret
  field :access_token
  field :access_token_secret
  field :dropbox_uid
  field :watage_temporary_key
  field :watage_access_token
  field :watage_access_token_secret

  def DropboxAccount::authorize(params, callback_url)
    app_key    = params[:app][:key]
    app_secret = params[:app][:secret]

    account = DropboxAccount.find(:first, :conditions => {
                                    :app_key                    => app_key,
                                    :app_secret                 => app_secret,
                                    :access_token.exists        => true,
                                    :access_token_secret.exists => true})
    return account if account

    account = DropboxAccount.new(:app_key => app_key, :app_secret => app_secret)
    session = DropboxSession.new(app_key, app_secret)
    session.get_request_token
    account[:request_token_key]    = session.request_token.key
    account[:request_token_secret] = session.request_token.secret
    account[:watage_temporary_key] = UUIDTools::UUID.random_create.to_s
    account.save

    session.get_authorize_url(callback_url+"/"+account[:watage_temporary_key])
  end

  def DropboxAccount::store_token(params)
    account = DropboxAccount.find(:first, :conditions => {:watage_temporary_key => params[:tmp_key]})
    session = DropboxSession.new(account[:app_key], account[:app_secret])
    session.set_request_token(account[:request_token_key], account[:request_token_secret])
    session.get_access_token
    account[:access_token]         = session.access_token.key
    account[:access_token_secret]  = session.access_token.secret
    account[:dropbox_uid]          = params[:uid]
    account[:watage_temporary_key] = nil
    account[:watage_access_token]        = UUIDTools::UUID.random_create.to_s
    account[:watage_access_token_secret] = UUIDTools::UUID.random_create.to_s
    account.save
    account
  end

  def DropboxAccount::put(file, token, secret)
    account = DropboxAccount.find(:first, :conditions => {
                                    :watage_access_token        => token,
                                    :watage_access_token_secret => secret})
    return if account.nil?
    
    session = DropboxSession.new(account[:app_key], account[:app_secret])
    session.set_access_token(account[:access_token], account[:access_token_secret])
    client = DropboxClient.new(session, :dropbox)
    filename = file.original_filename
    response = client.put_file("/public/#{URI::unescape filename}", file.read)
    {:source => "http://dl.dropbox.com/u/#{client.account_info["uid"]}/#{filename}"}
  end
end

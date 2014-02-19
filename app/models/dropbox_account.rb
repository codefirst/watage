class DropboxAccount
  include Mongoid::Document
  include Mongoid::Timestamps

  field :app_key
  field :app_secret
  field :access_token
  field :access_token_secret
  field :dropbox_uid

  field :watage_access_token
  field :watage_access_token_secret

  def self.find_by_watage_token(watage_access_token, watage_access_token_secret)
    self.where({watage_access_token: watage_access_token, watage_access_token_secret: watage_access_token_secret}).first
  end

  def self.find_by_dropbox_uid(app_key, app_secret, dropbox_uid)
    self.where({app_key: app_key, app_secret: app_secret, dropbox_uid: dropbox_uid}).first
  end

  def put(file)
    session = DropboxSession.new(app_key, app_secret)
    session.set_access_token(access_token, access_token_secret)
    client = DropboxClient.new(session, :dropbox)
    filename = file.original_filename
    uid = client.account_info["uid"]
    client.put_file("/public/#{URI::unescape filename}", file.read)
    {source: "https://dl.dropboxusercontent.com/u/#{uid}/#{filename}"}
  end
end

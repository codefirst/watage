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
    client = DropboxApi::Client.new(access_token)
    path = "/#{uuid}-#{URI::unescape file.original_filename}"
    client.upload(path, file.read)
    link = client.create_shared_link_with_settings(path)

    {
      source: 'https://dl.dropboxusercontent.com' + URI.parse(link.url).path
    }
  end

  def uuid
    UUIDTools::UUID.random_create.to_s
  end
end

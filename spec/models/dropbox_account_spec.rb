require "spec_helper"

describe DropboxAccount do
  describe 'find_by_watage_token' do
    before {
      @account = DropboxAccount.new(watage_access_token: 'WATAGE_ACCESS_TOKEN',
                                    watage_access_token_secret: 'WATAGE_ACCESS_TOKEN_SECRET')
      @account.save
     }
    subject { DropboxAccount.find_by_watage_token('WATAGE_ACCESS_TOKEN', 'WATAGE_ACCESS_TOKEN_SECRET') }
    its(:watage_access_token) { should eq 'WATAGE_ACCESS_TOKEN' }
    its(:watage_access_token_secret) { should eq 'WATAGE_ACCESS_TOKEN_SECRET' }
    after { @account.delete }
  end
  describe 'find_by_dropbox_uid' do
    before {
      @account = DropboxAccount.new(app_key: 'APP_KEY',
                                    app_secret: 'APP_SECRET',
                                    dropbox_uid: 'DROPBOX_UID')
      @account.save
     }
    subject { DropboxAccount.find_by_dropbox_uid('APP_KEY', 'APP_SECRET', 'DROPBOX_UID') }
    its(:app_key) { should eq 'APP_KEY' }
    its(:app_secret) { should eq 'APP_SECRET' }
    its(:dropbox_uid) { should eq 'DROPBOX_UID' }
    after { @account.delete }
  end
end

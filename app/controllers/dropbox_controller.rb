class DropboxController < ApplicationController
  def authorize
    attr = params[:dropbox_account].permit(:app_key, :app_secret)
    account = DropboxAccount.new(attr)
    db_session = DropboxApi::Authenticator.new(account.app_key, account.app_secret)
    set_session(account.app_key, account.app_secret)
    redirect_to db_session.authorize_url(redirect_uri: dropbox_callback_url)
  end

  def callback
    @account = DropboxAccount.find_by_dropbox_uid(session[:app_key], session[:app_secret], params[:uid])
    if @account.nil?
      db_session = DropboxApi::Authenticator.new(session[:app_key], session[:app_secret])
      begin
        token = db_session.get_token(params[:code], redirect_uri: dropbox_callback_url)
      rescue => e
        redirect_to root_path, alert: e.message
        return
      end
      @account = DropboxAccount.new(
        app_key:                    session[:app_key],
        app_secret:                 session[:app_secret],
        access_token:               token.token,
        access_token_secret:        token.refresh_token,
        dropbox_uid:                params[:uid],
        watage_access_token:        uuid,
        watage_access_token_secret: uuid
      )
      @account.save
    end
    flash[:notice] = 'Successfully logged.'
    set_session(nil, nil)
  end

  def destroy
    attr = params[:dropbox_account].permit(:watage_access_token, :watage_access_token_secret)
    target = DropboxAccount.new(attr)

    account = DropboxAccount.find_by_watage_token(target.watage_access_token, target.watage_access_token_secret)
    if account
      account.delete
      redirect_to root_path, :notice => "Successfully deleted."
      return
    end
    redirect_to root_path, :alert => "Delete failed."
  end

  private
  def set_session(app_key, app_secret)
    session[:app_key] = app_key
    session[:app_secret] = app_secret
  end
end

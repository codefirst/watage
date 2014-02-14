class DropboxController < ApplicationController
  def authorize
    attr = params[:dropbox_account].permit(:app_key, :app_secret)
    account = DropboxAccount.new(attr)

    db_session = DropboxSession.new(account.app_key, account.app_secret)
    db_session.get_request_token
    set_session(db_session.serialize, account.app_key, account.app_secret)
    redirect_to db_session.get_authorize_url(dropbox_callback_url)
  end

  def callback
    @account = DropboxAccount.find_by_dropbox_uid(session[:app_key], session[:app_secret], params[:uid])
    if @account.nil?
      db_session = DropboxSession.deserialize(session[:dropbox_session])
      db_session.get_access_token
      @account = DropboxAccount.new(
        app_key:                    session[:app_key],
        app_secret:                 session[:app_secret],
        access_token:               db_session.access_token.key,
        access_token_secret:        db_session.access_token.secret,
        dropbox_uid:                params[:uid],
        watage_access_token:        uuid,
        watage_access_token_secret: uuid
      )
      @account.save
    end
    flash[:notice] = 'Successfully logged.'
    set_session(nil, nil, nil)
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
  def set_session(dropbox_session, app_key, app_secret)
    session[:dropbox_session] = dropbox_session
    session[:app_key] = app_key
    session[:app_secret] = app_secret
  end
end

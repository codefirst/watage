class ApplicationController < ActionController::Base
  protect_from_forgery

  def index
  end

  def authorize
    if params[:tmp_key].nil?
      resp = DropboxAccount::authorize(params, url_for(:action => 'authorize'))
      case resp
      when String
        redirect_to resp
      else
        @account = resp
        render :action => 'authorize'
      end
    else
      @account = DropboxAccount::store_token(params)
      render :action => 'authorize'
    end
  end

  def remove
    DropboxAccount::remove(params)
    redirect_to '/'
  end
end

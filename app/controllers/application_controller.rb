class ApplicationController < ActionController::Base
  protect_from_forgery

  def index
  end

  def manual
  end

  def authorize
    if params[:tmp_key].nil?
      resp = DropboxAccount::authorize(params, url_for(:action => 'authorize'))
      case resp.keys
      when [:redirect]
        redirect_to resp.values.first
      when [:authorized]
        @account = resp.values.first
        render :action => 'authorize'
      when [:error]
        @error = resp.values.first
        render :action => 'index'
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

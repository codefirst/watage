class ApplicationController < ActionController::Base
  protect_from_forgery

  def index
  end

  def authorize
    # todo: switch based on storage kind
    resp = WatageDropbox::authorize(params, url_for(:action => 'authorize'))
    if resp[:url_for_authorize]
      redirect_to resp[:url_for_authorize]
    else
      render :action => 'authorize'
    end
  end
end

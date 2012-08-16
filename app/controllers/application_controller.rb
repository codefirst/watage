require 'uri'
require 'httputil'

class ApplicationController < ActionController::Base
  include HTTPUtil
  protect_from_forgery

  def index
  end

  def authorize
    # todo: switch based on storage kind
    redirect_to(Dropbox.new.authorize(params, url_for(:action => 'authorize')))
  end
end

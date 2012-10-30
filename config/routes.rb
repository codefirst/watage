# -*- coding: utf-8 -*-
Watage::Application.routes.draw do
  get '/',  :controller => 'application', :action => 'index'
  get '/authorize', :controller => 'application', :action => 'index'
  post '/authorize', :controller => 'application', :action => 'authorize'
  get '/authorize/:tmp_key', :controller => 'application', :action => 'store_token'

  namespace(:api) do
    namespace(:v1) do
      post  'put', :controller => 'filer', :action => 'put'
    end
  end

  root :to => 'application#index'
end

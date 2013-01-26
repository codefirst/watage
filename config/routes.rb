# -*- coding: utf-8 -*-
Watage::Application.routes.draw do
  get  '/',  :controller => 'application', :action => 'index'
  get  '/manual', :controller => 'application', :action => 'manual'
  get  '/authorize' => redirect('/')
  post '/authorize', :controller => 'application', :action => 'authorize'
  get  '/authorize/:tmp_key', :controller => 'application', :action => 'authorize'
  post '/remove', :controller => 'application', :action => 'remove'

  namespace(:api) do
    namespace(:v1) do
      post  'put', :controller => 'filer', :action => 'put'
    end
  end

  root :to => 'application#index'
end

# -*- coding: utf-8 -*-
Watage::Application.routes.draw do
  get '/',  :controller => 'application', :action => 'index'
  post '/', :controller => 'api/v1/filer', :action => 'put'

  namespace(:api) do
    namespace(:v1) do
      post  'put', :controller => 'filer', :action => 'put'
    end
  end
end

# -*- coding: utf-8 -*-
Watage::Application.routes.draw do
  get '/',  :controller => 'application', :action => 'index'
  post '/', :controller => 'api/v1/filer', :action => 'add'

  namespace(:api) do
    namespace(:v1) do
      post  'add', :controller => 'filer', :action => 'add'
    end
  end
end

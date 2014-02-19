Watage::Application.routes.draw do
  get '/', to: 'top#index'
  get '/manual', to: 'top#manual'

  post 'dropbox/authorize', as: 'dropbox_authorize'
  get 'dropbox/callback', as: 'dropbox_callback'
  delete 'dropbox/destroy', as: 'dropbox_destroy'

  namespace(:api) do
    namespace(:v1) do
      post 'put', to: 'filer#put'
    end
  end

  root to: 'application#index'
end

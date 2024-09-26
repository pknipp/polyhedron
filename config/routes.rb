Rails.application.routes.draw do
  resources :widgets

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  get '/', to: 'welcome#index'
  get '/:shape', to: 'welcome#edges'
  get '/points/:shape', to: 'welcome#points'

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end

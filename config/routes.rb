Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  resources :reunions do
    get :with_soft_delete, on: :collection
    post :publish, on: :member
  end
end

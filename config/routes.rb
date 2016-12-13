Rails.application.routes.draw do
  resources :lists
  get 'contacts/index'
  get 'lists/index'
  get 'contacts/download'
  get 'contacts/create_list'
  get 'contacts/search'
  get 'contacts/process_file'
  
  resources :contacts do
    collection { post :process_file }
  end
  resources :contacts do
    collection { post :save_list }
  end
  resources :contacts do
    collection { post :load_to_drive }
  end
  
  resources :contacts do
    collection { post :create_list }
  end
  resources :contacts do
    collection { get :search }
  end
 
  root to: "contacts#index"
end
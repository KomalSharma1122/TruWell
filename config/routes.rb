Rails.application.routes.draw do

  mount ActionCable.server => '/cable'


  post '/users/sign_up', to: "users#sign_up"

  post '/users/log_in', to: "users#log_in"

  patch '/users/log_out', to: "users#log_out"

  get "/users/:id", to: "users#show"

  get "/doctor/:id", to: "users#show_doctor"

  patch '/users/:id', to: "users#update"

  get '/doctor_details', to: "users#doctor_details"

  get "/users", to: "users#index"

  post '/doctor_availabilities_create', to: "doctor_availabilities#create"

  get '/available_dates/:user_id', to: "doctor_availabilities#show"

  get '/available_slots', to: "doctor_availabilities#available_slots"

  post '/appointments', to: 'appointments#create'

  get '/appointments', to: 'appointments#index'

  patch '/appointments/:id', to: "appointments#update"

  post '/prescriptions', to: 'prescriptions#create'

  get '/prescriptions', to: 'prescriptions#index'

  patch '/prescriptions/:id', to: 'prescriptions#update'

  delete '/prescriptions/:id', to: 'prescriptions#destroy'

  post '/medical_histories', to: 'medical_histories#create'

  get '/medical_histories', to: 'medical_histories#index'

  delete "/users/:id", to: "users#destroy"

  post "/chat_rooms", to: "chat_rooms#create"

  get "chat_rooms", to: "chat_rooms#index"

  get "new_chats", to: "chat_rooms#new_chats"

  get "favourite_chats", to: "chat_rooms#favourite_chats"

  patch "add_to_favourites/:id", to: "chat_rooms#add_to_favourites"

  delete "delete_chat/:id", to: "chat_rooms#delete_chat"

  post "new_message", to: "messages#create"

  get "messages/:chat_room_id", to: "messages#index"

  delete "delete_message/:id", to: "messages#delete"




  # get "chat_rooms/:id", to: "Chat_room#"

end

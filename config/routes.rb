Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"

  get "videos", to: "videos#extract_coordinates"
  post "videos", to: "videos#upload"
end

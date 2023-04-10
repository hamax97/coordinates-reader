Rails.application.routes.draw do
  get 'images/show'
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  root "videos#extract_coordinates"

  get "videos", to: "videos#extract_coordinates"
  post "videos", to: "videos#upload"
  get "videos/:id", to: "videos#show", as: :video

  get "images/:id", to: "images#show", as: :image
end

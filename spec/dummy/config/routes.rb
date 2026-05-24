# frozen_string_literal: true

Rails.application.routes.draw do
  mount RailsAutodoc::Engine => "/api-docs"

  namespace :api do
    namespace :v1 do
      resources :users, only: %i[index show create update destroy]
    end
  end
end

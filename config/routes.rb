# frozen_string_literal: true

RailsAutodoc::Engine.routes.draw do
  get "/", to: "spec#ui"
  get "/spec.json", to: "spec#show"
end

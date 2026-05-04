require 'api_constraints'
require 'resque/server'
require 'resque/scheduler'
require 'resque/scheduler/server'

Rails.application.routes.draw do

  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'
  authenticated :user, ->(u) { u.role_id == "editor"} do
    root to: "properties/editors#editor_show", as: :editor_root
  end

  authenticated :user, ->(u) { u.role_id == "agent" || u.role_id == "manager" || u.role_id == "admin" } do
    root to: "properties/agents#agent_index", as: :agent_root
  end

  unauthenticated :user do
    root "pages#home"
  end

  devise_for :users,
            controllers: {
              sessions: 'users/sessions'
            },
            path: '',
            path_names: {sign_in: 'login', sign_out: 'logout', show: 'profile'}

  devise_scope :user do
    get '/my_profile', to: 'users/registrations#my_profile', as: :my_profile
    get '/edit_profile', to: 'users/registrations#edit_profile', as: :edit_profile
    get '/change_password', to: 'users/registrations#change_password', as: :change_password
    get '/my_profile_loadmore', to: 'users/registrations#my_profile_loadmore'
    patch '/', to: 'devise/registrations#update', as: :user_registration
    put '/', to: 'devise/registrations#update'
  end

  resources :users, only: [:show, :edit], param: :nickname do
    member do
      post 'edit' => "users#edit"
    end
  end
  get 'users_loadmore' => 'users#users_loadmore'
  get 'manage_users' => 'users#index'


  resources :areas, only: [:show], param: :slug
  resources :locations, only: [:new, :create, :index, :show], param: :slug
  resources :properties do
    member do
      post '/owner_details' => "properties#owner_details"
      post '/edit' => "properties#edit"
      post '/contact_from_property' => "leads#new_from_property"
      post '/stop_calling' => 'properties/editors#stop_calling'
      post '/not_answering' => 'properties/editors#not_answering'
      post '/editor_done' => 'properties/editors#editor_done'
      get '/editor_edit_property' => 'properties/editors#editor_edit_property'
      get '/property_carousel' => 'properties#delete_photo_attachment'
      post '/editor_select_photos' => 'properties/editors#editor_select_photos'
      delete :delete_photo_attachment, to: 'properties#delete_photo_attachment'
      get 'download_all_photos' => 'properties#download_all_photos'
      get 'download_all_photos_without_watermark' => 'properties#download_all_photos_without_watermark'
      get 'show_leads' => 'properties#show_leads'
      post '/create_lead_property' => 'properties#create_lead_property'
      delete :delete_lead_property, to: 'properties#delete_lead_property'

    end
    collection do
      get :search, to: 'properties#index'
      get :loadmore, to: 'properties#loadmore'
      get :search_selector
      get :editor, to: 'properties/editors#editor_show'
      post '/editors/editor_add_photos' => "properties/editors#editor_add_photos"
      get '/editors/editor_add_photos' => "properties/editors#editor_add_photos"
      get "/edit_field", to: "properties/editors#editor_edit_field"
      post '/editors/editor_update' => "properties/editors#editor_update"
      patch '/editors/editor_update' => "properties/editors#editor_update"
      put '/editors/editor_update' => "properties/editors#editor_update"
      post '/editors/editor_update_availability_date' => "properties/editors#editor_update_availability_date"
      get '/editors/editor_edit_owner' => 'properties/editors#editor_edit_owner'
      get '/editors/editor_edit_other_property' => 'properties/editors#editor_edit_other_property', as: 'editor_edit_other_property'
      post '/editors/editor_update_other_property' => "properties/editors#editor_update_other_property"
      get 'editors/editor_new_property' => 'properties/editors#editor_new_property'
      post 'editors/editor_create_property' => 'properties/editors#editor_create_property', as: 'editor_create_property'
      patch '/editors/update_editor_all' => 'properties/editors#update_editor_all'
      put '/editors/update_editor_all' => 'properties/editors#update_editor_all'
      get 'agents/agent_search', to: 'properties/agents#agent_index'
      get 'agents/agent_loadmore', to: 'properties/agents#agent_loadmore'
      patch '/editors/editor_all_add_3_months' => 'properties/editors#editor_all_add_3_months'
      put '/editors/editor_all_add_3_months' => 'properties/editors#editor_all_add_3_months'
      patch '/editors/editor_all_add_6_months' => 'properties/editors#editor_all_add_6_months'
      put '/editors/editor_all_add_6_months' => 'properties/editors#editor_all_add_6_months'

    end
  end
  resources :owners do
    get :autocomplete_owner_phone_number, :on => :collection
    get :autocomplete_owner_name, :on => :collection
    get :autocomplete_owner_additional_info, :on => :collection
    member do
      patch :editor_update
      put :editor_update
    end
  end
  resources :leads do
    resources :lead_areas, only: [:create, :destroy]
    resources :lead_properties, only: [:create, :destroy]
    resources :lead_locations, only: [:create, :destroy]
    collection do
      post '/create_from_property' => "leads#create_from_property"
      get :loadmore, to: 'leads#loadmore'
      get :loadmore_my_leads, to: 'leads#loadmore_my_leads'
      get '/new_from_agent' => "leads#new_from_agent"
      post '/create_from_agent' => "leads#create_from_agent"
      get "/edit_field", to: "leads#edit_field"
      post '/update_field' => "leads#update_field"
      patch '/update_field' => "leads#update_field"
      put '/update_field' => "leads#update_field"
    end
    member do
      get '/step1' => 'leads#show_step1'
      get '/step2' => 'leads#show_step2'
      get '/step3' => 'leads#show_step3'
      get '/step4' => 'leads#show_step4'
      get '/step5' => 'leads#show_step5'

      get '/search_properties' => 'leads#search_properties'

      patch '/phase_completed' => 'leads#phase_completed'
      put '/phase_completed' => 'leads#phase_completed'

      get '/new_lead_phase1' => 'leads#new_lead_phase1'
      get '/new_lead_phase3' => 'leads#new_lead_phase3'
      get '/new_lead_phase4' => 'leads#new_lead_phase4'
      get '/new_lead_phase5' => 'leads#new_lead_phase5'

      patch '/create_lead_phase' => 'leads#create_lead_phase'
      put '/create_lead_phase' => 'leads#create_lead_phase'

      get '/edit_lead_phase' => 'leads#edit_lead_phase'

      patch '/update_lead_phase' => 'leads#update_lead_phase'
      put '/update_lead_phase' => 'leads#update_lead_phase'
      delete :delete_lead_phase, to: 'leads#delete_lead_phase'

      patch '/create_lead_location' => 'leads#create_lead_location'
      put '/create_lead_location' => 'leads#create_lead_location'
      delete :delete_lead_location, to: 'leads#delete_lead_location'

      patch '/create_lead_property' => 'leads#create_lead_property'
      put '/create_lead_property' => 'leads#create_lead_property'
      patch '/update_lead_property' => 'leads#update_lead_property'
      put '/update_lead_property' => 'leads#update_lead_property'
      delete :delete_lead_property, to: 'leads#delete_lead_property'
      get '/create_lead_property' => 'leads#search_properties' #Makes Property Sorting on Step 2 work
      get '/delete_lead_property' => 'leads#search_properties' #Makes Property Sorting on Step 2 work

      get '/add_property_address' => 'leads#add_property_address'
      patch '/property_address' => 'leads#property_address'
      put '/property_address' => 'leads#property_address'

      get '/add_meeting_point' => 'leads#add_meeting_point'
      patch '/meeting_point' => 'leads#meeting_point'
      put '/meeting_point' => 'leads#meeting_point'

      get '/add_proposal_amount' => 'leads#add_proposal_amount'
      patch '/proposal_amount' => 'leads#proposal_amount'
      put '/proposal_amount' => 'leads#proposal_amount'

      get '/add_visit_date' => 'leads#add_visit_date'
      patch '/visit_date' => 'leads#visit_date'
      put '/visit_date' => 'leads#visit_date'

      get '/edit_deposit_info' => 'leads#edit_deposit_info'
      patch '/update_deposit_info' => 'leads#update_deposit_info'
      put '/update_deposit_info' => 'leads#update_deposit_info'

      get '/edit_contract_info' => 'leads#edit_contract_info'
      patch '/update_contract_info' => 'leads#update_contract_info'
      put '/update_contract_info' => 'leads#update_contract_info'

      get '/create_reason_for_dropping' => 'leads#create_reason_for_dropping'
      patch '/drop_lead' => 'leads#drop_lead'
      put '/drop_lead' => 'leads#drop_lead'

    end
  end

  resources :candidates, only: [:new, :create, :index, :show]

  get '/contact' => "leads#new"
  get '/careers' => "candidates#new"
  get '/privacy-policy' => "pages#privacy_policy"
  get '/terms-conditions' => "pages#terms_conditions"
  get '/my_updates' => 'properties#my_updates'
  get '/my_leads' => 'leads#my_leads'

  resources :conversations, only: [:index, :create] do
    resources :messages, only: [:index, :create]
  end

  get '/notification_settings' => 'settings#edit'
  post '/notification_settings' => 'settings#update'
  get '/notifications' => 'notifications#index'
  get '/add_to_bookmarks' => 'bookmarks#create'
  get '/my_bookmarks' => 'properties#my_bookmarks'
  post '/remind_to_call' => 'owners#remind_to_call'

  mount ActionCable.server => '/cable'
  authenticate :user do
    mount Resque::Server, at: '/jobs'
  end
  namespace :api, defaults: {format: :json} do
    scope module: :v1, constraints: ApiConstraints.new(version: 1, default: true) do
      resources :properties, only: [:create, :index, :show]
      # resources :sessions, only: [:create, :destroy]
      post 'sessions' =>  'sessions#create'
      delete 'sessions' => 'sessions#destroy'
    end
  end

end

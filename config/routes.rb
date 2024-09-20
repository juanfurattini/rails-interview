Rails.application.routes.draw do
  namespace :api do
    resources :todo_lists, only: %i[index], path: :todolists do
      put :complete_tasks

      resources :todo_list_items, only: %i[index create update destroy], path: :todos do
        put :complete_task
      end
    end
  end

  resources :todo_lists, only: %i[index new], path: :todolists
end

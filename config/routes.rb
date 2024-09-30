Rails.application.routes.draw do
  root to: 'todo_lists#index'

  namespace :api do
    resources :todo_lists, only: %i[index create update destroy], path: :todolists do
      put :complete_tasks

      resources :todo_list_items, only: %i[index create update destroy], path: :todos do
        put :complete_task
      end
    end
  end

  resources :todo_lists, path: :todolists do
    put :complete_tasks

    resources :todo_list_items, path: :todos do
      put :complete_task
    end
  end
end

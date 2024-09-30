require 'rails_helper'

describe Api::TodoListsController do
  render_views

  describe 'GET index' do
    let!(:todo_list) { TodoList.create(name: 'Setup RoR project') }

    context 'when format is HTML' do
      it 'raises a routing error' do
        expect {
          get :index
        }.to raise_error(ActionController::RoutingError, 'Not supported format')
      end
    end

    context 'when format is JSON' do
      it 'returns a success code' do
        get :index, format: :json

        expect(response.status).to eq(200)
      end

      it 'includes todo list records' do
        get :index, format: :json

        todo_lists = JSON.parse(response.body)

        aggregate_failures 'includes the id and name' do
          expect(todo_lists.count).to eq(1)
          expect(todo_lists[0].keys).to match_array(['id', 'name'])
          expect(todo_lists[0]['id']).to eq(todo_list.id)
          expect(todo_lists[0]['name']).to eq(todo_list.name)
        end
      end
    end
  end

  describe 'POST create' do
    context 'when list can be created' do
      let(:params) { { name: 'Setup RoR project' } }

      it 'returns a success code' do
        post :create, params: params

        expect(response.status).to eq(201)
      end

      it 'creates a new list' do
        expect { post :create, params: params }.to change{TodoList.count}.by(1)
      end

      it 'returns the created list' do
        post :create, params: params

        json_response = JSON.parse(response.body)
        created_list = TodoList.last

        expect(json_response).to eq created_list.as_json
      end
    end

    context 'when creation fails' do
      let(:params) { { name: nil } }

      it 'returns an error code' do
        post :create, params: params

        expect(response.status).to eq(422)
      end

      it 'no list is created' do
        expect { post :create, params: params }.not_to change{TodoList.count}
      end

      it 'returns the errors' do
        post :create, params: params

        json_response = JSON.parse(response.body)

        expect(json_response['name']).to match_array ["can't be blank"]
      end
    end
  end

  describe 'PUT update' do
    let!(:todo_list) { TodoList.create(name: 'Setup RoR project') }

    context 'when list can be updated' do
      let(:params) { { id: todo_list.id, name: 'Setup RoR project 2' } }

      it 'returns a success code' do
        put :update, params: params
        expect(response.status).to eq(200)
      end

      it 'updates the list attribute' do
        expect do
          put :update, params: params
          todo_list.reload
        end.to change(todo_list, :name).from('Setup RoR project').to('Setup RoR project 2')
      end

      it 'returns the updated list' do
        put :update, params: params

        json_response = JSON.parse(response.body)
        created_list = TodoList.last

        expect(json_response).to eq created_list.as_json
      end
    end

    context 'when update fails' do
      let(:params) { { id: todo_list.id, name: nil } }

      it 'returns an error code' do
        put :update, params: params

        expect(response.status).to eq(422)
      end

      it 'the list attribute keeps the same' do
        expect do
          put :update, params: params
          todo_list.reload
        end.not_to change(todo_list, :name)
      end

      it 'returns the errors' do
        put :update, params: params

        json_response = JSON.parse(response.body)

        expect(json_response['name']).to match_array ["can't be blank"]
      end
    end
  end

  describe 'DELETE destroy' do
    let!(:todo_list) { TodoList.create(name: 'Setup RoR project') }

    let(:params) { { id: todo_list.id } }

    it 'returns a success code' do
      delete :destroy, params: params
      expect(response.status).to eq(200)
    end

    it 'destroys the list' do
      expect { delete :destroy, params: params }.to change{TodoList.count}.by(-1)
    end

    it 'returns nothing' do
      delete :destroy, params: params

      expect(response.body).to be_blank
    end
  end

  describe 'PUT complete_tasks' do
    include ActiveJob::TestHelper

    before do
      todo_list.todo_list_items.create(description: 'Task 1')
      todo_list.todo_list_items.create(description: 'Task 2')
    end

    after do
      clear_enqueued_jobs
    end

    let!(:todo_list) { TodoList.create(name: 'Setup RoR project') }

    let(:params) { { todo_list_id: todo_list.id } }

    it 'returns a success code' do
      put :complete_tasks, params: params
      expect(response.status).to eq(200)
    end

    it 'enqueues the ListCompleterJob' do
      expect {
        put :complete_tasks, params: params
      }.to have_enqueued_job(ListCompleterJob).once
    end
  end
end

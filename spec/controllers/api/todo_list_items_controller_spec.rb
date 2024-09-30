require 'rails_helper'

describe Api::TodoListItemsController do
  render_views

  let!(:todo_list) { TodoList.create(name: 'Setup RoR project') }
  let!(:todo_list_item_1) { todo_list.todo_list_items.create(description: 'Task 1') }
  let!(:todo_list_item_2) { todo_list.todo_list_items.create(description: 'Task 2') }

  describe 'GET index' do
    let(:params) { { todo_list_id: todo_list.id } }

    context 'when format is HTML' do
      it 'raises a routing error' do
        expect {
          get :index, params: params
        }.to raise_error(ActionController::RoutingError, 'Not supported format')
      end
    end

    context 'when format is JSON' do
      it 'returns a success code' do
        get :index, params: params, format: :json

        expect(response.status).to eq(200)
      end

      it 'includes todo list items records' do
        get :index, params: params, format: :json

        todo_list_items = JSON.parse(response.body)

        aggregate_failures 'includes the right attributes' do
          expect(todo_list_items.count).to eq(2)
          expect(todo_list_items).to match_array([
            todo_list_item_1.as_json, todo_list_item_2.as_json
          ])
        end
      end
    end
  end

  describe 'POST create' do
    context 'when list item can be created' do
      let(:params) { { todo_list_id: todo_list.id, description: 'Task 3' } }

      it 'returns a success code' do
        post :create, params: params

        expect(response.status).to eq(201)
      end

      it 'creates a new list item' do
        expect { post :create, params: params }.to change{TodoListItem.count}.by(1)
      end

      it 'returns the created list' do
        post :create, params: params

        json_response = JSON.parse(response.body)
        created_list = TodoListItem.last

        expect(json_response).to eq created_list.as_json
      end
    end

    context 'when creation fails' do
      let(:params) { { todo_list_id: todo_list.id, description: nil } }

      it 'returns an error code' do
        post :create, params: params

        expect(response.status).to eq(422)
      end

      it 'no list item is created' do
        expect { post :create, params: params }.not_to change{TodoListItem.count}
      end

      it 'returns the errors' do
        post :create, params: params

        json_response = JSON.parse(response.body)

        expect(json_response['description']).to match_array ["can't be blank"]
      end
    end
  end

  describe 'PUT update' do
    context 'when list item can be updated' do
      let(:params) { { todo_list_id: todo_list.id, id: todo_list_item_2.id, description: 'Task 2.1' } }

      it 'returns a success code' do
        put :update, params: params
        expect(response.status).to eq(200)
      end

      it 'updates the list item attribute' do
        expect do
          put :update, params: params
          todo_list_item_2.reload
        end.to change(todo_list_item_2, :description).from('Task 2').to('Task 2.1')
      end

      it 'returns the updated list item' do
        put :update, params: params

        json_response = JSON.parse(response.body)

        expect(json_response).to eq todo_list_item_2.reload.as_json
      end
    end

    context 'when creation fails' do
      let(:params) { { todo_list_id: todo_list.id, id: todo_list_item_2.id, description: nil } }

      it 'returns an error code' do
        put :update, params: params

        expect(response.status).to eq(422)
      end

      it 'the list item attribute keeps the same' do
        expect do
          put :update, params: params
          todo_list_item_2.reload
        end.not_to change(todo_list_item_2, :description)
      end

      it 'returns the errors' do
        put :update, params: params

        json_response = JSON.parse(response.body)

        expect(json_response['description']).to match_array ["can't be blank"]
      end
    end
  end

  describe 'DELETE destroy' do
    let(:params) { { todo_list_id: todo_list.id, id: todo_list_item_2.id } }

    it 'returns a success code' do
      delete :destroy, params: params
      expect(response.status).to eq(200)
    end

    it 'destroys the list' do
      expect { delete :destroy, params: params }.to change{TodoListItem.count}.by(-1)
    end

    it 'returns nothing' do
      delete :destroy, params: params

      expect(response.body).to be_blank
    end
  end

  describe 'PUT complete_task' do
    include ActiveJob::TestHelper

    let!(:todo_list) { TodoList.create(name: 'Setup RoR project') }

    let(:params) { { todo_list_id: todo_list.id, todo_list_item_id: todo_list_item_2.id } }

    let(:current) { Time.current }

    context 'when item is pending' do
      before do
        travel_to current
      end

      after do
        travel_back
      end

      it 'returns a success code' do
        put :complete_task, params: params
        expect(response.status).to eq(200)
      end

      it 'mark the task as completed' do
        expect do
          put :complete_task, params: params
          todo_list_item_2.reload
        end.to change(todo_list_item_2, :completed_at).from(nil).to be_within(1.second).of current
      end
    end

    context 'when item is already completed' do
      before do
        todo_list_item_2.complete!
        todo_list_item_2.reload
      end

      it 'returns an error code' do
        put :complete_task, params: params
        expect(response.status).to eq(422)
      end

      it 'the list item attribute keeps the same' do
        expect do
          put :complete_task, params: params
          todo_list_item_2.reload
        end.not_to change(todo_list_item_2, :completed_at)
      end

      it 'returns the errors' do
        put :complete_task, params: params

        json_response = JSON.parse(response.body)

        expect(json_response['completed_at']).to match_array ["The task is already completed"]
      end
    end
  end
end

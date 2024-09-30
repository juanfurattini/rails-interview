require 'rails_helper'

describe TodoListItemsController do
  render_views

  let!(:todo_list) { TodoList.create(name: 'Setup RoR project') }
  let!(:todo_list_item_1) { todo_list.todo_list_items.create(description: 'Task 1') }
  let!(:todo_list_item_2) { todo_list.todo_list_items.create(description: 'Task 2') }

  describe 'GET index' do
    let(:params) { { todo_list_id: todo_list.id } }

    it 'returns a success code' do
      get :index, params: params

      expect(response.status).to eq(200)
    end

    it 'assigns todo list records' do
      get :index, params: params

      expect(assigns(:todo_list_items)).to match_array todo_list.todo_list_items
    end

    it 'renders index' do
      get :index, params: params

      expect(response).to render_template('index')
    end
  end

  describe 'POST create' do
    context 'when list item can be created' do
      let(:params) { { todo_list_id: todo_list.id, todo_list_item: { description: 'Task 3', todo_list_id: todo_list.id } } }

      it 'returns a success code' do
        post :create, params: params

        expect(response.status).to eq(201)
      end

      it 'creates a new list item' do
        expect { post :create, params: params }.to change{TodoListItem.count}.by(1)
      end

      it 'assigns todo list records' do
        post :create, params: params

        expect(assigns(:todo_list_item)).to eq TodoListItem.last
      end
    end

    context 'when creation fails' do
      let(:params) { { todo_list_id: todo_list.id, todo_list_item: { description: nil, todo_list_id: todo_list.id } } }

      it 'returns an error code' do
        post :create, params: params

        expect(response.status).to eq(422)
      end

      it 'no list item is created' do
        expect { post :create, params: params }.not_to change{TodoListItem.count}
      end

      it 'renders new' do
        post :create, params: params

        expect(response).to render_template('new')
      end
    end
  end

  describe 'PUT update' do
    context 'when list item can be updated' do
      let(:params) { { todo_list_id: todo_list.id, id: todo_list_item_2.id, todo_list_item: { description: 'Task 2.1', todo_list_id: todo_list.id } } }

      it 'returns a success code' do
        put :update, params: params
        expect(response.status).to eq(302)
      end

      it 'updates the list item attribute' do
        expect do
          put :update, params: params
          todo_list_item_2.reload
        end.to change(todo_list_item_2, :description).from('Task 2').to('Task 2.1')
      end

      it 'assigns todo list records' do
        put :update, params: params

        expect(assigns(:todo_list_item)).to eq TodoListItem.last
      end
    end

    context 'when update fails' do
      let(:params) { { todo_list_id: todo_list.id, id: todo_list_item_2.id, todo_list_item: { description: nil, todo_list_id: todo_list.id } } }

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

      it 'renders edit' do
        put :update, params: params

        expect(response).to render_template('edit')
      end
    end
  end

  describe 'DELETE destroy' do
    let(:params) { { todo_list_id: todo_list.id, id: todo_list_item_2.id } }

    it 'returns a success code' do
      delete :destroy, params: params
      expect(response.status).to eq(302)
    end

    it 'destroys the list' do
      expect { delete :destroy, params: params }.to change{TodoListItem.count}.by(-1)
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
        expect(response.status).to eq(302)
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

      it 'renders show' do
        put :complete_task, params: params

        expect(response).to render_template('show')
      end
    end
  end
end

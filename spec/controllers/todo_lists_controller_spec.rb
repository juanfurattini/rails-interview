require 'rails_helper'

describe TodoListsController do
  render_views

  describe 'GET index' do
    let!(:todo_list) { TodoList.create(name: 'Setup RoR project') }

    it 'returns a success code' do
      get :index

      expect(response.status).to eq(200)
    end

    it 'assigns todo list records' do
      get :index

      expect(assigns(:todo_lists)).to match_array [todo_list]
    end

    it 'renders index' do
      get :index

      expect(response).to render_template('index')
    end
  end

  describe 'POST create' do
    context 'when list can be created' do
      let(:params) { { todo_list: { name: 'Setup RoR project' } } }

      it 'returns a success code' do
        post :create, params: params

        expect(response.status).to eq(201)
      end

      it 'creates a new list' do
        expect { post :create, params: params }.to change{TodoList.count}.by(1)
      end

      it 'assigns todo list records' do
        post :create, params: params

        expect(assigns(:todo_list)).to eq TodoList.last
      end
    end

    context 'when creation fails' do
      let(:params) { { todo_list: { name: nil } } }

      it 'returns an error code' do
        post :create, params: params

        expect(response.status).to eq(422)
      end

      it 'no list is created' do
        expect { post :create, params: params }.not_to change{TodoList.count}
      end

      it 'renders new' do
        post :create, params: params

        expect(response).to render_template('new')
      end
    end
  end

  describe 'PUT update' do
    let!(:todo_list) { TodoList.create(name: 'Setup RoR project') }

    context 'when list can be updated' do
      let(:params) { { id: todo_list.id, todo_list: { name: 'Setup RoR project 2' } } }

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

      it 'assigns todo list records' do
        put :update, params: params

        expect(assigns(:todo_list)).to eq TodoList.last
      end
    end

    context 'when update fails' do
      let(:params) { { id: todo_list.id, todo_list: { name: nil } } }

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

      it 'renders edit' do
        put :update, params: params

        expect(response).to render_template('edit')
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

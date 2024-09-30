require 'rails_helper'

RSpec.describe TodoListItem, type: :model do
  let!(:todo_list) do
    TodoList.create(name: 'Setup RoR project').tap do |list|
      list.todo_list_items.create(description: 'Task 1')
      list.todo_list_items.create(description: 'Task 2')
    end.reload
  end
  let!(:todo_list_item) { todo_list.todo_list_items.last }

  describe 'scopres' do
    before { todo_list_item.complete! }

    describe 'pending' do
      it 'returns the pending items' do
        expect(TodoListItem.pending).to match_array [todo_list.todo_list_items.first]
      end
    end

    describe 'completed' do
      it 'returns the completed items' do
        expect(TodoListItem.completed).to match_array [todo_list.todo_list_items.last]
      end
    end
  end

  describe 'associations' do
    it { expect(todo_list_item).to respond_to :todo_list }

    it 'all items are elements of class TodoListItem' do
      expect(todo_list_item.todo_list).to be_a TodoList
    end
  end

  describe '#complete!' do
    context 'when item is completed' do
      before { todo_list_item.complete! }

      it 'completed_at is not updated' do
        expect do
          todo_list_item.complete!
          todo_list_item.reload
        end.not_to change(todo_list_item, :completed_at)
      end

      it 'contains the error' do
        todo_list_item.complete!
        expect(todo_list_item.errors[:completed_at]).to be_present
      end
    end

    context 'when item is not completed' do
      include ActiveJob::TestHelper

      before { travel_to current }

      after { travel_back }

      let(:current) { Time.current }

      it 'updates the completed_at' do
        expect do
          todo_list_item.complete!
          todo_list_item.reload
        end.to change(todo_list_item, :completed_at).from(nil).to be_within(1.second).of current
      end

      it 'no errors were generated' do
        todo_list_item.complete!
        expect(todo_list_item.errors[:completed_at]).to be_blank
      end
    end
  end

  describe '#pending?' do
    context 'when item is completed' do
      before { todo_list_item.complete! }

      it 'returns false' do
        expect(todo_list_item.reload.pending?).to be false
      end
    end

    context 'when item is not completed' do
      it 'returns true' do
        expect(todo_list_item.reload.pending?).to be true
      end
    end
  end

  describe '#completed?' do
    context 'when item is completed' do
      before { todo_list_item.complete! }

      it 'returns true' do
        expect(todo_list_item.reload.completed?).to be true
      end
    end

    context 'when item is not completed' do
      it 'returns false' do
        expect(todo_list_item.reload.completed?).to be false
      end
    end
  end
end

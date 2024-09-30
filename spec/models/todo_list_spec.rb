require 'rails_helper'

RSpec.describe TodoList, type: :model do
  let!(:todo_list) do
    TodoList.create(name: 'Setup RoR project').tap do |list|
      list.todo_list_items.create(description: 'Task 1')
      list.todo_list_items.create(description: 'Task 2')
    end.reload
  end

  describe 'associations' do
    it { expect(todo_list).to respond_to :todo_list_items }

    it 'all items are elements of class TodoListItem' do
      expect(todo_list.todo_list_items).to all(be_a(TodoListItem))
    end
  end

  describe 'validations' do
    subject(:list) { TodoList.new(name: name) }

    context 'when name is not present' do
      let(:name) { nil }

      it { is_expected.not_to be_valid }

      it 'contains the error' do
        list.valid?
        expect(list.errors[:name]).to be_present
      end
    end

    context 'when name is present' do
      let(:name) { 'Sample name' }

      it { is_expected.to be_valid }

      it 'contains the error' do
        list.valid?
        expect(list.errors[:name]).not_to be_present
      end
    end
  end

  describe '#complete!' do
    context 'when all items are completed' do
      before { todo_list.todo_list_items.map(&:complete!) }

      it 'marks all items as completed' do
        todo_list.complete!
        expect(todo_list.reload.completed?).to be true
      end
    end

    context 'when some items are completed' do
      before { todo_list.todo_list_items.first.complete! }

      it 'marks all items as completed' do
        todo_list.complete!
        expect(todo_list.reload.completed?).to be true
      end
    end

    context 'when all items are pending' do
      it 'marks all items as completed' do
        todo_list.complete!
        expect(todo_list.reload.completed?).to be true
      end
    end
  end

  describe '#pending?' do
    context 'when all items are completed' do
      before { todo_list.todo_list_items.map(&:complete!) }

      it 'returns false' do
        expect(todo_list.reload.pending?).to be false
      end
    end

    context 'when some items are completed' do
      before { todo_list.todo_list_items.first.complete! }

      it 'returns true' do
        expect(todo_list.reload.pending?).to be true
      end
    end

    context 'when all items are pending' do
      it 'returns true' do
        expect(todo_list.reload.pending?).to be true
      end
    end
  end

  describe '#completed?' do
    context 'when all items are completed' do
      before { todo_list.todo_list_items.map(&:complete!) }

      it 'returns true' do
        expect(todo_list.reload.completed?).to be true
      end
    end

    context 'when some items are completed' do
      before { todo_list.todo_list_items.first.complete! }

      it 'returns false' do
        expect(todo_list.reload.completed?).to be false
      end
    end

    context 'when all items are pending' do
      it 'returns false' do
        expect(todo_list.reload.completed?).to be false
      end
    end
  end
end

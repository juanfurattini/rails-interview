class TodoList < ApplicationRecord
  has_many :todo_list_items

  validates :name, presence: true

  def complete!
    todo_list_items.pending.map(&:complete!)
  end

  def pending?
    todo_list_items.pending.any?
  end

  def completed?
    !pending?
  end
end
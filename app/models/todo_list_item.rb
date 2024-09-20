class TodoListItem < ApplicationRecord
  belongs_to :todo_list

  scope :pending, -> { where(completed_at: nil) }
  scope :completed, -> { where.not(completed_at: nil) }

  validates :description, presence: true
  validate :completed_at_cannot_change, on: :update

  def complete!
    update(completed_at: Time.current)
  end

  def pending?
    self.completed_at.blank?
  end

  def completed?
    self.completed_at.present?
  end

  private

  def completed_at_cannot_change
    return unless will_save_change_to_completed_at? && completed_at_was.present?

    errors.add(:completed_at, 'The task is already completed')
  end
end
class AddTodoListItems < ActiveRecord::Migration[7.0]
  def change
    create_table :todo_list_items do |t|
      t.string :description, null: false
      t.timestamp :completed_at

      t.belongs_to :todo_list
    end
  end
end

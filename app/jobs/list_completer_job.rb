class ListCompleterJob < ApplicationJob
  queue_as :list_completer

  def perform(list_id)
    @todo_list = TodoList.find(list_id)
    @todo_list.complete!
  end
end

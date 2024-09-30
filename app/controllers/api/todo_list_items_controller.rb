module Api
  class TodoListItemsController < ApiController
    before_action :find_list
    before_action :find_list_item, only: %i[update destroy]

    # GET /api/todolists/:todo_list_id/todos
    def index
      @todo_list_items = @todo_list.todo_list_items

      respond_to :json
    end

    # POST /api/todolists/:todo_list_id/todos
    def create
      @todo_list_item = TodoListItem.new(create_params)

      if @todo_list_item.save
        render json: @todo_list_item, status: :created
      else
        render json: @todo_list_item.errors, status: :unprocessable_entity
      end
    end

    # PUT /api/todolist/:todo_list_id/todos/:id
    def update
      @todo_list_item.assign_attributes(update_params)

      if @todo_list_item.save
        render json: @todo_list_item, status: :ok
      else
        render json: @todo_list_item.errors, status: :unprocessable_entity
      end
    end

    # DELETE /api/todolist/:todo_list_id/todos/:id
    def destroy
      if @todo_list_item.destroy
        head :ok
      else
        head :unprocessable_entity
      end
    end

    # PUT /api/todolists/:todo_list_id/todos/:todo_list_item_id/complete_task
    def complete_task
      @todo_list_item = @todo_list.todo_list_items.find(params[:todo_list_item_id])

      if @todo_list_item.complete!
        render json: @todo_list_item, status: :ok
      else
        render json: @todo_list_item.errors, status: :unprocessable_entity
      end
    end


    private

    def find_list
      @todo_list = TodoList.find(params[:todo_list_id])
    end

    def find_list_item
      @todo_list_item = @todo_list.todo_list_items.find(params[:id])
    end

    def create_params
      params.permit(:description, :completed_at, :todo_list_id)
    end

    def update_params
      params.permit(:description, :todo_list_id)
    end
  end
end

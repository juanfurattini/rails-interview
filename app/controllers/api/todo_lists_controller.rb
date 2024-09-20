module Api
  class TodoListsController < ApiController
    before_action :find_list, only: %i[update destroy]

    # GET /api/todolists
    def index
      @todo_lists = TodoList.all

      respond_to :json
    end

    # POST /api/todolists
    def create
      @todo_list = TodoList.new(create_params)

      if @todo_list.save
        render json: @todo_list, status: :created
      else
        render json: @todo_list.errors, status: :unprocessable_entity
      end
    end

    # PUT /api/todolist/:id
    def update
      @todo_list.assign_attributes(update_params)

      if @todo_list.save
        render json: @todo_list, status: :ok
      else
        render json: @todo_list.errors, status: :unprocessable_entity
      end
    end

    # DELETE /api/todolists
    def destroy
      if @todo_list.destroy
        head :ok
      else
        head :unprocessable_entity
      end
    end

    # PUT /api/todolists/:todo_list_id/complete_tasks
    def complete_tasks
      ListCompleterJob.perform_later(params[:todo_list_id])

      head :ok
    end


    private

    def find_list
      @todo_list = TodoList.find(params[:id])
    end

    def create_params
      params.permit(:name)
    end

    def update_params
      params.permit(:name)
    end
  end
end
